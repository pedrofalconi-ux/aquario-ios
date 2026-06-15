import SwiftUI
import WebKit

// MARK: - Resource Model
struct RecursoItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemIcon: String
    let accentSymbol: String
    let gradientColors: [Color]
    let destination: ResourceDestination
}

enum ResourceDestination {
    case native
    case web(path: String)
    case external(url: String)
}

private enum GradesDisplayMode: String, CaseIterable {
    case lista = "Lista"
    case grafo = "Grafo"
}

public struct RecursosView: View {
    @State private var selectedTab: String? = nil
    
    // Grid configuration for premium dashboard
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private let recursos = [
        RecursoItem(id: "disciplinas", title: "Minhas Disciplinas", description: "Acompanhe turmas, horários e organização do semestre.", systemIcon: "calendar", accentSymbol: "square.grid.3x3.fill", gradientColors: [.blue, .purple], destination: .web(path: "/calendario")),
        RecursoItem(id: "mapas", title: "Mapas dos Prédios", description: "Consulte salas, andares e laboratórios com o mapa oficial.", systemIcon: "map.fill", accentSymbol: "building.2.crop.circle", gradientColors: [.green, .emerald], destination: .web(path: "/mapas")),
        RecursoItem(id: "grades", title: "Grades Curriculares", description: "Veja o grafo do curso, pré-requisitos e períodos.", systemIcon: "point.3.filled.connected.trianglepath.dotted", accentSymbol: "point.topleft.down.curvedto.point.bottomright.up", gradientColors: [.purple, .indigo], destination: .native),
        RecursoItem(id: "calendario-academico", title: "Calendário Acadêmico", description: "Confira matrículas, feriados, exames e datas importantes.", systemIcon: "calendar.badge.clock", accentSymbol: "calendar.day.timeline.left", gradientColors: [.pink, .red], destination: .native),
        RecursoItem(id: "guias", title: "Guias e Recursos", description: "Consulte os guias oficiais do seu curso com leitura nativa e completa.", systemIcon: "book.closed.fill", accentSymbol: "books.vertical.fill", gradientColors: [.cyan, .blue], destination: .native),
        RecursoItem(id: "sigaa", title: "SIGAA Caiu?", description: "Verifique o status do portal acadêmico em tempo real.", systemIcon: "wifi.router.fill", accentSymbol: "wave.3.right.circle.fill", gradientColors: [.teal, .cyan], destination: .external(url: "https://sigaacaiu.com"))
    ]
    
    private var activeSheetBinding: Binding<ActiveSheet?> {
        Binding<ActiveSheet?>(
            get: {
                guard let tab = selectedTab, tab != "sigaa" else { return nil }
                return ActiveSheet(id: tab)
            },
            set: { active in
                selectedTab = active?.id
            }
        )
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.10, blue: 0.22),
                        Color(red: 0.05, green: 0.18, blue: 0.34),
                        Color(red: 0.78, green: 0.92, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 220, height: 220)
                        .offset(x: 130, y: -260)

                    Circle()
                        .fill(Color.cyan.opacity(0.16))
                        .frame(width: 160, height: 160)
                        .offset(x: -150, y: -90)

                    RoundedRectangle(cornerRadius: 120, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 280, height: 120)
                        .rotationEffect(.degrees(-14))
                        .offset(x: -40, y: 240)
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        heroSection

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(recursos) { recurso in
                                Button(action: {
                                    handleRecursoTap(recurso.id)
                                }) {
                                    RecursoCard(recurso: recurso)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Atalhos do semestre")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Use recursos nativos sempre que possível e abra o site apenas nos fluxos que ainda dependem da versão web.")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.86))
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Explorar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            // Sheet presentation for sub-views
            .sheet(item: activeSheetBinding) { sheet in
                switch sheet.id {
                case "disciplinas":
                    EmbeddedResourceView(title: "Minhas Disciplinas", url: URL(string: "https://aquarioufpb.com/calendario")!)
                case "mapas":
                    EmbeddedResourceView(title: "Mapas dos Prédios", url: URL(string: "https://aquarioufpb.com/mapas")!)
                case "grades":
                    GradesView()
                case "calendario-academico":
                    CalendarioView()
                case "guias":
                    GuiasHubView()
                default:
                    EmptyView()
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recursos")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Encontre horários, mapas, grades, datas acadêmicas e os guias oficiais do CI em um só lugar.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.90))
                }

                Spacer(minLength: 12)

                Image("AquarioLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 62, height: 62)
                    .padding(12)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            HStack(spacing: 10) {
                heroBadge(icon: "checkmark.seal.fill", text: "Recursos reais")
                heroBadge(icon: "iphone.gen3", text: "Mais nativo")
            }
        }
        .padding(22)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func heroBadge(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }
    
    private func handleRecursoTap(_ id: String) {
        guard let recurso = recursos.first(where: { $0.id == id }) else { return }

        switch recurso.destination {
        case .external(let urlString):
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        case .native, .web:
            selectedTab = id
        }
    }
}

// Wrapper for SwiftUI Sheet presentation matching Identifiable
struct ActiveSheet: Identifiable {
    let id: String
}

struct RecursoCard: View {
    let recurso: RecursoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: recurso.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: recurso.systemIcon)
                        .foregroundColor(.white)
                        .font(.title3)
                }

                Spacer()

                Image(systemName: recurso.accentSymbol)
                    .font(.system(size: 34))
                    .foregroundColor(recurso.gradientColors.last?.opacity(0.22) ?? Color.black.opacity(0.08))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(recurso.title)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
                    .multilineTextAlignment(.leading)

                Text(recurso.description)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }

            Text(statusLabel)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(recurso.gradientColors.first ?? .blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background((recurso.gradientColors.first ?? .blue).opacity(0.10))
                .clipShape(Capsule())

            Spacer(minLength: 8)

            HStack(spacing: 6) {
                ForEach(Array(recurso.gradientColors.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color.opacity(0.9))
                        .frame(width: 8, height: 8)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(Color(red: 0.05, green: 0.50, blue: 0.80))
                    .font(.caption.weight(.bold))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 12)
    }

    private var statusLabel: String {
        switch recurso.destination {
        case .native:
            return "Integrado"
        case .web:
            return "Ao vivo"
        case .external:
            return "Tempo real"
        }
    }
}

// Custom Colors helper
extension Color {
    static let emerald = Color(red: 0.06, green: 0.73, blue: 0.45)
}

final class WebResourceState: ObservableObject {
    @Published var isLoading = true
    @Published var canGoBack = false
    @Published var canGoForward = false
    fileprivate weak var webView: WKWebView?

    func reload() {
        webView?.reload()
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }
}

struct EmbeddedResourceView: View {
    let title: String
    let url: URL

