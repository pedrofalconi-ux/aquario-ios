import SwiftUI

public struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    @State private var confirmarSenha = ""
    
    @State private var centros: [Centro] = []
    @State private var cursos: [Curso] = []
    
    @State private var selectedCentroId: String = ""
    @State private var selectedCursoId: String = ""
    
    @State private var isLoading = false
    @State private var isLoadingOnboarding = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    public init() {}
    
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
                        .fill(Color.cyan.opacity(0.12))
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .offset(x: -50, y: -20)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .offset(x: 50, y: 20)
                }
            }
            .ignoresSafeArea()
            
            // Main Content
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Criar Conta")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Preencha os dados abaixo para se cadastrar")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                    
                    if let successMessage = successMessage {
                        // Success View
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.green)
                            
                            Text("Sucesso!")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text(successMessage)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: { dismiss() }) {
                                Text("Voltar para o Login")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 10)
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    } else {
                        // Form Card
                        VStack(spacing: 16) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Nome Completo")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                                    .bold()
                                
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                    TextField("Seu nome completo", text: $nome)
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
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("E-mail Institucional")
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
                            
                            // Center Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Centro Acadêmico")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                                    .bold()
                                
                                Picker("Selecione seu Centro", selection: $selectedCentroId) {
                                    if centros.isEmpty {
                                        Text("Carregando centros...").tag("")
                                    } else {
                                        Text("Selecione um centro").tag("")
                                        ForEach(centros) { centro in
                                            Text(centro.sigla).tag(centro.id)
                                        }
                                    }
                                }
                                .pickerStyle(.menu)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .onChange(of: selectedCentroId) { newValue in
                                    selectedCursoId = ""
                                    cursos = []
                                    if !newValue.isEmpty {
                                        loadCursos(for: newValue)
                                    }
                                }
                            }
                            
                            // Course Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Curso")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                                    .bold()
                                
                                Picker("Selecione seu Curso", selection: $selectedCursoId) {
                                    if selectedCentroId.isEmpty {
                                        Text("Selecione um centro primeiro").tag("")
                                    } else if isLoadingOnboarding {
                                        Text("Carregando cursos...").tag("")
                                    } else if cursos.isEmpty {
                                        Text("Nenhum curso encontrado").tag("")
                                    } else {
                                        Text("Selecione um curso").tag("")
                                        ForEach(cursos) { curso in
                                            Text(curso.nome).tag(curso.id)
                                        }
                                    }
                                }
                                .pickerStyle(.menu)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .disabled(selectedCentroId.isEmpty || isLoadingOnboarding)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Senha")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                                    .bold()
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                    SecureField("Mínimo 8 caracteres", text: $senha)
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
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Confirmar Senha")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                                    .bold()
                                
                                HStack {
                                    Image(systemName: "lock.rotation")
                                        .foregroundColor(.gray)
                                    SecureField("Repita sua senha", text: $confirmarSenha)
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
                            
                            // Submit Button
                            Button(action: handleRegister) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .padding(.trailing, 8)
                                    }
                                    Text(isLoading ? "Cadastrando..." : "Cadastrar")
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
                            .disabled(isLoading || isFormInvalid)
                            
                            // Back Button
                            Button(action: { dismiss() }) {
                                Text("Já tem conta? Entrar")
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
                    }
                }
            }
        }
        .onAppear(perform: loadCentros)
    }
    
    private var isFormInvalid: Bool {
        nome.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 ||
        email.isEmpty ||
        senha.count < 8 ||
        confirmarSenha != senha ||
        selectedCentroId.isEmpty ||
        selectedCursoId.isEmpty
    }
    
    private func loadCentros() {
        Task {
            do {
                let fetchedCentros = try await NetworkManager.shared.fetchCentros()
                await MainActor.run {
                    self.centros = fetchedCentros.sorted { $0.sigla < $1.sigla }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erro ao carregar centros: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func loadCursos(for centroId: String) {
        isLoadingOnboarding = true
        Task {
            do {
                let fetchedCursos = try await NetworkManager.shared.fetchCursos(centroId: centroId)
                await MainActor.run {
                    self.cursos = fetchedCursos.sorted { $0.nome < $1.nome }
                    self.isLoadingOnboarding = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erro ao carregar cursos: \(error.localizedDescription)"
                    self.isLoadingOnboarding = false
                }
            }
        }
    }
    
    private func handleRegister() {
        guard !isFormInvalid else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let msg = try await NetworkManager.shared.register(
                    nome: nome,
                    email: email,
                    senha: senha,
                    centroId: selectedCentroId,
                    cursoId: selectedCursoId
                )
                await MainActor.run {
                    isLoading = false
                    successMessage = msg
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
