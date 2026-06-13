import Foundation

// MARK: - Enums

public enum PapelPlataforma: String, Codable {
    case user = "USER"
    case masterAdmin = "MASTER_ADMIN"
}

public enum TipoEntidade: String, Codable, CaseIterable {
    case laboratorio = "LABORATORIO"
    case grupo = "GRUPO"
    case ligaAcademica = "LIGA_ACADEMICA"
    case empresa = "EMPRESA"
    case atletica = "ATLETICA"
    case centroAcademico = "CENTRO_ACADEMICO"
    case outro = "OUTRO"
    
    public var displayName: String {
        switch self {
        case .laboratorio: return "Laboratório"
        case .grupo: return "Grupo de Pesquisa"
        case .ligaAcademica: return "Liga Acadêmica"
        case .empresa: return "Empresa Júnior"
        case .atletica: return "Atlética"
        case .centroAcademico: return "Centro Acadêmico"
        case .outro: return "Outro"
        }
    }
}

public enum TipoVaga: String, Codable, CaseIterable {
    case estagio = "ESTAGIO"
    case trainee = "TRAINEE"
    case voluntario = "VOLUNTARIO"
    case pesquisa = "PESQUISA"
    case clt = "CLT"
    case pj = "PJ"
    case outro = "OUTRO"
    
    public var displayName: String {
        switch self {
        case .estagio: return "Estágio"
        case .trainee: return "Trainee"
        case .voluntario: return "Trabalho Voluntário"
        case .pesquisa: return "Pesquisa/Iniciação Científica"
        case .clt: return "CLT"
        case .pj: return "PJ"
        case .outro: return "Outro"
        }
    }
}

public enum NaturezaDisciplina: String, Codable {
    case obrigatoria = "OBRIGATORIA"
    case optativa = "OPTATIVA"
    case complementarFlexiva = "COMPLEMENTAR_FLEXIVA"
}

// MARK: - Models

public struct Usuario: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let email: String?
    public let matricula: String?
    public let slug: String?
    public let papelPlataforma: PapelPlataforma
    public let eVerificado: Bool
    public let urlFotoPerfil: String?
    public let periodoAtual: String?
    
    // Support both flat database IDs and nested API objects
    public let centroId: String?
    public let cursoId: String?
    public let centro: CentroSummary?
    public let curso: CursoSummary?
}

public struct CentroSummary: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let sigla: String
}

public struct CursoSummary: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
}

public struct Entidade: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let slug: String?
    public let subtitle: String?
    public let descricao: String?
    public let tipo: TipoEntidade
    public let urlFoto: String?
    public let contato: String?
    public let instagram: String?
    public let linkedin: String?
    public let website: String?
    public let location: String?
    public let foundingDate: Date?
}

public struct Vaga: Codable, Identifiable, Hashable {
    public let id: String
    public let titulo: String
    public let descricao: String
    public let tipoVaga: TipoVaga
    public let entidadeId: String
    public let criadoPorUsuarioId: String
    public let linkInscricao: String
    public let dataFinalizacao: Date
    public let criadoEm: Date
    public let areas: [String]
    public let salario: String?
    public let sobreEmpresa: String?
    public let requisitos: [String]
    public let responsabilidades: [String]
    public let etapasProcesso: [String]
    
    // Nested Entity relation representation
    public let entidade: EntidadeSummary?
}

public struct EntidadeSummary: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let urlFoto: String?
}

public struct Disciplina: Codable, Identifiable, Hashable {
    public let id: String
    public let codigo: String
    public let nome: String
    public let cargaHorariaTotal: Int?
    public let cargaHorariaTeoria: Int?
    public let cargaHorariaPratica: Int?
    public let departamento: String?
    public let modalidade: String?
    public let ementa: String?
}

public struct DisciplinaConcluida: Codable, Identifiable, Hashable {
    public let id: String
    public let usuarioId: String
    public let disciplinaId: String
    public let concluidaEm: Date
}

public struct Guia: Codable, Identifiable, Hashable {
    public let id: String
    public let titulo: String
    public let slug: String
    public let descricao: String?
    public let tags: [String]
    public let secoes: [SecaoGuia]?
}

public struct SecaoGuia: Codable, Identifiable, Hashable {
    public let id: String
    public let guiaId: String
    public let titulo: String
    public let slug: String
    public let ordem: Int
    public let conteudo: String?
    public let subsecoes: [SubSecaoGuia]?
}

public struct SubSecaoGuia: Codable, Identifiable, Hashable {
    public let id: String
    public let secaoId: String
    public let titulo: String
    public let slug: String
    public let ordem: Int
    public let conteudo: String?
}

public struct Centro: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let sigla: String
    public let descricao: String?
    public let campusId: String
}

public struct Curso: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let centroId: String
}