    @Environment(\.dismiss) private var dismiss
    @StateObject private var state = WebResourceState()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.10, blue: 0.18)
                    .ignoresSafeArea()

                ResourceWebView(url: url, state: state)
                    .overlay(alignment: .top) {
                        if state.isLoading {
                            ProgressView("Carregando...")
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.65))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .padding(.top, 12)
                        }
                    }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: state.goBack) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(!state.canGoBack)

                    Button(action: state.goForward) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(!state.canGoForward)

                    Spacer()

                    Button(action: state.reload) {
                        Image(systemName: "arrow.clockwise")
                    }

                    Link(destination: url) {
                        Image(systemName: "safari")
                    }
                }
            }
        }
    }
}

struct ResourceWebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var state: WebResourceState

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.load(URLRequest(url: url))
        state.webView = webView
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            webView.load(URLRequest(url: url))
        }
        state.webView = webView
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let state: WebResourceState

        init(state: WebResourceState) {
            self.state = state
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            state.isLoading = true
            updateState(for: webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            state.isLoading = false
            updateState(for: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            state.isLoading = false
            updateState(for: webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            state.isLoading = false
            updateState(for: webView)
        }

        private func updateState(for webView: WKWebView) {
            state.canGoBack = webView.canGoBack
            state.canGoForward = webView.canGoForward
        }
    }
}


// MARK: - Sub-View 2: Minhas Disciplinas
struct DisciplinasView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    struct GradeHoraria: Identifiable {
        let id = UUID()
        let cod: String
        let nome: String
        let hora: String
        let dias: String
        let sala: String
    }
    
    let minhasMaterias = [
        GradeHoraria(cod: "CI101", nome: "Estruturas de Dados", hora: "08:00 - 10:00", dias: "Segunda, Quarta", sala: "Lavid 1"),
        GradeHoraria(cod: "CI102", nome: "Cálculo Diferencial I", hora: "10:00 - 12:00", dias: "Segunda, Quarta", sala: "Auditório CI"),
        GradeHoraria(cod: "CI105", nome: "Introdução à IA", hora: "14:00 - 16:00", dias: "Terça, Quinta", sala: "Sala 204")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar por código, nome ou professor...", text: $searchText)
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding()
                
                List {
                    Section(header: Text("Minha Grade Horária")) {
                        ForEach(minhasMaterias) { materia in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(materia.nome)
                                        .font(.headline)
                                    Spacer()
                                    Text(materia.cod)
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                
                                HStack {
                                    Label(materia.dias, systemImage: "calendar")
                                    Spacer()
                                    Label(materia.hora, systemImage: "clock")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                                Label("Sala: \(materia.sala)", systemImage: "mappin.and.ellipse")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Minhas Disciplinas")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Sub-View 3: Mapas dos Prédios
struct MapasView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedFloor = 0
    
    let roomsByFloor = [
        // Térreo
        ["Lab 101 - Lavid", "Lab 102 - Aria", "Secretaria de Departamento", "Auditório Principal", "Copa dos Alunos"],
        // 1º Andar
        ["Sala de Aula 103", "Sala de Aula 104", "Laboratório de Hardware", "Sala dos Professores", "Diretoria do CI"],
        // 2º Andar
        ["Sala de Aula 201", "Sala de Aula 202", "Sala de Aula 204", "Laboratório de Redes", "Biblioteca Setorial"]
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Andar", selection: $selectedFloor) {
                    Text("Térreo").tag(0)
                    Text("1º Andar").tag(1)
                    Text("2º Andar").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Map Graphic simulation
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                        
                        VStack(spacing: 8) {
                            Text("Planta Esquemática do CI")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .bold()
                            
                            // Visual Layout Representation
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(Color.cyan.opacity(0.2))
                                    .frame(width: 80, height: 60)
                                    .cornerRadius(6)
                                    .overlay(Text("Ala Sul").font(.caption2).bold())
                                
                                Rectangle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 100, height: 60)
                                    .cornerRadius(6)
                                    .overlay(Text("Corredor").font(.caption2).bold())
                                
                                Rectangle()
                                    .fill(Color.emerald.opacity(0.2))
                                    .frame(width: 80, height: 60)
                                    .cornerRadius(6)
                                    .overlay(Text("Ala Norte").font(.caption2).bold())
                            }
                            .padding()
                        }
                    }
                    .frame(height: 150)
                    .padding(.horizontal)
                }
                
                List {
                    Section(header: Text("Locais no Andar")) {
                        ForEach(roomsByFloor[selectedFloor], id: \.self) { room in
                            Label(room, systemImage: "door.left.hand.closed")
                                .padding(.vertical, 2)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Mapas dos Prédios")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Sub-View 4: Grades Curriculares
struct GradesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var cursos: [Curso] = []
    @State private var selectedCursoId = ""
    @State private var grade: GradeCurricularResponse? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Graph Highlight state
    @State private var selectedCode: String? = nil
    @State private var prereqCodes: Set<String> = []
    @State private var dependentCodes: Set<String> = []
    
    // Detail sheet for clicked discipline
    @State private var selectedNode: GradeDisciplinaNode? = nil
    @State private var showOptativas = true
    @State private var displayMode: GradesDisplayMode = .lista
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background dark blue matching app theme
                Color(red: 0.08, green: 0.12, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Toolbar controls
                    VStack(alignment: .leading, spacing: 12) {
                        // Course selector
                        HStack {
                            Text("Curso:")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.74))
                            
                            Menu {
                                ForEach(cursos) { curso in
                                    Button(action: {
                                        selectedCursoId = curso.id
                                        loadGrade(for: curso.id)
                                    }) {
                                        HStack {
                                            Text(curso.nome)
                                            if selectedCursoId == curso.id {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCursoNome)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.72))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                            
                            // Optativas Toggle
                            Toggle(isOn: $showOptativas) {
                                Text("Optativas")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.92))
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .fixedSize()
                        }

                        if horizontalSizeClass == .compact {
                            Picker("Modo", selection: $displayMode) {
                                ForEach(GradesDisplayMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Interactive Graph Legend
                        HStack(spacing: 12) {
                            legendItem(color: .blue, text: "Selecionada")
                            legendItem(color: .orange, text: "Pré-requisito")
                            legendItem(color: .green, text: "Libera")
                        }
                        .font(.caption2)
                    }
                    .padding()
                    .background(Color(red: 0.05, green: 0.08, blue: 0.15))
                    
                    // Main Grid or Status
                    Group {
                        if isLoading {
                            Spacer()
                            ProgressView("Carregando grade...")
                                .tint(.white)
                                .foregroundColor(.white)
                            Spacer()
                        } else if let error = errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.yellow)
                                Text("Erro ao carregar grade")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.74))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Button("Tentar Novamente") {
                                    if !selectedCursoId.isEmpty {
                                        loadGrade(for: selectedCursoId)
                                    } else {
                                        loadCursos()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                            .frame(maxHeight: .infinity)
                        } else if let gradeData = grade {
                            gradeContent(gradeData)
                        } else {
                            VStack {
                                Text("Selecione um curso para visualizar a grade.")
                                    .foregroundColor(Color.white.opacity(0.74))
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Grade Curricular")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .onAppear(perform: initializeView)
            .sheet(item: $selectedNode) { node in
                DisciplineDetailSheet(node: node, allNodes: grade?.disciplinas ?? [])
            }
        }
    }
    
    private var selectedCursoNome: String {
        cursos.first(where: { $0.id == selectedCursoId })?.nome ?? "Selecione o curso"
    }

    @ViewBuilder
    private func gradeContent(_ gradeData: GradeCurricularResponse) -> some View {
        if horizontalSizeClass == .compact && displayMode == .lista {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(groupedDisciplines(gradeData.disciplinas), id: \.key) { period, list in
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(period)º Período")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                ForEach(list) { node in
                                    disciplineListCard(node, allNodes: gradeData.disciplinas)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                .padding()
            }
        } else {
            let periods = groupedDisciplines(gradeData.disciplinas)

            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(periods, id: \.key) { key, list in
                        VStack(spacing: 12) {
                            Text("\(key)º Período")
                                .font(.caption)
                                .bold()
                                .foregroundColor(Color.white.opacity(0.78))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(6)

                            ForEach(list) { node in
                                disciplineCard(node, allNodes: gradeData.disciplinas)
                            }

                            Spacer()
                        }
                        .frame(width: 140)
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    @ViewBuilder
    private func disciplineCard(_ node: GradeDisciplinaNode, allNodes: [GradeDisciplinaNode]) -> some View {
        let isSelected = selectedCode == node.codigo
        let isPrereq = prereqCodes.contains(node.codigo)
        let isDep = dependentCodes.contains(node.codigo)
        let hasActiveSelection = selectedCode != nil
        
        let inChain = isSelected || isPrereq || isDep
        let opacity = (!hasActiveSelection || inChain) ? 1.0 : 0.25
        
        let backgroundColor: Color = {
            if isSelected {
                return .blue
            } else if isPrereq {
                return .orange
            } else if isDep {
                return .green
            } else {
                return Color.white.opacity(0.06)
            }
        }()
        
        let borderColor: Color = {
            if isSelected {
                return .cyan
            } else if isPrereq {
                return .red
            } else if isDep {
                return .emerald
            } else {
                return Color.white.opacity(0.15)
            }
        }()
        
        Button(action: {
            handleNodeTap(node, allNodes: allNodes)
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(node.codigo)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)
                    Spacer()
                    Circle()
                        .fill(node.natureza == "OBRIGATORIA" ? Color.blue : Color.orange)
                        .frame(width: 6, height: 6)
                }
                
                Text(node.nome)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("\(node.cargaHorariaTotal ?? 0)h")
                        .font(.system(size: 9))
                        .foregroundColor(Color.white.opacity(0.72))
                    Spacer()
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.72))
                        .onTapGesture {
                            selectedNode = node
                        }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
            .background(backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .opacity(opacity)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func disciplineListCard(_ node: GradeDisciplinaNode, allNodes: [GradeDisciplinaNode]) -> some View {
        let isSelected = selectedCode == node.codigo
        let isPrereq = prereqCodes.contains(node.codigo)
        let isDep = dependentCodes.contains(node.codigo)

        let statusColor: Color = {
            if isSelected { return .blue }
            if isPrereq { return .orange }
            if isDep { return .green }
            return Color.white.opacity(0.08)
        }()

        Button(action: {
            handleNodeTap(node, allNodes: allNodes)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(node.nome)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)

                        Text(node.codigo)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.cyan)
                    }

                    Spacer()

                    Button(action: {
                        selectedNode = node
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.white.opacity(0.78))
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    Label("\(node.cargaHorariaTotal ?? 0)h", systemImage: "clock")
                    Spacer()
                    Text(node.natureza == "OBRIGATORIA" ? "Obrigatória" : "Optativa")
                }
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.74))

                if !node.preRequisitos.isEmpty {
                    Text("Pré-requisitos: \(node.preRequisitos.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.70))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(statusColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? Color.cyan : isPrereq ? Color.orange : isDep ? Color.green : Color.white.opacity(0.12),
                        lineWidth: 1.4
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func handleNodeTap(_ node: GradeDisciplinaNode, allNodes: [GradeDisciplinaNode]) {
        if selectedCode == node.codigo {
            selectedCode = nil
            prereqCodes.removeAll()
            dependentCodes.removeAll()
        } else {
            selectedCode = node.codigo
            
            let codeToNode = Dictionary(uniqueKeysWithValues: allNodes.map { ($0.codigo, $0) })
            
            var prereqs = Set<String>()
            func walkUp(_ c: String) {
                guard let n = codeToNode[c] else { return }
                for req in n.preRequisitos {
                    if !prereqs.contains(req) && codeToNode[req] != nil {
                        prereqs.insert(req)
                        walkUp(req)
                    }
                }
            }
            walkUp(node.codigo)
            prereqCodes = prereqs
            
            var dependents = Set<String>()
            func walkDown(_ c: String) {
                for n in allNodes {
                    if n.preRequisitos.contains(c) && !dependents.contains(n.codigo) {
                        dependents.insert(n.codigo)
                        walkDown(n.codigo)
                    }
                }
            }
            walkDown(node.codigo)
            dependentCodes = dependents
        }
    }
    
    private func groupedDisciplines(_ list: [GradeDisciplinaNode]) -> [(key: Int, value: [GradeDisciplinaNode])] {
        let visible = list.filter { showOptativas || $0.natureza == "OBRIGATORIA" }
        let grouped = Dictionary(grouping: visible, by: { $0.periodo })
        return grouped.sorted(by: { $0.key < $1.key }).map { (key: $0.key, value: $0.value) }
    }
    
    private func initializeView() {
        loadCursos()
        
        if let user = StorageProvider.shared.getCachedUser() {
            if let cursoId = user.cursoId {
                selectedCursoId = cursoId
                loadGrade(for: cursoId)
            } else if let curso = user.curso {
                selectedCursoId = curso.id
                loadGrade(for: curso.id)
            }
        }
    }
    
    private func loadCursos() {
        Task {
            do {
                let fetched = try await NetworkManager.shared.fetchAllCursos()
                await MainActor.run {
                    self.cursos = fetched
                    if self.selectedCursoId.isEmpty, let first = fetched.first {
                        self.selectedCursoId = first.id
                        loadGrade(for: first.id)
                    }
                }
            } catch {
                print("Erro ao carregar cursos: \(error)")
            }
        }
    }
    
    private func loadGrade(for cursoId: String) {
        isLoading = true
        errorMessage = nil
        selectedCode = nil
        prereqCodes.removeAll()
        dependentCodes.removeAll()
        
        Task {
            do {
                let gradeRes = try await NetworkManager.shared.fetchGradeCurricular(cursoId: cursoId)
                await MainActor.run {
                    self.grade = gradeRes
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

struct DisciplineDetailSheet: View {
    let node: GradeDisciplinaNode
    let allNodes: [GradeDisciplinaNode]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.12, blue: 0.2)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(node.codigo)
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.cyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.cyan.opacity(0.15))
                                    .cornerRadius(6)
                                
                                Spacer()
                                
                                Text(node.natureza == "OBRIGATORIA" ? "Obrigatória" : "Optativa")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(node.natureza == "OBRIGATORIA" ? .blue : .orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(node.natureza == "OBRIGATORIA" ? Color.blue.opacity(0.15) : Color.orange.opacity(0.15))
                                    .cornerRadius(6)
                            }
                            
                            Text(node.nome)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            detailRow(label: "Carga Horária Total", value: "\(node.cargaHorariaTotal ?? 0) horas")
                            detailRow(label: "Teórica / Prática", value: "\(node.cargaHorariaTeoria ?? 0)h / \(node.cargaHorariaPratica ?? 0)h")
                            if let dep = node.departamento {
                                detailRow(label: "Departamento", value: dep)
                            }
                            if let mod = node.modalidade {
                                detailRow(label: "Modalidade", value: mod)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                        
                        if let ementa = node.ementa, !ementa.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ementa / Conteúdo")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(ementa)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineSpacing(6)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pré-requisitos")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if node.preRequisitos.isEmpty {
                                    Text("Sem pré-requisitos")
                                        .font(.subheadline)
                                        .foregroundColor(Color.white.opacity(0.72))
                                } else {
                                    ForEach(node.preRequisitos, id: \.self) { reqCode in
                                        HStack {
                                            Image(systemName: "arrow.right.circle.fill")
                                                .foregroundColor(.orange)
                                            Text(reqCode)
                                                .font(.subheadline)
                                                .bold()
                                                .foregroundColor(.white)
                                            if let reqName = resolveNodeName(reqCode) {
                                                Text("- \(reqName)")
                                                    .font(.caption)
                                                    .foregroundColor(Color.white.opacity(0.70))
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Equivalências")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if node.equivalencias.isEmpty {
                                    Text("Sem equivalências cadastradas")
                                        .font(.subheadline)
                                        .foregroundColor(Color.white.opacity(0.72))
                                    } else {
                                        ForEach(node.equivalencias, id: \.self) { eqCode in
                                            HStack {
                                                Image(systemName: "arrow.left.and.right.circle.fill")
                                                    .foregroundColor(.green)
                                                Text(eqCode)
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundColor(.white)
                                                if let eqName = resolveNodeName(eqCode) {
                                                    Text("- \(eqName)")
                                                        .font(.caption)
                                                        .foregroundColor(Color.white.opacity(0.70))
                                                        .lineLimit(1)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                    }
                }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ok") { dismiss() }
                }
            }
        }
    }
    
    private func resolveNodeName(_ code: String) -> String? {
        allNodes.first(where: { $0.codigo == code })?.nome
    }
    
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.72))
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
        }
    }
}

private enum CalendarioModoVisualizacao: String, CaseIterable {
    case lista = "Linha do tempo"
    case calendario = "Calendário"
}

struct CalendarioView: View {
    @Environment(\.dismiss) var dismiss

    @State private var semestres: [SemestreLetivo] = []
    @State private var selectedSemestreId: String = ""
    @State private var semestreDetalhado: SemestreLetivoDetalhado? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var viewMode: CalendarioModoVisualizacao = .lista
    @State private var activeCategory: CategoriaEventoAcademico? = nil
    @State private var displayedMonth: Date = Date()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    private var effectiveSemestreId: String? {
        if !selectedSemestreId.isEmpty {
            return selectedSemestreId
        }
        return semestres.first?.id
    }

    private var filteredEventos: [EventoCalendarioAcademico] {
        let eventos = semestreDetalhado?.eventos ?? []
        guard let activeCategory else { return eventos.sorted { $0.dataInicio < $1.dataInicio } }
        return eventos
            .filter { $0.categoria == activeCategory }
            .sorted { $0.dataInicio < $1.dataInicio }
    }

    private var availableCategories: [CategoriaEventoAcademico] {
        let categories = Set((semestreDetalhado?.eventos ?? []).map(\.categoria))
        return CategoriaEventoAcademico.allCases.filter { categories.contains($0) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.10, blue: 0.22),
                        Color(red: 0.05, green: 0.18, blue: 0.34),
                        Color(red: 0.87, green: 0.95, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        calendarHeader
                        controlsSection

                        if isLoading && semestreDetalhado == nil {
                            calendarLoading
                        } else if let errorMessage, semestreDetalhado == nil {
                            calendarError(message: errorMessage)
                        } else if filteredEventos.isEmpty {
                            calendarEmpty
                        } else if viewMode == .lista {
                            timelineSection
                        } else {
                            monthGridSection
                        }
                    }
                    .padding(20)
                }
                .refreshable {
                    await loadSemestres(forceReload: true)
                }
            }
            .navigationTitle("Calendário Acadêmico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .task {
                await loadSemestres(forceReload: false)
            }
        }
    }

    private var calendarHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calendário Acadêmico")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Consulte datas de matrícula, provas, feriados e marcos do semestre em uma visualização clara.")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.80))
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !semestres.isEmpty {
                Picker("Semestre", selection: Binding(
                    get: { effectiveSemestreId ?? "" },
                    set: { newValue in
                        selectedSemestreId = newValue
                        Task { await loadSemestreDetalhado(id: newValue) }
                    }
                )) {
                    ForEach(semestres) { semestre in
                        Text(semestre.nome).tag(semestre.id)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
            }

            Picker("Visualização", selection: $viewMode) {
                ForEach(CalendarioModoVisualizacao.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    calendarChip(title: "Todos", isActive: activeCategory == nil, color: Color.white.opacity(0.18)) {
                        activeCategory = nil
                    }

                    ForEach(availableCategories, id: \.self) { category in
                        calendarChip(title: category.displayName, isActive: activeCategory == category, color: category.color.opacity(0.90)) {
                            activeCategory = activeCategory == category ? nil : category
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func calendarChip(title: String, isActive: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(isActive ? color : Color.white.opacity(0.10))
                .clipShape(Capsule())
        }
    }

    private var timelineSection: some View {
        let grouped = Dictionary(grouping: filteredEventos) { event in
            monthBucket(for: event.dataInicio)
        }
        let sortedMonths = grouped.keys.sorted()

        return VStack(alignment: .leading, spacing: 18) {
            ForEach(sortedMonths, id: \.self) { key in
                TimelineMonthSection(
                    title: monthSectionFormatter.string(from: key),
                    events: grouped[key] ?? [],
                    dayFormatter: dayFormatter,
                    monthFormatter: monthShortFormatter,
                    rangeFormatter: formattedDateRange
                )
            }
        }
    }

    private var monthGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    shiftMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }

                Spacer()

                Text(monthTitleFormatter.string(from: displayedMonth))
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    shiftMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white.opacity(0.75))
                        .frame(maxWidth: .infinity)
                }

                ForEach(monthCells, id: \.id) { cell in
                    dayCell(cell)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                Text("Eventos no mês")
                    .font(.headline)
                    .foregroundColor(.white)

                ForEach(Array(eventsForDisplayedMonth.prefix(6))) { event in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(event.categoria.color)
                            .frame(width: 10, height: 10)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(event.descricao)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text(formattedDateRange(start: event.dataInicio, end: event.dataFim))
                                .font(.caption)
                                .foregroundColor(Color.white.opacity(0.72))
                        }
                        Spacer()
                    }
                }
            }
            .padding(18)
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private func dayCell(_ cell: CalendarDayCell) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cell.isCurrentMonth ? Color.white : Color.white.opacity(0.35))
                .frame(height: 56)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(cell.dayLabel)
                        .font(.caption)
                        .fontWeight(cell.isToday ? .bold : .medium)
                        .foregroundColor(cell.isCurrentMonth ? Color(red: 0.05, green: 0.20, blue: 0.38) : Color.gray)
                    Spacer()
                }

                if let event = cell.events.first {
                    Capsule()
                        .fill(event.categoria.color)
                        .frame(width: 24, height: 6)
                }
            }
            .padding(8)

            if cell.events.count > 1 {
                Text("\(cell.events.count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color(red: 0.05, green: 0.50, blue: 0.80))
                    .clipShape(Circle())
                    .padding(5)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(cell.isToday ? Color.cyan : Color.clear, lineWidth: 2)
        )
    }

    private var monthCells: [CalendarDayCell] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }

        let calendar = Calendar.current
        let monthStart = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingDays = (firstWeekday + 5) % 7
        let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart) ?? monthStart

        return (0..<42).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: gridStart) else { return nil }
            let events = filteredEventos.filter { isDate(date, within: $0.dataInicio, and: $0.dataFim) }
            return CalendarDayCell(
                id: date.timeIntervalSince1970,
                date: date,
                dayLabel: String(calendar.component(.day, from: date)),
                isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                isToday: calendar.isDateInToday(date),
                events: events
            )
        }
    }

    private var eventsForDisplayedMonth: [EventoCalendarioAcademico] {
        filteredEventos.filter {
            Calendar.current.isDate($0.dataInicio, equalTo: displayedMonth, toGranularity: .month) ||
            Calendar.current.isDate($0.dataFim, equalTo: displayedMonth, toGranularity: .month)
        }
    }

    private var calendarLoading: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)
            Text("Carregando calendário...")
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    private func calendarError(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.white)
            Text("Não foi possível carregar o calendário")
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.80))
                .multilineTextAlignment(.center)
            Button("Tentar Novamente") {
                Task { await loadSemestres(forceReload: true) }
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var calendarEmpty: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundColor(.white)
            Text("Nenhum evento encontrado")
                .font(.headline)
                .foregroundColor(.white)
            Text("Ajuste os filtros ou escolha outro semestre.")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.80))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func loadSemestres(forceReload: Bool) async {
        if forceReload {
            semestreDetalhado = nil
        }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await NetworkManager.shared.fetchSemestresLetivos()
                .sorted { $0.dataInicio < $1.dataInicio }
            semestres = fetched

            if selectedSemestreId.isEmpty {
                selectedSemestreId = fetched.last?.id ?? fetched.first?.id ?? ""
            }

            if let semestreId = effectiveSemestreId, !semestreId.isEmpty {
                await loadSemestreDetalhado(id: semestreId)
            } else {
                isLoading = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func loadSemestreDetalhado(id: String) async {
        guard !id.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await NetworkManager.shared.fetchSemestreLetivo(id: id)
            semestreDetalhado = fetched
            displayedMonth = fetched.dataInicio
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func shiftMonth(by offset: Int) {
        guard let newDate = Calendar.current.date(byAdding: .month, value: offset, to: displayedMonth),
              let semestre = semestreDetalhado else { return }

        let startMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: semestre.dataInicio)) ?? semestre.dataInicio
        let endMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: semestre.dataFim)) ?? semestre.dataFim

        if newDate >= startMonth && newDate <= endMonth {
            displayedMonth = newDate
        }
    }

    private func monthBucket(for date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: components) ?? date
    }

    private func isDate(_ date: Date, within start: Date, and end: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let normalizedStart = calendar.startOfDay(for: start)
        let normalizedEnd = calendar.startOfDay(for: end)
        return normalizedDate >= normalizedStart && normalizedDate <= normalizedEnd
    }

    private func formattedDateRange(start: Date, end: Date) -> String {
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return fullDateFormatter.string(from: start)
        }
        return "\(fullDateFormatter.string(from: start)) - \(fullDateFormatter.string(from: end))"
    }

    private var weekdaySymbols: [String] {
        ["SEG", "TER", "QUA", "QUI", "SEX", "SAB", "DOM"]
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd"
        return formatter
    }

    private var monthShortFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMM"
        return formatter
    }

    private var fullDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM"
        return formatter
    }

    private var monthTitleFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var monthSectionFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

