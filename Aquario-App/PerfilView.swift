import SwiftUI
import PhotosUI
import UIKit

public struct PerfilView: View {
    @Binding var isAuthenticated: Bool
    @State private var user: Usuario? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var progressPercent: Double = 0.38
    @State private var completedSubjectsCount = 14
    @State private var totalSubjectsCount = 38
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var customAvatarData: Data? = nil
    @State private var linkedEntidade: Entidade? = nil
    @State private var entidades: [Entidade] = []
    @State private var isLoadingEntidades = false
    @State private var showEntidadeSheet = false

    public init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.10, blue: 0.22),
                        Color(red: 0.05, green: 0.18, blue: 0.34),
                        Color(red: 0.84, green: 0.95, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        if let user {
                            profileHero(user)
                            profileActionsCard
                            linkedEntidadeCard
                            accountInfoCard(user)
                            progressCard
                            logoutButton
                        } else if isLoading {
                            loadingState
                        } else if let errorMessage {
                            errorState(message: errorMessage)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Meu Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                customAvatarData = StorageProvider.shared.getProfileAvatarData()
                linkedEntidade = StorageProvider.shared.getSelectedEntidade()
                await loadProfile()
                await loadEntidadesIfNeeded()
            }
            .onChange(of: selectedPhotoItem) { newItem in
                guard let newItem else { return }
                Task {
                    await loadAvatar(from: newItem)
                }
            }
            .sheet(isPresented: $showEntidadeSheet) {
                EntidadePickerSheet(
                    entidades: entidades,
                    isLoading: isLoadingEntidades,
                    selectedEntidadeId: linkedEntidade?.id,
                    onReload: {
                        Task { await loadEntidades(forceReload: true) }
                    },
                    onSelect: { entidade in
                        linkedEntidade = entidade
                        StorageProvider.shared.saveSelectedEntidade(entidade)
                        showEntidadeSheet = false
                    },
                    onClear: {
                        linkedEntidade = nil
                        StorageProvider.shared.clearSelectedEntidade()
                        showEntidadeSheet = false
                    }
                )
            }
        }
    }

    private func profileHero(_ user: Usuario) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    profilePhoto(for: user)

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Trocar avatar", systemImage: "camera.fill")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(user.nome)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.82))
                    }

                    HStack(spacing: 8) {
                        if let cursoNome = user.curso?.nome {
                            profilePill(cursoNome)
                        }
                        if let centro = user.centro?.sigla {
                            profilePill(centro)
                        }
                    }
                }

                Spacer()
            }

            HStack(spacing: 12) {
                profileStat(title: "Matrícula", value: user.matricula ?? "Não informado")
                profileStat(title: "Período", value: user.periodoAtual ?? "1º Período")
            }

            HStack(spacing: 10) {
                Image("AquarioLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)

                Text(user.eVerificado ? "Conta verificada no Aquário" : "Conta aguardando verificação")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.84))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.17, blue: 0.32),
                    Color(red: 0.07, green: 0.43, blue: 0.61)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func profilePhoto(for user: Usuario) -> some View {
        ZStack(alignment: .bottomTrailing) {
            if let customAvatarData, let image = UIImage(data: customAvatarData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 108, height: 108)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.30), lineWidth: 3))
            } else if let url = resolvedURL(from: user.urlFotoPerfil) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        initialsView(user.nome)
                    @unknown default:
                        initialsView(user.nome)
                    }
                }
                .frame(width: 108, height: 108)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.30), lineWidth: 3))
            } else {
                initialsView(user.nome)
                    .frame(width: 108, height: 108)
            }

            Image(systemName: "camera.fill")
                .font(.caption.weight(.bold))
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
        }
    }

    private var profileActionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ações do perfil")
                .font(.headline)
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))

            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    actionPill(icon: "person.crop.circle.badge.plus", title: "Trocar avatar")
                }

                Button(action: {
                    showEntidadeSheet = true
                }) {
                    actionPill(icon: "building.2.crop.circle", title: linkedEntidade == nil ? "Inserir entidade" : "Editar entidade")
                }
            }

            Button(action: {
                Task {
                    await loadProfile()
                    await loadEntidadesIfNeeded()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Atualizar dados da conta")
                    Spacer()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
                .padding(14)
                .background(Color(red: 0.93, green: 0.97, blue: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 12)
    }

    private var linkedEntidadeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Minha Entidade")
                .font(.headline)
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))

            if let linkedEntidade {
                HStack(spacing: 14) {
                    EntidadeMiniArtwork(imagePath: linkedEntidade.urlFoto, title: linkedEntidade.nome)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(linkedEntidade.nome)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))

                        Text(linkedEntidade.tipo.displayName)
                            .font(.caption)
                            .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))

                        if let subtitle = linkedEntidade.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
                        }
                    }

                    Spacer()
                }
            } else {
                Text("Selecione a entidade com a qual você participa para deixar o perfil mais completo no app.")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 12)
    }

    private func accountInfoCard(_ user: Usuario) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Dados da conta")
                .font(.headline)
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))

            VStack(spacing: 12) {
                infoRow(label: "Nome", value: user.nome)
                infoRow(label: "Email", value: user.email ?? "Não informado")
                infoRow(label: "Curso", value: user.curso?.nome ?? "Não informado")
                infoRow(label: "Centro", value: user.centro?.nome ?? "Não informado")
                infoRow(label: "Status", value: user.eVerificado ? "Verificado" : "Pendente")
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 12)
    }

    private func actionPill(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .lineLimit(1)
            Spacer()
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(.white)
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.50, blue: 0.80),
                    Color(red: 0.26, green: 0.82, blue: 0.91)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
                .frame(width: 72, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))

            Spacer()
        }
    }

    private func profilePill(_ value: String) -> some View {
        Text(value)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.14))
            .clipShape(Capsule())
    }

    private func profileStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundColor(Color.white.opacity(0.68))
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progresso da Grade Curricular")
                .font(.headline)
                .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.82, green: 0.90, blue: 0.97), lineWidth: 10)
                        .frame(width: 88, height: 88)

                    Circle()
                        .trim(from: 0, to: CGFloat(progressPercent))
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.50, blue: 0.80),
                                    Color(red: 0.26, green: 0.82, blue: 0.91)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progressPercent * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Disciplinas concluídas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(completedSubjectsCount) de \(totalSubjectsCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
                    Text("Acompanhe seu avanço por disciplina e por período.")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
                }
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 12)
    }

    private var logoutButton: some View {
        Button(action: handleLogout) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sair da Conta")
                Spacer()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(18)
            .background(Color(red: 0.78, green: 0.18, blue: 0.22))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var loadingState: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(.white)
            Text("Carregando perfil...")
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 46))
                .foregroundColor(.white)
            Text("Não foi possível carregar o perfil")
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.80))
                .multilineTextAlignment(.center)
            Button(action: {
                Task {
                    await loadProfile()
                    await loadEntidadesIfNeeded()
                }
            }) {
                Label("Tentar Novamente", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func loadProfile() async {
        if user == nil, let cached = StorageProvider.shared.getCachedUser() {
            self.user = cached
        }

        isLoading = user == nil
        errorMessage = nil

        do {
            let fresh = try await NetworkManager.shared.fetchMe()
            self.user = fresh
            StorageProvider.shared.saveUser(fresh)
        } catch {
            if self.user == nil {
                self.errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    private func loadEntidadesIfNeeded() async {
        if entidades.isEmpty {
            await loadEntidades(forceReload: false)
        }
    }

    private func loadEntidades(forceReload: Bool) async {
        if !forceReload {
            let cached = StorageProvider.shared.getCachedEntidades()
            if entidades.isEmpty, !cached.isEmpty {
                entidades = cached
            }
        }

        isLoadingEntidades = true
        defer { isLoadingEntidades = false }

        do {
            entidades = try await NetworkManager.shared.fetchEntidades()
        } catch {
            if entidades.isEmpty {
                entidades = StorageProvider.shared.getCachedEntidades()
            }
        }
    }

    private func loadAvatar(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    customAvatarData = data
                    StorageProvider.shared.saveProfileAvatarData(data)
                }
            }
        } catch {
            print("Erro ao carregar avatar local: \(error)")
        }
    }

    @ViewBuilder
    private func initialsView(_ name: String) -> some View {
        Text(name.prefix(2).uppercased())
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 108, height: 108)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.50, blue: 0.80),
                        Color(red: 0.26, green: 0.82, blue: 0.91)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Circle())
    }

    private func resolvedURL(from urlString: String?) -> URL? {
        guard let urlString, !urlString.isEmpty else { return nil }
        if urlString.hasPrefix("http") {
            return URL(string: urlString)
        }
        if urlString.hasPrefix("/") {
            return URL(string: "https://aquarioufpb.com" + urlString)
        }
        return URL(string: "https://aquarioufpb.com/" + urlString)
    }

    private func handleLogout() {
        NetworkManager.shared.logout()
        isAuthenticated = false
    }
}