// MARK: - Projeto Models

public enum StatusProjeto: String, Codable {
    case rascunho = "RASCUNHO"
    case publicado = "PUBLICADO"
    case arquivado = "ARQUIVADO"
}

public struct ProjetoAutorUsuarioPublic: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let urlFotoPerfil: String?
    public let slug: String?
}

public struct ProjetoAutorEntidadePublic: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let slug: String?
    public let tipo: String
    public let urlFoto: String?
}

public struct ProjetoAutorPublic: Codable, Identifiable, Hashable {
    public var id: String {
        return databaseId
    }
    public let databaseId: String
    public let projetoId: String
    public let usuarioId: String?
    public let entidadeId: String?
    public let autorPrincipal: Bool
    public let usuario: ProjetoAutorUsuarioPublic?
    public let entidade: ProjetoAutorEntidadePublic?
    
    enum CodingKeys: String, CodingKey {
        case databaseId = "id"
        case projetoId
        case usuarioId
        case entidadeId
        case autorPrincipal
        case usuario
        case entidade
    }
}

public struct Projeto: Codable, Identifiable, Hashable {
    public let id: String
    public let titulo: String
    public let slug: String
    public let subtitulo: String?
    public let textContent: String?
    public let urlImagem: String?
    public let status: StatusProjeto
    public let tags: [String]
    public let dataInicio: Date?
    public let dataFim: Date?
    public let urlRepositorio: String?
    public let urlDemo: String?
    public let urlOutro: String?
    public let criadoEm: Date
    public let publicadoEm: Date?
    public let autores: [ProjetoAutorPublic]
}

// MARK: - Grade Curricular Models

public struct GradeDisciplinaNode: Codable, Identifiable, Hashable {
    public let id: String
    public let disciplinaId: String
    public let codigo: String
    public let nome: String
    public let periodo: Int
    public let natureza: String
    public let cargaHorariaTotal: Int?
    public let cargaHorariaTeoria: Int?
    public let cargaHorariaPratica: Int?
    public let departamento: String?
    public let modalidade: String?
    public let ementa: String?
    public let preRequisitos: [String]
    public let equivalencias: [String]
}

public struct GradeCurricularResponse: Codable {
    public let curriculoId: String
    public let curriculoCodigo: String
    public let cursoId: String
    public let cursoNome: String
    public let disciplinas: [GradeDisciplinaNode]
}

// MARK: - Calendário Acadêmico Models

public enum CategoriaEventoAcademico: String, Codable, CaseIterable {
    case matriculaIngressantes = "MATRICULA_INGRESSANTES"
    case matriculaVeteranos = "MATRICULA_VETERANOS"
    case rematricula = "REMATRICULA"
    case matriculaExtraordinaria = "MATRICULA_EXTRAORDINARIA"
    case pontoFacultativo = "PONTO_FACULTATIVO"
    case feriado = "FERIADO"
    case examesFinais = "EXAMES_FINAIS"
    case registroMediasFinais = "REGISTRO_MEDIAS_FINAIS"
    case colacaoDeGrau = "COLACAO_DE_GRAU"
    case inicioPeriodoLetivo = "INICIO_PERIODO_LETIVO"
    case terminoPeriodoLetivo = "TERMINO_PERIODO_LETIVO"
    case outra = "OUTRA"

    public var displayName: String {
        switch self {
        case .matriculaIngressantes: return "Matrícula (Ingressantes)"
        case .matriculaVeteranos: return "Matrícula (Veteranos)"
        case .rematricula: return "Rematrícula"
        case .matriculaExtraordinaria: return "Matrícula Extraordinária"
        case .pontoFacultativo: return "Ponto Facultativo"
        case .feriado: return "Feriado"
        case .examesFinais: return "Exames Finais"
        case .registroMediasFinais: return "Registro de Médias Finais"
        case .colacaoDeGrau: return "Colação de Grau"
        case .inicioPeriodoLetivo: return "Início do Período Letivo"
        case .terminoPeriodoLetivo: return "Término do Período Letivo"
        case .outra: return "Outra"
        }
    }
}

public struct EventoCalendarioAcademico: Codable, Identifiable, Hashable {
    public let id: String
    public let descricao: String
    public let dataInicio: Date
    public let dataFim: Date
    public let categoria: CategoriaEventoAcademico
    public let semestreId: String
    public let criadoEm: Date
    public let atualizadoEm: Date
}

public struct SemestreLetivo: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let dataInicio: Date
    public let dataFim: Date
    public let criadoEm: Date
    public let atualizadoEm: Date
}

public struct SemestreLetivoDetalhado: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let dataInicio: Date
    public let dataFim: Date
    public let criadoEm: Date
    public let atualizadoEm: Date
    public let eventos: [EventoCalendarioAcademico]
}