private struct CalendarDayCell: Identifiable {
    let id: TimeInterval
    let date: Date
    let dayLabel: String
    let isCurrentMonth: Bool
    let isToday: Bool
    let events: [EventoCalendarioAcademico]
}

private struct TimelineMonthSection: View {
    let title: String
    let events: [EventoCalendarioAcademico]
    let dayFormatter: DateFormatter
    let monthFormatter: DateFormatter
    let rangeFormatter: (Date, Date) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ForEach(events) { event in
                    TimelineEventCard(
                        event: event,
                        dayText: dayFormatter.string(from: event.dataInicio),
                        monthText: monthFormatter.string(from: event.dataInicio).uppercased(),
                        dateRange: rangeFormatter(event.dataInicio, event.dataFim)
                    )
                }
            }
        }
    }
}

private struct TimelineEventCard: View {
    let event: EventoCalendarioAcademico
    let dayText: String
    let monthText: String
    let dateRange: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 4) {
                Text(dayText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(monthText)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.80))
            }
            .frame(width: 58)
            .padding(.vertical, 10)
            .background(event.categoria.color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(event.descricao)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.05, green: 0.20, blue: 0.38))
                Text(dateRange)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.28, green: 0.39, blue: 0.52))
                Text(event.categoria.displayName)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(event.categoria.color)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 16, x: 0, y: 10)
    }
}

