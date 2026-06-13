import Foundation
import Security

// MARK: - API Error Handling

public struct ApiError: Error, LocalizedError {
    public let message: String
    public let code: String?
    
    public var errorDescription: String? {
        return message
    }
}

private struct ApiErrorBody: Codable {
    let message: String
    let code: String?
}

// MARK: - Keychain Helper

public enum KeychainHelper {
    private static let service = "com.aquarioufpb.app"
    private static let tokenAccount = "auth_token"
    private static let fallbackKey = "fallback_auth_token"
    
    @discardableResult
    public static func saveToken(_ token: String) -> Bool {
        // Fallback to UserDefaults immediately
        UserDefaults.standard.set(token, forKey: fallbackKey)
        
        guard let data = token.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenAccount,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public static func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data, let token = String(data: data, encoding: .utf8), !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return token
        }
        
        // Return fallback token if keychain failed or was empty
        if let fallbackToken = UserDefaults.standard.string(forKey: fallbackKey), !fallbackToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fallbackToken
        }
        
        return nil
    }
    
    @discardableResult
    public static func deleteToken() -> Bool {
        UserDefaults.standard.removeObject(forKey: fallbackKey)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenAccount
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - Redirect-Preserving URLSession Delegate

/// By default URLSession drops the Authorization header when following a 3xx redirect.
/// This delegate copies all original request headers onto every redirect so the token is never lost.
private final class RedirectPreservingDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        var newRequest = request
        // Preserve all original headers (especially Authorization)
        if let originalHeaders = task.originalRequest?.allHTTPHeaderFields {
            for (key, value) in originalHeaders {
                newRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        completionHandler(newRequest)
    }
}

// MARK: - Network Manager

public final class NetworkManager {
    public static let shared = NetworkManager()
    
    // Use www subdomain directly — aquarioufpb.com 307-redirects to www, which drops Auth headers
    public var baseURL = URL(string: "https://www.aquarioufpb.com/api")!
    
    private let redirectDelegate = RedirectPreservingDelegate()
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config, delegate: redirectDelegate, delegateQueue: nil)
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        // Custom date decoder for PostgreSQL/Prisma ISO8601 timestamps
        let formatterWithMs = DateFormatter()
        formatterWithMs.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let formatterWithoutMs = DateFormatter()
        formatterWithoutMs.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            if let date = formatterWithMs.date(from: dateStr) { return date }
            if let date = formatterWithoutMs.date(from: dateStr) { return date }
            if let date = simpleDateFormatter.date(from: dateStr) { return date }
            
            // Fallback
            let iso8601 = ISO8601DateFormatter()
            if let date = iso8601.date(from: dateStr) { return date }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Formato de data inválido: \(dateStr)"
            )
        }
        return decoder
    }()
    
    private init() {}
    
    // MARK: - Core Request Function
    
    private func request<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        let baseForPath = baseURL.appendingPathComponent(path)
        let url: URL
        if let queryItems = queryItems, !queryItems.isEmpty {
            var components = URLComponents(url: baseForPath, resolvingAgainstBaseURL: false)!
            components.queryItems = queryItems
            guard let resolvedURL = components.url else {
                throw ApiError(message: "URL inválida.", code: "INVALID_URL")
            }
            url = resolvedURL
        } else {
            url = baseForPath
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = KeychainHelper.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw ApiError(message: "Usuário não autenticado. Faça login novamente.", code: "UNAUTHORIZED")
            }
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError(message: "Resposta do servidor inválida.", code: "INVALID_RESPONSE")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorBody = try? jsonDecoder.decode(ApiErrorBody.self, from: data) {
                throw ApiError(message: errorBody.message, code: errorBody.code)
            } else {
                throw ApiError(
                    message: "Erro no servidor (Código: \(httpResponse.statusCode)).",
                    code: "HTTP_\(httpResponse.statusCode)"
                )
            }
        }
        
        // Special case: if T is String and data is empty or not JSON
        if T.self == String.self, let stringValue = String(data: data, encoding: .utf8) as? T {
            return stringValue
        }
        
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    // MARK: - API Methods
    
    public func login(email: String, senha: [String: String]) async throws -> String {
        let bodyDict = ["email": email, "senha": senha["senha"] ?? ""]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict)
        
        struct LoginResponse: Codable {
            let token: String
        }
        
        let response: LoginResponse = try await request(path: "auth/login", method: "POST", body: bodyData)
        KeychainHelper.saveToken(response.token)
        
        // Fetch and cache the user profile immediately
        let user = try await fetchMe()
        StorageProvider.shared.saveUser(user)
        
        return response.token
    }
    
    public func fetchMe() async throws -> Usuario {
        return try await request(path: "auth/me", requiresAuth: true)
    }
    
    public func fetchVagas() async throws -> [Vaga] {
        let vagas: [Vaga] = try await request(path: "vagas")
        
        // Cache in background thread or main context
        await MainActor.run {
            StorageProvider.shared.cacheVagas(vagas)
        }
        
        return vagas
    }
    
    public func fetchEntidades() async throws -> [Entidade] {
        let entidades: [Entidade] = try await request(path: "entidades")
        
        await MainActor.run {
            StorageProvider.shared.cacheEntidades(entidades)
        }
        
        return entidades
    }
    
    public func fetchGuias() async throws -> [Guia] {
        let guias: [Guia] = try await request(path: "guias")
        
        await MainActor.run {
            StorageProvider.shared.cacheGuias(guias)
        }
        
        return guias
    }
    
    public func logout() {
        KeychainHelper.deleteToken()
        DispatchQueue.main.async {
            StorageProvider.shared.clearUser()
        }
    }
    
    // MARK: - Registration and Onboarding data
    
    public func fetchCentros() async throws -> [Centro] {
        return try await request(path: "centros")
    }
    
    public func fetchCursos(centroId: String) async throws -> [Curso] {
        return try await request(path: "centros/\(centroId)/cursos")
    }
    
    public func register(
        nome: String,
        email: String,
        senha: String,
        centroId: String,
        cursoId: String
    ) async throws -> String {
        let bodyDict: [String: Any] = [
            "nome": nome,
            "email": email,
            "senha": senha,
            "centroId": centroId,
            "cursoId": cursoId
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict)
        
        struct RegisterResponse: Codable {
            let message: String
        }
        
        let response: RegisterResponse = try await request(path: "auth/register", method: "POST", body: bodyData)
        return response.message
    }
    
    // MARK: - Projetos & Grade Curricular API Methods
    
    public func fetchProjetos() async throws -> [Projeto] {
        struct ProjetosListResponse: Codable {
            let projetos: [Projeto]
        }
        let queryItems = [
            URLQueryItem(name: "status", value: "PUBLICADO"),
            URLQueryItem(name: "limit", value: "100")
        ]
        let response: ProjetosListResponse = try await request(path: "projetos", queryItems: queryItems)
        return response.projetos
    }
    
    public func fetchAllCursos() async throws -> [Curso] {
        return try await request(path: "cursos")
    }
    
    public func fetchGradeCurricular(cursoId: String) async throws -> GradeCurricularResponse {
        let queryItems = [URLQueryItem(name: "cursoId", value: cursoId)]
        return try await request(path: "curriculos/grade", queryItems: queryItems)
    }

    public func fetchSemestresLetivos() async throws -> [SemestreLetivo] {
        return try await request(path: "calendario-academico")
    }

    public func fetchSemestreLetivo(id: String) async throws -> SemestreLetivoDetalhado {
        return try await request(path: "calendario-academico/\(id)")
    }
}
