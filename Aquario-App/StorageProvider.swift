import Foundation

// MARK: - Storage Provider

public final class StorageProvider {
    public static let shared = StorageProvider()
    
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private init() {}
    
    // MARK: - Internal Cache Helpers
    
    private func fileURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent("\(key).json")
    }
    
    private func save<T: Encodable>(_ data: T, to key: String) {
        let url = fileURL(for: key)
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url, options: .atomic)
        } catch {
            print("Erro ao salvar cache local para '\(key)': \(error)")
        }
    }
    
    private func load<T: Decodable>(key: String) -> T? {
        let url = fileURL(for: key)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Erro ao ler cache local para '\(key)': \(error)")
            return nil
        }
    }
    
    private func remove(key: String) {
        let url = fileURL(for: key)
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Public API
    
    public func saveUser(_ user: Usuario) {
        save(user, to: "user_profile")
    }
    
    public func getCachedUser() -> Usuario? {
        return load(key: "user_profile")
    }
    
    public func clearUser() {
        remove(key: "user_profile")
    }

    public func saveProfileAvatarData(_ data: Data) {
        let url = fileURL(for: "profile_avatar")
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print("Erro ao salvar avatar local: \(error)")
        }
    }

    public func getProfileAvatarData() -> Data? {
        let url = fileURL(for: "profile_avatar")
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    public func clearProfileAvatar() {
        remove(key: "profile_avatar")
    }

    public func saveSelectedEntidade(_ entidade: Entidade) {
        save(entidade, to: "selected_entidade")
    }

    public func getSelectedEntidade() -> Entidade? {
        load(key: "selected_entidade")
    }

    public func clearSelectedEntidade() {
        remove(key: "selected_entidade")
    }
    
    public func cacheVagas(_ list: [Vaga]) {
        save(list, to: "cached_vagas")
    }
    
    public func getCachedVagas() -> [Vaga] {
        return load(key: "cached_vagas") ?? []
    }
    
    public func cacheEntidades(_ list: [Entidade]) {
        save(list, to: "cached_entidades")
    }
    
    public func getCachedEntidades() -> [Entidade] {
        return load(key: "cached_entidades") ?? []
    }
    
    public func cacheGuias(_ list: [Guia]) {
        save(list, to: "cached_guias")
    }
    
    public func getCachedGuias() -> [Guia] {
        return load(key: "cached_guias") ?? []
    }
}