private extension CategoriaEventoAcademico {
    var color: Color {
        switch self {
        case .matriculaIngressantes: return .blue
        case .matriculaVeteranos: return .indigo
        case .rematricula: return .purple
        case .matriculaExtraordinaria: return Color(red: 0.55, green: 0.28, blue: 0.84)
        case .pontoFacultativo: return .yellow
        case .feriado: return .red
        case .examesFinais: return .orange
        case .registroMediasFinais: return Color(red: 0.92, green: 0.72, blue: 0.15)
        case .colacaoDeGrau: return .green
        case .inicioPeriodoLetivo: return Color(red: 0.09, green: 0.63, blue: 0.47)
        case .terminoPeriodoLetivo: return .pink
        case .outra: return .gray
        }
    }
}

// MARK: - Sub-View 6: Guias e Recursos
struct GuideNode: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let sitePath: String
    let repoFilePath: String?
    let assetDirectoryPath: String?
    let children: [GuideNode]

    var hasContent: Bool {
        repoFilePath != nil
    }

    var childrenCount: Int {
        children.count
    }
}

struct GuideSearchResult: Identifiable {
    let node: GuideNode
    let trail: [GuideNode]

    var id: String {
        node.id
    }
}

struct GuideContentBlock: Identifiable {
    enum Kind {
        case markdown(String)
        case image(url: URL, alt: String)
    }

