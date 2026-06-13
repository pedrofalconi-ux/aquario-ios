import SwiftUI

public struct VagasView: View {
    @State private var vagas: [Vaga] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText = ""
    @State private var selectedTypeFilter: TipoVaga? = nil
    @State private var selectedVaga: Vaga? = nil
    
    public init() {}
    
    // Filtered Vagas
    private var filteredVagas: [Vaga] {
        vagas.filter { vaga in
            let matchesSearch = searchText.isEmpty || 
                vaga.titulo.localizedCaseInsensitiveContains(searchText) || 
                vaga.descricao.localizedCaseInsensitiveContains(searchText) ||
                (vaga.entidade?.nome.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesType = selectedTypeFilter == nil || vaga.tipoVaga == selectedTypeFilter
            
            return matchesSearch && matchesType
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Filter Tags ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Todos", isSelected: selectedTypeFilter == nil) {
                                selectedTypeFilter = nil
                            }
                            
                            ForEach(TipoVaga.allCases, id: \.self) { type in
                                FilterChip(title: type.displayName, isSelected: selectedTypeFilter == type) {
                                    selectedTypeFilter = type
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    
                    // Opportunities List
                    if isLoading && vagas.isEmpty {
                        Spacer()
                        ProgressView("Buscando vagas...")
                        Spacer()
                    } else if filteredVagas.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "tray.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("Nenhuma vaga encontrada")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        List(filteredVagas) { vaga in
                            VagaRow(vaga: vaga)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    selectedVaga = vaga
                                }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await loadVagas(force: true)
                        }
                    }
                }
            }
            .navigationTitle("Oportunidades")
            .onAppear {
                Task {
                    await loadVagas(force: false)
                }
            }
            .sheet(item: $selectedVaga) { vaga in
                VagaDetailView(vaga: vaga)
            }
        }
    }
    
    private func loadVagas(force: Bool) async {
        if !force {
            // Check cache first to respond instantly
            let cached = StorageProvider.shared.getCachedVagas()
            if !cached.isEmpty {
                self.vagas = cached
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await NetworkManager.shared.fetchVagas()
            self.vagas = fetched
        } catch {
            errorMessage = error.localizedDescription
            // If network failed and we don't have memory data, load from disk
            if vagas.isEmpty {
                let cached = StorageProvider.shared.getCachedVagas()
                self.vagas = cached
            }
        }
        isLoading = false
    }
}

// MARK: - Subviews

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Buscar vagas, laboratórios ou tags...", text: $text)
                .foregroundColor(.primary)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .bold(isSelected)
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .cornerRadius(20)
        }
    }
}

struct VagaRow: View {
    let vaga: Vaga
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category Tag
                Text(vaga.tipoVaga.displayName)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                
                Spacer()
                
                // Finalization Date Warning
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(vaga.dataFinalizacao.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vaga.titulo)
                    .font(.headline)
                    .lineLimit(2)
                
                if let entityName = vaga.entidade?.nome {
                    Text(entityName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(vaga.descricao)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            // Bottom Info (Salary, Tags)
            HStack {
                if let salario = vaga.salario, !salario.isEmpty {
                    Label(salario, systemImage: "banknote")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Small area badges
                HStack(spacing: 4) {
                    ForEach(vaga.areas.prefix(2), id: \.self) { area in
                        Text(area)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct VagaDetailView: View {
    let vaga: Vaga
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text(vaga.tipoVaga.displayName)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        
                        Text(vaga.titulo)
                            .font(.title)
                            .bold()
                        
                        if let entityName = vaga.entidade?.nome {
                            HStack {
                                Image(systemName: "building.2.fill")
                                Text(entityName)
                            }
                            .font(.headline)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Info Grid
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Salário/Bolsa")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(vaga.salario ?? "Não informado")
                                .font(.body)
                                .bold()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Inscrições até")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(vaga.dataFinalizacao.formatted(date: .long, time: .omitted))
                                .font(.body)
                                .bold()
                        }
                    }
                    
                    Divider()
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descrição do Cargo")
                            .font(.headline)
                        Text(vaga.descricao)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Requirements
                    if !vaga.requisitos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Requisitos")
                                .font(.headline)
                            ForEach(vaga.requisitos, id: \.self) { req in
                                HStack(alignment: .top) {
                                    Text("•")
                                    Text(req)
                                }
                                .font(.body)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Apply Button
                    if let url = URL(string: vaga.linkInscricao) {
                        Link(destination: url) {
                            HStack {
                                Text("Candidatar-se à vaga")
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding()
            }
            .navigationTitle("Detalhes da Vaga")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
