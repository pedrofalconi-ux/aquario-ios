import SwiftUI

public struct LoginView: View {
    @Binding var isAuthenticated: Bool
    
    @State private var email = ""
    @State private var senha = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var isShowingRegister = false
    
    public init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
    }
    
    public var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.2),
                    Color(red: 0.04, green: 0.06, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative Glowing Circles
            VStack {
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: -80, y: -50)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: 80, y: 50)
                }
            }
            .ignoresSafeArea()
            
            // Main Content
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Logo and Title
                    VStack(spacing: 16) {
                        Image(systemName: "fish.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 4)
                        
                        Text("Aquário")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Plataforma acadêmica do CI — UFPB")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Form Card
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-mail institucional")
                                .font(.caption)
                                .foregroundColor(.cyan)
                                .bold()
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                TextField("usuario@academico.ufpb.br", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Senha")
                                .font(.caption)
                                .foregroundColor(.cyan)
                                .bold()
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                SecureField("Sua senha secreta", text: $senha)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        // Error Banner
                        if let errorMessage = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                            .transition(.opacity)
                        }
                        
                        // Action Button
                        Button(action: handleLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 8)
                                }
                                Text(isLoading ? "Entrando..." : "Entrar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .disabled(isLoading || email.isEmpty || senha.isEmpty)
                        
                        Button(action: { isShowingRegister = true }) {
                            Text("Não tem uma conta? Cadastre-se")
                                .font(.subheadline)
                                .foregroundColor(.cyan)
                                .padding(.top, 8)
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingRegister) {
            RegisterView()
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty && !senha.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await NetworkManager.shared.login(email: email, senha: ["senha": senha])
                await MainActor.run {
                    isLoading = false
                    isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isAuthenticated: .constant(false))
    }
}