    let id = UUID()
    let kind: Kind
}

enum GuideCatalog {
    static let repositoryBasePath = "centro-de-informatica"

    static let allRoots: [GuideNode] = [
        category(
            id: "bem-vindo",
            title: "Bem Vindo",
            summary: "Comece por aqui com introdução ao CI e dicas práticas para os primeiros períodos.",
            children: [
                leaf("bem-vindo-introducao", "Introdução", "Boas-vindas ao curso e visão geral do que explorar no Centro de Informática.", "guias/bem-vindo/introducao", "\(repositoryBasePath)/0 - Bem Vindo/1 - Introdução.md", assetDirectory: "\(repositoryBasePath)/0 - Bem Vindo"),
                leaf("bem-vindo-dicas", "Dicas", "Orientações para rotina acadêmica, estudo e adaptação ao campus.", "guias/bem-vindo/dicas", "\(repositoryBasePath)/0 - Bem Vindo/2 - Dicas.md", assetDirectory: "\(repositoryBasePath)/0 - Bem Vindo")
            ]
        ),
        category(
            id: "grupos",
            title: "Grupos",
            summary: "Conheça atlética, grupos, ligas, laboratórios e o PET do CI.",
            children: [
                leaf("grupos-atetica", "Atética", "Informações sobre a atlética e participação estudantil.", "guias/grupos/atetica", "\(repositoryBasePath)/1 - Grupos/Atética.md", assetDirectory: "\(repositoryBasePath)/1 - Grupos"),
                leaf("grupos-grupos-e-ligas", "Grupos e Ligas", "Mapa dos grupos acadêmicos e ligas em atividade no CI.", "guias/grupos/grupos-e-ligas", "\(repositoryBasePath)/1 - Grupos/Grupos e Ligas.md", assetDirectory: "\(repositoryBasePath)/1 - Grupos"),
                leaf("grupos-laboratorios", "Laboratórios", "Veja laboratórios e oportunidades de pesquisa do centro.", "guias/grupos/laboratorios", "\(repositoryBasePath)/1 - Grupos/Laboratórios.md", assetDirectory: "\(repositoryBasePath)/1 - Grupos"),
                leaf("grupos-pet", "PET", "Saiba como funciona o PET e como participar.", "guias/grupos/pet", "\(repositoryBasePath)/1 - Grupos/PET.md", assetDirectory: "\(repositoryBasePath)/1 - Grupos")
            ]
        ),
        category(
            id: "informacoes",
            title: "Informações",
            summary: "Consulte bolsas, salas e formas de deslocamento para o CI.",
            children: [
                leaf("informacoes-bolsas", "Bolsas", "Entenda modalidades, oportunidades e caminhos para apoio acadêmico.", "guias/informacoes/bolsas", "\(repositoryBasePath)/2 - Informações/Bolsas.md", assetDirectory: "\(repositoryBasePath)/2 - Informações"),
                leaf("informacoes-salas", "Salas", "Referência rápida sobre salas e uso dos espaços do CI.", "guias/informacoes/salas", "\(repositoryBasePath)/2 - Informações/Salas.md", assetDirectory: "\(repositoryBasePath)/2 - Informações"),
                leaf("informacoes-transporte", "Transporte", "Horários do circular, paradas e dicas para chegar ao campus.", "guias/informacoes/transporte", "\(repositoryBasePath)/2 - Informações/Transporte.md", assetDirectory: "\(repositoryBasePath)/2 - Informações")
            ]
        ),
        category(
            id: "ciencia-da-computacao",
            title: "Ciencia da Computação",
            summary: "Explore curso, coordenação, estrutura curricular e grade de Ciência da Computação.",
            children: [
                leaf("cc-sobre", "Sobre o Curso", "Objetivos, formação e panorama do curso de Ciência da Computação.", "guias/ciencia-da-computacao/sobre-o-curso", "\(repositoryBasePath)/Ciencia da Computação/0 - Sobre o Curso.md", assetDirectory: "\(repositoryBasePath)/Ciencia da Computação"),
                leaf("cc-coordenacao", "Coordenação", "Contatos, funcionamento e orientações da coordenação do curso.", "guias/ciencia-da-computacao/coordenacao", "\(repositoryBasePath)/Ciencia da Computação/Coordenação.md", assetDirectory: "\(repositoryBasePath)/Ciencia da Computação"),
                node(
                    id: "cc-estrutura",
                    title: "Estrutura CC",
                    summary: "Veja a estrutura curricular, atividades extracurriculares e complementares flexíveis.",
                    sitePath: "guias/ciencia-da-computacao/estrutura-cc",
                    repoFilePath: "\(repositoryBasePath)/Ciencia da Computação/Estrutura CC.md",
                    assetDirectoryPath: "\(repositoryBasePath)/Ciencia da Computação",
                    children: [
                        leaf("cc-atividades", "Atividades Extracurriculares", "Descubra formas de enriquecer sua formação além das disciplinas.", "guias/ciencia-da-computacao/estrutura-cc/atividades-extracurriculares", "\(repositoryBasePath)/Ciencia da Computação/Estrutura CC/Atividades Extracurriculares.md", assetDirectory: "\(repositoryBasePath)/Ciencia da Computação/Estrutura CC"),
                        leaf("cc-complementares", "Complementares Flexíveis", "Entenda como cumprir as complementares flexíveis do curso.", "guias/ciencia-da-computacao/estrutura-cc/complementares-flexiveis", "\(repositoryBasePath)/Ciencia da Computação/Estrutura CC/Complementares Flexíveis.md", assetDirectory: "\(repositoryBasePath)/Ciencia da Computação/Estrutura CC")
                    ]
                ),
                leaf("cc-grade", "Grade", "Visualize o fluxograma e a organização da grade do curso.", "guias/ciencia-da-computacao/grade", "\(repositoryBasePath)/Ciencia da Computação/Grade.md", assetDirectory: "\(repositoryBasePath)/Ciencia da Computação")
            ]
        ),
        category(
            id: "ciencia-de-dados-e-inteligencia-artificial",
            title: "Ciencia de Dados e Inteligencia Artificial",
            summary: "Informações do curso de CDIA, com visão geral e coordenação.",
            children: [
                leaf("cdia-sobre", "Sobre o Curso", "Conheça foco, perfil e possibilidades do curso de CDIA.", "guias/ciencia-de-dados-e-inteligencia-artificial/sobre-o-curso", "\(repositoryBasePath)/Ciencia de Dados e Inteligencia Artificial/0 - Sobre o Curso.md", assetDirectory: "\(repositoryBasePath)/Ciencia de Dados e Inteligencia Artificial"),
                leaf("cdia-coordenacao", "Coordenação", "Contatos e orientações da coordenação de CDIA.", "guias/ciencia-de-dados-e-inteligencia-artificial/coordenacao", "\(repositoryBasePath)/Ciencia de Dados e Inteligencia Artificial/Coordenação.md", assetDirectory: "\(repositoryBasePath)/Ciencia de Dados e Inteligencia Artificial")
            ]
        ),
        category(
            id: "engenharia-da-computacao",
            title: "Engenharia da Computação",
            summary: "Consulte curso, coordenação, estrutura e grade de Engenharia da Computação.",
            children: [
                leaf("ec-sobre", "Sobre o Curso", "Panorama do curso e das trilhas formativas de Engenharia da Computação.", "guias/engenharia-da-computacao/sobre-o-curso", "\(repositoryBasePath)/Engenharia da Computação/0 - Sobre o Curso.md", assetDirectory: "\(repositoryBasePath)/Engenharia da Computação"),
                leaf("ec-coordenacao", "Coordenação", "Contatos e orientações da coordenação de Engenharia da Computação.", "guias/engenharia-da-computacao/coordenacao", "\(repositoryBasePath)/Engenharia da Computação/Coordenação.md", assetDirectory: "\(repositoryBasePath)/Engenharia da Computação"),
                node(
                    id: "ec-estrutura",
                    title: "Estrutura EC",
                    summary: "Veja a organização curricular e as atividades complementares do curso.",
                    sitePath: "guias/engenharia-da-computacao/estrutura-ec",
                    repoFilePath: "\(repositoryBasePath)/Engenharia da Computação/Estrutura EC.md",
                    assetDirectoryPath: "\(repositoryBasePath)/Engenharia da Computação",
                    children: [
                        leaf("ec-atividades", "Atividades Extracurriculares", "Conheça experiências que ampliam a formação em EC.", "guias/engenharia-da-computacao/estrutura-ec/atividades-extracurriculares", "\(repositoryBasePath)/Engenharia da Computação/Estrutura EC/Atividades Extracurriculares.md", assetDirectory: "\(repositoryBasePath)/Engenharia da Computação/Estrutura EC"),
                        leaf("ec-complementares", "Complementares Flexíveis", "Entenda as regras e possibilidades das complementares flexíveis de EC.", "guias/engenharia-da-computacao/estrutura-ec/complementares-flexiveis", "\(repositoryBasePath)/Engenharia da Computação/Estrutura EC/Complementares Flexíveis.md", assetDirectory: "\(repositoryBasePath)/Engenharia da Computação/Estrutura EC")
                    ]
                ),
                leaf("ec-grade", "Grade", "Acesse a representação visual da grade de Engenharia da Computação.", "guias/engenharia-da-computacao/grade", "\(repositoryBasePath)/Engenharia da Computação/Grade.md", assetDirectory: "\(repositoryBasePath)/Engenharia da Computação")
            ]
        )
    ]

