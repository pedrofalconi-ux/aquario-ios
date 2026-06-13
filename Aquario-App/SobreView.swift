import SwiftUI

public struct SobreView: View {
    
    private let problemsBefore = [
        "Falta de informação centralizada",
        "Excesso de locais para buscar informações",
        "Dificuldade de comunicação entre alunos, professores e laboratórios",
        "Vagas perdidas em e-mails",
        "Projetos sem visibilidade"
    ]
    
    private let problemsAfter = [
        "Informações centralizadas em um só lugar",
        "Comunicação eficiente e organizada",
        "Facilidade de acesso a oportunidades",
        "Melhor organização de vagas e projetos",
        "Comunidade conectada e colaborativa"
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient matching app theme
                Color(red: 0.08, green: 0.12, blue: 0.2)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.cyan)
                            }
                            
                            Text("Sobre o Aquário")
                                .font(.system(.largeTitle, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("A plataforma do Centro de Informática da UFPB que centraliza tudo o que você precisa em um só lugar.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Problems & Solutions Comparison
                        VStack(spacing: 16) {
                            // Before card
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Antes do Aquário")
                                    .font(.headline)
                                    .foregroundColor(.red.opacity(0.8))
                                
                                ForEach(problemsBefore, id: \.self) { problem in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red.opacity(0.8))
                                            .font(.subheadline)
                                        Text(problem)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                            
                            // After card
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Com o Aquário")
                                    .font(.headline)
                                    .foregroundColor(.green.opacity(0.8))
                                
                                ForEach(problemsAfter, id: \.self) { solution in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green.opacity(0.8))
                                            .font(.subheadline)
                                        Text(solution)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Platform Features card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Funcionalidades")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("O Aquário é uma plataforma em constante evolução desenvolvida para organizar e facilitar a vida acadêmica. No ar para o semestre de 2026.1:")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                featureItem(title: "Guias Acadêmicos", desc: "Dicas e tutoriais úteis sobre o curso.")
                                featureItem(title: "Grade Curricular Interativa", desc: "Fluxograma interativo com pré-requisitos.")
                                featureItem(title: "Diretório de Entidades", desc: "Laboratórios, projetos e atléticas do CI.")
                                featureItem(title: "Projetos de Alunos", desc: "Portfólio publicado pela comunidade.")
                                featureItem(title: "Minhas Disciplinas", desc: "Monte seu calendário e turmas semestrais.")
                            }
                            .padding(.top, 6)
                        }
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Open Source card
                        VStack(spacing: 16) {
                            Image(systemName: "curlybraces.square.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("Projeto Open Source")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("O Aquário é open source licenciado sob a licença MIT. Qualquer membro da comunidade pode contribuir com melhorias, seja sugerindo ideias ou enviando código.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            if let githubUrl = URL(string: "https://github.com/aquario-ufpb/aquario") {
                                Link(destination: githubUrl) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("Contribuir no GitHub")
                                    }
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sobre o Aquário")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    @ViewBuilder
    private func featureItem(title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.cyan)
                .bold()
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.72))
            }
        }
    }
}

struct SobreView_Previews: PreviewProvider {
    static var previews: some View {
        SobreView()
    }
}