private struct EntidadeMiniArtwork: View {
    let imagePath: String?
    let title: String

    var body: some View {
        Group {
            if let imageURL = resolvedURL(from: imagePath) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
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
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [Color.cyan, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(title.prefix(1).uppercased())
                .font(.headline.bold())
                .foregroundColor(.white)
        }
    }

    private func resolvedURL(from urlString: String?) -> URL? {
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

private struct EntidadePickerSheet: View {
    let entidades: [Entidade]
    let isLoading: Bool
    let selectedEntidadeId: String?
    let onReload: () -> Void
    let onSelect: (Entidade) -> Void
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredEntidades: [Entidade] {
        guard !searchText.isEmpty else { return entidades }
        return entidades.filter {
            $0.nome.localizedCaseInsensitiveContains(searchText) ||
            ($0.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Buscar entidade...", text: $searchText)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding()

                if isLoading && entidades.isEmpty {
                    Spacer()
                    ProgressView("Carregando entidades...")
                    Spacer()
                } else {
                    List(filteredEntidades) { entidade in
                        Button(action: {
                            onSelect(entidade)
                        }) {
                            HStack(spacing: 12) {
                                EntidadeMiniArtwork(imagePath: entidade.urlFoto, title: entidade.nome)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entidade.nome)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Text(entidade.tipo.displayName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if selectedEntidadeId == entidade.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Selecionar Entidade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpar") {
                        onClear()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onReload) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView(isAuthenticated: .constant(true))
    }
}