    static func rawURL(for repoPath: String) -> URL? {
        let encoded = repoPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? repoPath
        return URL(string: "https://raw.githubusercontent.com/aquario-ufpb/aquario-guias/main/\(encoded)")
    }

    static func resolvedAssetURL(relativePath: String, baseDirectory: String?) -> URL? {
        guard let baseDirectory else { return nil }
        let normalized = normalize(relativePath: relativePath, baseDirectory: baseDirectory)
        return rawURL(for: normalized)
    }

    private static func normalize(relativePath: String, baseDirectory: String) -> String {
        var parts = baseDirectory.split(separator: "/").map(String.init)
        for piece in relativePath.split(separator: "/").map(String.init) {
            if piece == "." || piece.isEmpty {
                continue
            } else if piece == ".." {
                if !parts.isEmpty {
                    parts.removeLast()
                }
            } else {
                parts.append(piece)
            }
        }
        return parts.joined(separator: "/")
    }

    private static func category(id: String, title: String, summary: String, children: [GuideNode]) -> GuideNode {
        node(id: id, title: title, summary: summary, sitePath: "guias/\(id)", repoFilePath: nil, assetDirectoryPath: nil, children: children)
    }

    private static func leaf(_ id: String, _ title: String, _ summary: String, _ sitePath: String, _ repoPath: String, assetDirectory: String) -> GuideNode {
        node(id: id, title: title, summary: summary, sitePath: sitePath, repoFilePath: repoPath, assetDirectoryPath: assetDirectory, children: [])
    }

