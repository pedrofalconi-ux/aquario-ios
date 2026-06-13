import SwiftUI

public struct ProjetosView: View {
    @State private var projetos: [Projeto] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil // nil means "Todos"
    
    private let filters = [
        (id: nil as String?, label: "Todos"),
        (id: "PESSOAL", label: "Pessoais"),
        (id: "LABORATORIO", label: "Laboratórios"),
        (id: "GRUPO", label: "Grupos"),
        (id: "LIGA_ACADEMICA", label: "Ligas")
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                Color(red: 0.08, green: 0.12, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Projetos")
                            .font(.system(.largeTitle, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Portfólio de projetos desenvolvidos pela comunidade do CI")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Pesquisar projetos...", text: $searchText)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Category filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filters, id: \.label) { filter in
                                    Button(action: {
                                        selectedFilter = filter.id
                                    }) {
                                        Text(filter.label)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedFilter == filter.id ?
                                                Color.blue : Color.white.opacity(0.1)
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(red: 0.05, green: 0.08, blue: 0.15))
                    
                    // Main content
                    Group {
                        if isLoading && projetos.isEmpty {
                            Spacer()
                            ProgressView()
                                .tint(.white)
                            Spacer()
                        } else if let error = errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.yellow)
                                Text("Erro ao carregar projetos")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Button("Tentar Novamente") {
                                    loadProjetos()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                            .frame(maxHeight: .infinity)
                        } else {
                            let filtered = filteredProjetos
                            if filtered.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "folder.badge.questionmark")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    Text("Nenhum projeto encontrado")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxHeight: .infinity)
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 16) {
                                        ForEach(filtered) { projeto in
                                            NavigationLink(destination: ProjetoDetailView(projeto: projeto)) {
                                                ProjetoCardView(projeto: projeto)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                                .refreshable {
                                    loadProjetos()
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Projetos")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .onAppear(perform: loadProjetos)
        }
    }
    
    private var filteredProjetos: [Projeto] {
        projetos.filter { proj in
            // Filter by search text
            let matchesSearch = searchText.isEmpty ||
                proj.titulo.localizedCaseInsensitiveContains(searchText) ||
                (proj.subtitulo?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                proj.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            
            // Filter by entity type
            let matchesFilter: Bool
            if let filter = selectedFilter {
                matchesFilter = proj.autores.contains { autor in
                    autor.entidade?.tipo == filter
                }
            } else {
                matchesFilter = true
            }
            
            return matchesSearch && matchesFilter
        }
    }
    
    private func loadProjetos() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetched = try await NetworkManager.shared.fetchProjetos()
                await MainActor.run {
                    self.projetos = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Sub-View: Card do Projeto
struct ProjetoCardView: View {
    let projeto: Projeto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Project Image banner / gradient fallback
            if let imageURL = resolveImageUrl(projeto.urlImagem) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                    case .failure, .empty:
                        gradientFallback
                    @unknown default:
                        gradientFallback
                    }
                }
            } else {
                gradientFallback
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 10) {
                Text(projeto.titulo)
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let subtitle = projeto.subtitulo {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Tags
                if !projeto.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(projeto.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                
                // Author row
                if let principal = principalAuthor {
                    HStack(spacing: 6) {
                        if let avatarUrl = authorAvatarUrl(principal), let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { phase in
                                if case .success(let image) = phase {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 20, height: 20)
                                        .clipShape(Circle())
                                } else {
                                    defaultAuthorIcon(principal)
                                }
                            }
                        } else {
                            defaultAuthorIcon(principal)
                        }
                        
                        Text(authorName(principal))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var gradientFallback: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.2, blue: 0.4),
                Color(red: 0.05, green: 0.1, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 120)
        .overlay(
            Image(systemName: "folder.fill")
                .foregroundColor(.white.opacity(0.3))
                .font(.system(size: 36))
        )
    }
    
    private var principalAuthor: ProjetoAutorPublic? {
        // Find principal author, otherwise first author
        projeto.autores.first(where: { $0.autorPrincipal }) ?? projeto.autores.first
    }
    
    private func authorName(_ autor: ProjetoAutorPublic) -> String {
        if let ent = autor.entidade {
            return ent.nome
        } else if let usr = autor.usuario {
            return usr.nome
        }
        return "Autor desconhecido"
    }
    
    private func authorAvatarUrl(_ autor: ProjetoAutorPublic) -> String? {
        if let ent = autor.entidade {
            return ent.urlFoto
        } else if let usr = autor.usuario {
            return usr.urlFotoPerfil
        }
        return nil
    }
    
    @ViewBuilder
    private func defaultAuthorIcon(_ autor: ProjetoAutorPublic) -> some View {
        Image(systemName: autor.entidade != nil ? "building.2.fill" : "person.fill")
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    private func resolveImageUrl(_ urlString: String?) -> URL? {
        guard let urlString = urlString else { return nil }
        if urlString.hasPrefix("http") {
            return URL(string: urlString)
        } else if urlString.hasPrefix("/") {
            return URL(string: "https://aquarioufpb.com" + urlString)
        } else {
            return URL(string: "https://aquarioufpb.com/" + urlString)
        }
    }
}

// MARK: - Sub-View: Detalhes do Projeto
struct ProjetoDetailView: View {
    let projeto: Projeto
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Banner Image
                if let imageURL = resolveImageUrl(projeto.urlImagem) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 220)
                                .clipped()
                        default:
                            gradientHeader
                        }
                    }
                } else {
                    gradientHeader
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(projeto.titulo)
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                        
                        if let sub = projeto.subtitulo {
                            Text(sub)
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Meta Actions & Info
                    HStack(spacing: 12) {
                        if let repo = projeto.urlRepositorio, let url = URL(string: repo) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "terminal.fill")
                                    Text("GitHub")
                                }
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        
                        if let demo = projeto.urlDemo, let url = URL(string: demo) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Demo")
                                }
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Details Divider
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Project description
                    if let content = projeto.textContent, !content.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sobre o Projeto")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(content)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(6)
                        }
                    }
                    
                    // Autores section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Autores")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(projeto.autores) { autor in
                            HStack(spacing: 12) {
                                if let avatarUrl = authorAvatarUrl(autor), let url = URL(string: avatarUrl) {
                                    AsyncImage(url: url) { phase in
                                        if case .success(let image) = phase {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 36, height: 36)
                                                .clipShape(Circle())
                                        } else {
                                            defaultAvatar(autor)
                                        }
                                    }
                                } else {
                                    defaultAvatar(autor)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(authorName(autor))
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Text(autor.autorPrincipal ? "Autor Principal" : "Colaborador")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .background(Color(red: 0.08, green: 0.12, blue: 0.2).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var gradientHeader: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.2, blue: 0.4),
                Color(red: 0.05, green: 0.1, blue: 0.25)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 180)
    }
    
    private func authorName(_ autor: ProjetoAutorPublic) -> String {
        if let ent = autor.entidade {
            return ent.nome
        } else if let usr = autor.usuario {
            return usr.nome
        }
        return "Autor desconhecido"
    }
    
    private func authorAvatarUrl(_ autor: ProjetoAutorPublic) -> String? {
        if let ent = autor.entidade {
            return ent.urlFoto
        } else if let usr = autor.usuario {
            return usr.urlFotoPerfil
        }
        return nil
    }
    
    @ViewBuilder
    private func defaultAvatar(_ autor: ProjetoAutorPublic) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 36, height: 36)
            
            Image(systemName: autor.entidade != nil ? "building.2.fill" : "person.fill")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
    }
    
    private func resolveImageUrl(_ urlString: String?) -> URL? {
        guard let urlString = urlString else { return nil }
        if urlString.hasPrefix("http") {
            return URL(string: urlString)
        } else if urlString.hasPrefix("/") {
            return URL(string: "https://aquarioufpb.com" + urlString)
        } else {
            return URL(string: "https://aquarioufpb.com/" + urlString)
        }
    }
}

struct ProjetosView_Previews: PreviewProvider {
    static var previews: some View {
        ProjetosView()
    }
}
