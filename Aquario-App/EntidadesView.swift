import SwiftUI

public struct EntidadesView: View {
    @State private var entidades: [Entidade] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText = ""
    @State private var selectedType: TipoEntidade? = nil
    @State private var selectedEntidade: Entidade? = nil

    public init() {}

    private var filteredEntidades: [Entidade] {
        entidades.filter { entidade in
            let matchesSearch = searchText.isEmpty ||
                entidade.nome.localizedCaseInsensitiveContains(searchText) ||
                (entidade.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (entidade.descricao?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesType = selectedType == nil || entidade.tipo == selectedType
            return matchesSearch && matchesType
        }
    }

    private var laboratorios: [Entidade] {
        filteredEntidades
            .filter { $0.tipo == .laboratorio }
            .sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
    }

    private var gruposELigas: [Entidade] {
        filteredEntidades
            .filter { $0.tipo == .grupo || $0.tipo == .ligaAcademica || $0.tipo == .outro }
            .sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
    }

    private var centrosEAtleticas: [Entidade] {
        filteredEntidades
            .filter { $0.tipo == .centroAcademico || $0.tipo == .atletica }
            .sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
    }

    private var empresasParceiras: [Entidade] {
        filteredEntidades
            .filter { $0.tipo == .empresa }
            .sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.10, blue: 0.22),
                        Color(red: 0.05, green: 0.20, blue: 0.35),
                        Color(red: 0.82, green: 0.94, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection

                        VStack(spacing: 14) {
                            SearchBar(text: $searchText)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterChip(title: "Todos", isSelected: selectedType == nil) {
                                        selectedType = nil
                                    }

                                    ForEach(TipoEntidade.allCases, id: \.self) { type in
                                        FilterChip(title: type.displayName, isSelected: selectedType == type) {
                                            selectedType = type
                                        }
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )

                        if isLoading && entidades.isEmpty {
                            loadingSection
                        } else if let errorMessage, filteredEntidades.isEmpty {
                            errorSection(message: errorMessage)
                        } else if filteredEntidades.isEmpty {
                            emptySection
                        } else {
                            VStack(alignment: .leading, spacing: 28) {
                                EntidadeSection(title: "Laboratórios", entities: laboratorios, onTap: openDetail)
                                EntidadeSection(title: "Grupos e Ligas", entities: gruposELigas, onTap: openDetail)
                                EntidadeSection(title: "Centros Acadêmicos e Atléticas", entities: centrosEAtleticas, onTap: openDetail)
                                EntidadeSection(title: "Empresas Parceiras", entities: empresasParceiras, onTap: openDetail)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await loadEntidades(force: true)
                }
            }
            .navigationTitle("Entidades")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                Task {
                    await loadEntidades(force: false)
                }
            }
            .sheet(item: $selectedEntidade) { entidade in
                EntidadeDetailView(entidade: entidade)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Entidades")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("As mesmas fotos, nomes e agrupamentos do Aquário para você reconhecer cada laboratório, grupo, liga e entidade acadêmica sem estranhar a mudança de plataforma.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                Image("AquarioLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .padding(10)
                    .background(Color.white.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            HStack(spacing: 10) {
                metricPill(value: filteredEntidades.count, label: "visíveis")
                metricPill(value: entidades.count, label: "no total")
            }
        }
    }

    private func metricPill(value: Int, label: String) -> some View {
        HStack(spacing: 6) {
            Text("\(value)")
                .font(.headline)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.75))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }

    private var loadingSection: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.white)
            Text("Buscando entidades do Aquário...")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func errorSection(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 34))
                .foregroundColor(.white)
            Text("Não foi possível carregar as entidades")
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.75))
                .multilineTextAlignment(.center)
            Button("Tentar Novamente") {
                Task { await loadEntidades(force: true) }
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var emptySection: some View {
        VStack(spacing: 14) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 34))
                .foregroundColor(.white)
            Text("Nenhuma entidade encontrada")
                .font(.headline)
                .foregroundColor(.white)
            Text("Tente outro filtro ou pesquise por um nome diferente.")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.75))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func openDetail(_ entidade: Entidade) {
        selectedEntidade = entidade
    }

    private func loadEntidades(force: Bool) async {
        if !force {
            let cached = StorageProvider.shared.getCachedEntidades()
            if !cached.isEmpty {
                self.entidades = cached
            }
        }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await NetworkManager.shared.fetchEntidades()
            self.entidades = fetched
        } catch {
            errorMessage = error.localizedDescription
            if entidades.isEmpty {
                let cached = StorageProvider.shared.getCachedEntidades()
                self.entidades = cached
            }
        }

        isLoading = false
    }
}

struct EntidadeSection: View {
    let title: String
    let entities: [Entidade]
    let onTap: (Entidade) -> Void

    var body: some View {
        if !entities.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 14) {
                    ForEach(entities) { entidade in
                        EntidadeCard(entidade: entidade)
                            .onTapGesture {
                                onTap(entidade)
                            }
                    }
                }
            }
        }
    }
}