    private static func node(id: String, title: String, summary: String, sitePath: String, repoFilePath: String?, assetDirectoryPath: String?, children: [GuideNode]) -> GuideNode {
        GuideNode(
            id: id,
            title: title,
            summary: summary,
            sitePath: sitePath,
            repoFilePath: repoFilePath,
            assetDirectoryPath: assetDirectoryPath,
            children: children
        )
    }
}

actor GuideContentCache {
    static let shared = GuideContentCache()
    private var cachedMarkdown: [String: String] = [:]

    func markdown(for repoPath: String) async throws -> String {
        if let cached = cachedMarkdown[repoPath] {
            return cached
        }

        guard let url = GuideCatalog.rawURL(for: repoPath) else {
            throw ApiError(message: "Não foi possível montar o endereço do guia.", code: "GUIDE_URL")
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw ApiError(message: "Não foi possível carregar o conteúdo do guia.", code: "GUIDE_HTTP_\(httpResponse.statusCode)")
        }

        guard let markdown = String(data: data, encoding: .utf8) else {
            throw ApiError(message: "Conteúdo do guia em formato inválido.", code: "GUIDE_ENCODING")
        }

        cachedMarkdown[repoPath] = markdown
        return markdown
    }
}

struct GuiasHubView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var searchResults: [GuideSearchResult] {
        let query = normalized(searchText)
        guard !query.isEmpty else { return [] }
        return flattenedNodes(from: GuideCatalog.allRoots)
            .filter { result in
                normalized(result.node.title).contains(query) || normalized(result.node.summary).contains(query)
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.10, blue: 0.22),
                        Color(red: 0.04, green: 0.20, blue: 0.34),
                        Color(red: 0.78, green: 0.92, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        guiasHeader
                        searchSection

                        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(spacing: 14) {
                                ForEach(GuideCatalog.allRoots) { root in
                                    NavigationLink(destination: GuideNodeDetailView(node: root, trail: [root])) {
                                        GuideRootCardView(node: root)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else if searchResults.isEmpty {
                            emptyState
                        } else {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Resultados")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                ForEach(searchResults) { result in
                                    NavigationLink(destination: GuideNodeDetailView(node: result.node, trail: result.trail)) {
                                        GuideSearchCardView(result: result)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Guias")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private var guiasHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bem-vindo aos Guias do Centro de Informática")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Aqui estão todos os tópicos disponíveis para explorar, agora organizados de forma nativa no aplicativo.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.86))
                }

                Spacer(minLength: 12)

                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 54, height: 54)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            HStack(spacing: 10) {
                guidePill(text: "\(GuideCatalog.allRoots.count) áreas", icon: "rectangle.grid.1x2.fill")
                guidePill(text: "\(flattenedNodes(from: GuideCatalog.allRoots).count) tópicos", icon: "text.book.closed.fill")
            }
        }
        .padding(22)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func guidePill(text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }

    private var searchSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.white.opacity(0.72))

            TextField("Buscar guia, curso ou tópico", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.white.opacity(0.72))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Text("Nenhum guia encontrado para essa busca.")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func flattenedNodes(from roots: [GuideNode]) -> [GuideSearchResult] {
        var results: [GuideSearchResult] = []

        func walk(_ node: GuideNode, trail: [GuideNode]) {
            if !node.children.isEmpty || node.hasContent {
                results.append(GuideSearchResult(node: node, trail: trail))
            }
            for child in node.children {
                walk(child, trail: trail + [child])
            }
        }

        for root in roots {
            walk(root, trail: [root])
        }

        return results
    }

    private func normalized(_ text: String) -> String {
        text.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}

struct GuideRootCardView: View {
    let node: GuideNode

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(node.title)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.04, green: 0.18, blue: 0.34))

                    Text(node.summary)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.25, green: 0.36, blue: 0.48))
                        .lineLimit(3)
                }

                Spacer(minLength: 10)

                Image(systemName: "chevron.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(Color(red: 0.05, green: 0.50, blue: 0.80))
            }

            Text("\(node.childrenCount) tópicos")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.05, green: 0.50, blue: 0.80))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(red: 0.05, green: 0.50, blue: 0.80).opacity(0.10))
                .clipShape(Capsule())
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 12)
    }
}

struct GuideSearchCardView: View {
    let result: GuideSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(result.node.title)
                .font(.headline)
                .foregroundColor(Color(red: 0.04, green: 0.18, blue: 0.34))

            Text(result.node.summary)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.25, green: 0.36, blue: 0.48))
                .lineLimit(2)

            Text(result.trail.map(\.title).joined(separator: "  >  "))
                .font(.caption)
                .foregroundColor(Color(red: 0.05, green: 0.50, blue: 0.80))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: 10)
    }
}

struct GuideNodeDetailView: View {
    let node: GuideNode
    let trail: [GuideNode]

    @State private var markdown = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private var contentBlocks: [GuideContentBlock] {
        parseContent(markdown, baseDirectory: node.assetDirectoryPath)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.10, blue: 0.19),
                    Color(red: 0.05, green: 0.19, blue: 0.34),
                    Color(red: 0.62, green: 0.86, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroSection

                    if !node.children.isEmpty {
                        childrenSection
                    }

                    contentSection
                }
                .padding(20)
            }
            .refreshable {
                await loadMarkdown(forceReload: true)
            }
        }
        .navigationTitle(node.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadMarkdown(forceReload: false)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(node.title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(node.summary)
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.86))

            HStack(spacing: 10) {
                detailPill(text: trail.map(\.title).joined(separator: " • "), icon: "point.topleft.down.curvedto.point.bottomright.up")
                if node.hasContent {
                    detailPill(text: "Conteúdo oficial", icon: "checkmark.seal.fill")
                }
            }
        }
        .padding(22)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func detailPill(text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }

    private var childrenSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tópicos desta área")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ForEach(node.children) { child in
                    NavigationLink(destination: GuideNodeDetailView(node: child, trail: trail + [child])) {
                        GuideChildCardView(node: child)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        if isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.white)
                Text("Carregando conteúdo do guia...")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else if let errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text(errorMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        } else if markdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Resumo")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(node.summary)
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.86))
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        } else {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(contentBlocks) { block in
                    switch block.kind {
                    case .markdown(let text):
                        MarkdownBlock(content: text, foregroundColor: Color(red: 0.16, green: 0.27, blue: 0.38))
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: 10)
                    case .image(let url, let alt):
                        GuideImageCard(url: url, alt: alt)
                    }
                }
            }
        }
    }

    private func loadMarkdown(forceReload: Bool) async {
        guard let repoFilePath = node.repoFilePath else {
            await MainActor.run {
                markdown = ""
                errorMessage = nil
                isLoading = false
            }
            return
        }

        if !forceReload, !markdown.isEmpty {
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let content = try await GuideContentCache.shared.markdown(for: repoFilePath)
            await MainActor.run {
                markdown = content
                isLoading = false
            }
        } catch {
            await MainActor.run {
                markdown = ""
                errorMessage = "Não foi possível carregar este guia agora."
                isLoading = false
            }
        }
    }

    private func parseContent(_ text: String, baseDirectory: String?) -> [GuideContentBlock] {
        guard let regex = try? NSRegularExpression(pattern: "!\\[([^\\]]*)\\]\\(([^)]+)\\)") else {
            return [.init(kind: .markdown(text))]
        }

        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
        if matches.isEmpty {
            return [.init(kind: .markdown(text))]
        }

        var blocks: [GuideContentBlock] = []
        var currentLocation = 0

        for match in matches {
            if match.range.location > currentLocation {
                let chunk = nsText.substring(with: NSRange(location: currentLocation, length: match.range.location - currentLocation))
                if !chunk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    blocks.append(.init(kind: .markdown(chunk)))
                }
            }

            let alt = match.range(at: 1).location != NSNotFound ? nsText.substring(with: match.range(at: 1)) : ""
            let path = match.range(at: 2).location != NSNotFound ? nsText.substring(with: match.range(at: 2)) : ""
            if let imageURL = GuideCatalog.resolvedAssetURL(relativePath: path, baseDirectory: baseDirectory) {
                blocks.append(.init(kind: .image(url: imageURL, alt: alt)))
            }

            currentLocation = match.range.location + match.range.length
        }

        if currentLocation < nsText.length {
            let trailing = nsText.substring(from: currentLocation)
            if !trailing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                blocks.append(.init(kind: .markdown(trailing)))
            }
        }

        return blocks.isEmpty ? [.init(kind: .markdown(text))] : blocks
    }
}

struct GuideChildCardView: View {
    let node: GuideNode

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(node.title)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.04, green: 0.18, blue: 0.34))

                Text(node.summary)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.25, green: 0.36, blue: 0.48))
                    .lineLimit(3)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(Color(red: 0.05, green: 0.50, blue: 0.80))
                .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: 10)
    }
}

struct GuideImageCard: View {
    let url: URL
    let alt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.90))
                        ProgressView()
                    }
                    .frame(minHeight: 180)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.90))
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundColor(Color(red: 0.05, green: 0.50, blue: 0.80))
                            Text("Não foi possível carregar a imagem.")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.18, green: 0.27, blue: 0.38))
                        }
                    }
                    .frame(minHeight: 180)
                @unknown default:
                    EmptyView()
                }
            }

            if !alt.isEmpty {
                Text(alt)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.18, green: 0.27, blue: 0.38))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: 10)
    }
}

struct MarkdownBlock: View {
    let content: String
    let foregroundColor: Color

    var body: some View {
        Text(attributedContent)
            .font(.body)
            .foregroundColor(foregroundColor)
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributedContent: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .full,
            failurePolicy: .returnPartiallyParsedIfPossible
        )

        if let parsed = try? AttributedString(markdown: content, options: options) {
            return parsed
        }

        return AttributedString(content)
    }
}

// Preview Provider
struct RecursosView_Previews: PreviewProvider {
    static var previews: some View {
        RecursosView()
    }
}