struct EntidadeCard: View {
    let entidade: Entidade

    var body: some View {
        HStack(spacing: 16) {
            EntidadeArtworkView(imagePath: entidade.urlFoto, title: entidade.nome, iconName: iconName)
                .frame(width: 84, height: 84)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text(entidade.nome)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(badgeText)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.20, green: 0.34, blue: 0.49))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.93, green: 0.96, blue: 0.99))
                        .clipShape(Capsule())
                }

                if let description = entidade.descricao ?? entidade.subtitle {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
                        .lineLimit(2)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private var badgeText: String {
        switch entidade.tipo {
        case .laboratorio: return "LAB"
        case .grupo: return "GRUPO"
        case .ligaAcademica: return "LIGA"
        case .centroAcademico: return "CA"
        case .atletica: return "ATLETICA"
        case .empresa: return "EMPRESA"
        case .outro: return "OUTRO"
        }
    }

    private var iconName: String {
        switch entidade.tipo {
        case .laboratorio: return "desktopcomputer"
        case .grupo: return "person.3.fill"
        case .ligaAcademica: return "flag.2.crossed.fill"
        case .empresa: return "briefcase.fill"
        case .atletica: return "sportscourt.fill"
        case .centroAcademico: return "building.columns.fill"
        case .outro: return "sparkles"
        }
    }
}

struct EntidadeArtworkView: View {
    let imagePath: String?
    let title: String
    let iconName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.91, green: 0.97, blue: 0.99),
                            Color.white
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let imageURL = resolveImageURL(imagePath) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                    case .failure, .empty:
                        fallback
                    @unknown default:
                        fallback
                    }
                }
            } else {
                fallback
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var fallback: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(Color(red: 0.06, green: 0.37, blue: 0.57))
            Text(String(title.prefix(2)).uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.22, green: 0.34, blue: 0.48))
        }
    }

    private func resolveImageURL(_ urlString: String?) -> URL? {
        guard let urlString, !urlString.isEmpty else { return nil }
        if urlString.hasPrefix("http") {
            return URL(string: urlString)
        }
        if urlString.hasPrefix("/") {
            return URL(string: "https://aquarioufpb.com" + urlString)
        }
        return URL(string: "https://aquarioufpb.com/" + urlString)
    }
}

struct EntidadeDetailView: View {
    let entidade: Entidade
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.04, green: 0.17, blue: 0.32),
                                        Color(red: 0.07, green: 0.43, blue: 0.61)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 220)

                        HStack(alignment: .bottom, spacing: 18) {
                            EntidadeArtworkView(imagePath: entidade.urlFoto, title: entidade.nome, iconName: "building.2.fill")
                                .frame(width: 96, height: 96)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(entidade.tipo.displayName)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.18))
                                    .clipShape(Capsule())

                                Text(entidade.nome)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                if let subtitle = entidade.subtitle {
                                    Text(subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(Color.white.opacity(0.78))
                                }
                            }
                        }
                        .padding(22)
                    }

                    detailsCard

                    if let descricao = entidade.descricao, !descricao.isEmpty {
                        infoCard(title: "Sobre a Entidade") {
                            Text(descricao)
                                .font(.body)
                                .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
                        }
                    }

                    linksCard
                }
                .padding(20)
            }
            .background(Color(red: 0.95, green: 0.98, blue: 1.0).ignoresSafeArea())
            .navigationTitle("Entidade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private var detailsCard: some View {
        infoCard(title: "Informações") {
            VStack(spacing: 14) {
                if let location = entidade.location, !location.isEmpty {
                    DetailRow(icon: "mappin.and.ellipse", label: "Localização", value: location)
                }
                if let contato = entidade.contato, !contato.isEmpty {
                    DetailRow(icon: "envelope.fill", label: "Contato", value: contato)
                }
                if let website = entidade.website, !website.isEmpty {
                    DetailRow(icon: "link", label: "Website", value: website)
                }
            }
        }
    }

    private var linksCard: some View {
        infoCard(title: "Links e Redes") {
            VStack(alignment: .leading, spacing: 12) {
                if let website = entidade.website, let url = URL(string: website) {
                    SocialButton(title: "Website", icon: "safari.fill", color: Color(red: 0.07, green: 0.39, blue: 0.65), url: url)
                }
                if let instagram = entidade.instagram, let url = URL(string: instagram) {
                    SocialButton(title: "Instagram", icon: "camera.fill", color: .pink, url: url)
                }
                if let linkedin = entidade.linkedin, let url = URL(string: linkedin) {
                    SocialButton(title: "LinkedIn", icon: "person.2.fill", color: .indigo, url: url)
                }
            }
        }
    }

    private func infoCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
            content()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 10)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.06, green: 0.37, blue: 0.57))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.20, green: 0.34, blue: 0.49))
            }
            Spacer()
        }
    }
}

struct SocialButton: View {
    let title: String
    let icon: String
    let color: Color
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
