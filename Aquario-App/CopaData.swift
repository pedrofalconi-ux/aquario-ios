import Foundation

public struct CopaTeam: Codable, Identifiable, Hashable {
    public let id: String
    public let nome: String
    public let flagCode: String
    public let grupo: String
    
    public var flagEmoji: String {
        switch id {
        case "MEX": return "🇲🇽"
        case "RSA": return "🇿🇦"
        case "KOR": return "🇰🇷"
        case "CZE": return "🇨🇿"
        case "CAN": return "🇨🇦"
        case "BIH": return "🇧🇦"
        case "QAT": return "🇶🇦"
        case "SUI": return "🇨🇭"
        case "BRA": return "🇧🇷"
        case "MAR": return "🇲🇦"
        case "HAI": return "🇭🇹"
        case "SCO": return "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
        case "USA": return "🇺🇸"
        case "PAR": return "🇵🇾"
        case "AUS": return "🇦🇺"
        case "TUR": return "🇹🇷"
        case "GER": return "🇩🇪"
        case "CUW": return "🇨🇼"
        case "CIV": return "🇨🇮"
        case "ECU": return "🇪🇨"
        case "NED": return "🇳🇱"
        case "JPN": return "🇯🇵"
        case "SWE": return "🇸🇪"
        case "TUN": return "🇹🇳"
        case "BEL": return "🇧🇪"
        case "EGY": return "🇪🇬"
        case "IRN": return "🇮🇷"
        case "NZL": return "🇳🇿"
        case "ESP": return "🇪🇸"
        case "CPV": return "🇨🇻"
        case "KSA": return "🇸🇦"
        case "URU": return "🇺🇾"
        case "FRA": return "🇫🇷"
        case "SEN": return "🇸🇳"
        case "IRQ": return "🇮🇶"
        case "NOR": return "🇳🇴"
        case "ARG": return "🇦🇷"
        case "ALG": return "🇩🇿"
        case "AUT": return "🇦🇹"
        case "JOR": return "🇯🇴"
        case "POR": return "🇵🇹"
        case "COD": return "🇨🇩"
        case "UZB": return "🇺🇿"
        case "COL": return "🇨🇴"
        case "ENG": return "🏴󠁧󠁢󠁥󠁮󠁧󠁿"
        case "CRO": return "🇭🇷"
        case "GHA": return "🇬🇭"
        case "PAN": return "🇵🇦"
        default: return "🏳️"
        }
    }
}

public struct CopaMatch: Codable, Identifiable, Hashable {
    public let id: Int
    public let kickoff: String
    public let stage: String
    public let grupo: String?
    public let homeId: String?
    public let awayId: String?
    public let homeLabel: String?
    public let awayLabel: String?
    public let venue: String
    public let city: String
}

public enum CopaData {
    public static let teams: [CopaTeam] = [
        CopaTeam(id: "MEX", nome: "México", flagCode: "mx", grupo: "A"),
        CopaTeam(id: "RSA", nome: "África do Sul", flagCode: "za", grupo: "A"),
        CopaTeam(id: "KOR", nome: "Coreia do Sul", flagCode: "kr", grupo: "A"),
        CopaTeam(id: "CZE", nome: "Tchéquia", flagCode: "cz", grupo: "A"),
        CopaTeam(id: "CAN", nome: "Canadá", flagCode: "ca", grupo: "B"),
        CopaTeam(id: "BIH", nome: "Bósnia e Herzegovina", flagCode: "ba", grupo: "B"),
        CopaTeam(id: "QAT", nome: "Catar", flagCode: "qa", grupo: "B"),
        CopaTeam(id: "SUI", nome: "Suíça", flagCode: "ch", grupo: "B"),
        CopaTeam(id: "BRA", nome: "Brasil", flagCode: "br", grupo: "C"),
        CopaTeam(id: "MAR", nome: "Marrocos", flagCode: "ma", grupo: "C"),
        CopaTeam(id: "HAI", nome: "Haiti", flagCode: "ht", grupo: "C"),
        CopaTeam(id: "SCO", nome: "Escócia", flagCode: "gb-sct", grupo: "C"),
        CopaTeam(id: "USA", nome: "Estados Unidos", flagCode: "us", grupo: "D"),
        CopaTeam(id: "PAR", nome: "Paraguai", flagCode: "py", grupo: "D"),
        CopaTeam(id: "AUS", nome: "Austrália", flagCode: "au", grupo: "D"),
        CopaTeam(id: "TUR", nome: "Turquia", flagCode: "tr", grupo: "D"),
        CopaTeam(id: "GER", nome: "Alemanha", flagCode: "de", grupo: "E"),
        CopaTeam(id: "CUW", nome: "Curaçao", flagCode: "cw", grupo: "E"),
        CopaTeam(id: "CIV", nome: "Costa do Marfim", flagCode: "ci", grupo: "E"),
        CopaTeam(id: "ECU", nome: "Equador", flagCode: "ec", grupo: "E"),
        CopaTeam(id: "NED", nome: "Países Baixos", flagCode: "nl", grupo: "F"),
        CopaTeam(id: "JPN", nome: "Japão", flagCode: "jp", grupo: "F"),
        CopaTeam(id: "SWE", nome: "Suécia", flagCode: "se", grupo: "F"),
        CopaTeam(id: "TUN", nome: "Tunísia", flagCode: "tn", grupo: "F"),
        CopaTeam(id: "BEL", nome: "Bélgica", flagCode: "be", grupo: "G"),
        CopaTeam(id: "EGY", nome: "Egito", flagCode: "eg", grupo: "G"),
        CopaTeam(id: "IRN", nome: "Irã", flagCode: "ir", grupo: "G"),
        CopaTeam(id: "NZL", nome: "Nova Zelândia", flagCode: "nz", grupo: "G"),
        CopaTeam(id: "ESP", nome: "Espanha", flagCode: "es", grupo: "H"),
        CopaTeam(id: "CPV", nome: "Cabo Verde", flagCode: "cv", grupo: "H"),
        CopaTeam(id: "KSA", nome: "Arábia Saudita", flagCode: "sa", grupo: "H"),
        CopaTeam(id: "URU", nome: "Uruguai", flagCode: "uy", grupo: "H"),
        CopaTeam(id: "FRA", nome: "França", flagCode: "fr", grupo: "I"),
        CopaTeam(id: "SEN", nome: "Senegal", flagCode: "sn", grupo: "I"),
        CopaTeam(id: "IRQ", nome: "Iraque", flagCode: "iq", grupo: "I"),
        CopaTeam(id: "NOR", nome: "Noruega", flagCode: "no", grupo: "I"),
        CopaTeam(id: "ARG", nome: "Argentina", flagCode: "ar", grupo: "J"),
        CopaTeam(id: "ALG", nome: "Argélia", flagCode: "dz", grupo: "J"),
        CopaTeam(id: "AUT", nome: "Áustria", flagCode: "at", grupo: "J"),
        CopaTeam(id: "JOR", nome: "Jordânia", flagCode: "jo", grupo: "J"),
        CopaTeam(id: "POR", nome: "Portugal", flagCode: "pt", grupo: "K"),
        CopaTeam(id: "COD", nome: "RD Congo", flagCode: "cd", grupo: "K"),
        CopaTeam(id: "UZB", nome: "Uzbequistão", flagCode: "uz", grupo: "K"),
        CopaTeam(id: "COL", nome: "Colômbia", flagCode: "co", grupo: "K"),
        CopaTeam(id: "ENG", nome: "Inglaterra", flagCode: "gb-eng", grupo: "L"),
        CopaTeam(id: "CRO", nome: "Croácia", flagCode: "hr", grupo: "L"),
        CopaTeam(id: "GHA", nome: "Gana", flagCode: "gh", grupo: "L"),
        CopaTeam(id: "PAN", nome: "Panamá", flagCode: "pa", grupo: "L"),
    ]
    
    public static let matches: [CopaMatch] = [
        CopaMatch(id: 1, kickoff: "2026-06-11T16:00:00-03:00", stage: "grupos", grupo: "A", homeId: "MEX", awayId: "RSA", homeLabel: nil, awayLabel: nil, venue: "Estádio Azteca", city: "Cidade do México"),
        CopaMatch(id: 2, kickoff: "2026-06-11T23:00:00-03:00", stage: "grupos", grupo: "A", homeId: "KOR", awayId: "CZE", homeLabel: nil, awayLabel: nil, venue: "Estádio Akron", city: "Guadalajara"),
        CopaMatch(id: 3, kickoff: "2026-06-12T16:00:00-03:00", stage: "grupos", grupo: "B", homeId: "CAN", awayId: "BIH", homeLabel: nil, awayLabel: nil, venue: "BMO Field", city: "Toronto"),
        CopaMatch(id: 4, kickoff: "2026-06-12T22:00:00-03:00", stage: "grupos", grupo: "D", homeId: "USA", awayId: "PAR", homeLabel: nil, awayLabel: nil, venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 5, kickoff: "2026-06-13T01:00:00-03:00", stage: "grupos", grupo: "D", homeId: "AUS", awayId: "TUR", homeLabel: nil, awayLabel: nil, venue: "BC Place", city: "Vancouver"),
        CopaMatch(id: 6, kickoff: "2026-06-13T16:00:00-03:00", stage: "grupos", grupo: "B", homeId: "QAT", awayId: "SUI", homeLabel: nil, awayLabel: nil, venue: "Levi's Stadium", city: "Santa Clara"),
        CopaMatch(id: 7, kickoff: "2026-06-13T19:00:00-03:00", stage: "grupos", grupo: "C", homeId: "BRA", awayId: "MAR", homeLabel: nil, awayLabel: nil, venue: "MetLife Stadium", city: "East Rutherford"),
        CopaMatch(id: 8, kickoff: "2026-06-13T22:00:00-03:00", stage: "grupos", grupo: "C", homeId: "HAI", awayId: "SCO", homeLabel: nil, awayLabel: nil, venue: "Gillette Stadium", city: "Foxborough"),
        CopaMatch(id: 9, kickoff: "2026-06-14T14:00:00-03:00", stage: "grupos", grupo: "E", homeId: "GER", awayId: "CUW", homeLabel: nil, awayLabel: nil, venue: "NRG Stadium", city: "Houston"),
        CopaMatch(id: 10, kickoff: "2026-06-14T17:00:00-03:00", stage: "grupos", grupo: "F", homeId: "NED", awayId: "JPN", homeLabel: nil, awayLabel: nil, venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 11, kickoff: "2026-06-14T20:00:00-03:00", stage: "grupos", grupo: "E", homeId: "CIV", awayId: "ECU", homeLabel: nil, awayLabel: nil, venue: "Lincoln Financial Field", city: "Filadélfia"),
        CopaMatch(id: 12, kickoff: "2026-06-14T23:00:00-03:00", stage: "grupos", grupo: "F", homeId: "SWE", awayId: "TUN", homeLabel: nil, awayLabel: nil, venue: "Estádio Monterrey", city: "Monterrey"),
        CopaMatch(id: 13, kickoff: "2026-06-15T14:00:00-03:00", stage: "grupos", grupo: "H", homeId: "ESP", awayId: "CPV", homeLabel: nil, awayLabel: nil, venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 14, kickoff: "2026-06-15T19:00:00-03:00", stage: "grupos", grupo: "G", homeId: "BEL", awayId: "EGY", homeLabel: nil, awayLabel: nil, venue: "Lumen Field", city: "Seattle"),
        CopaMatch(id: 15, kickoff: "2026-06-15T19:00:00-03:00", stage: "grupos", grupo: "H", homeId: "KSA", awayId: "URU", homeLabel: nil, awayLabel: nil, venue: "Hard Rock Stadium", city: "Miami"),
        CopaMatch(id: 16, kickoff: "2026-06-16T01:00:00-03:00", stage: "grupos", grupo: "G", homeId: "IRN", awayId: "NZL", homeLabel: nil, awayLabel: nil, venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 17, kickoff: "2026-06-16T16:00:00-03:00", stage: "grupos", grupo: "I", homeId: "FRA", awayId: "SEN", homeLabel: nil, awayLabel: nil, venue: "MetLife Stadium", city: "East Rutherford"),
        CopaMatch(id: 18, kickoff: "2026-06-16T19:00:00-03:00", stage: "grupos", grupo: "I", homeId: "IRQ", awayId: "NOR", homeLabel: nil, awayLabel: nil, venue: "Gillette Stadium", city: "Foxborough"),
        CopaMatch(id: 19, kickoff: "2026-06-16T22:00:00-03:00", stage: "grupos", grupo: "J", homeId: "ARG", awayId: "ALG", homeLabel: nil, awayLabel: nil, venue: "Arrowhead Stadium", city: "Kansas City"),
        CopaMatch(id: 20, kickoff: "2026-06-17T01:00:00-03:00", stage: "grupos", grupo: "J", homeId: "AUT", awayId: "JOR", homeLabel: nil, awayLabel: nil, venue: "Levi's Stadium", city: "Santa Clara"),
        CopaMatch(id: 21, kickoff: "2026-06-17T14:00:00-03:00", stage: "grupos", grupo: "K", homeId: "POR", awayId: "COD", homeLabel: nil, awayLabel: nil, venue: "NRG Stadium", city: "Houston"),
        CopaMatch(id: 22, kickoff: "2026-06-17T17:00:00-03:00", stage: "grupos", grupo: "L", homeId: "ENG", awayId: "CRO", homeLabel: nil, awayLabel: nil, venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 23, kickoff: "2026-06-17T20:00:00-03:00", stage: "grupos", grupo: "L", homeId: "GHA", awayId: "PAN", homeLabel: nil, awayLabel: nil, venue: "BMO Field", city: "Toronto"),
        CopaMatch(id: 24, kickoff: "2026-06-17T23:00:00-03:00", stage: "grupos", grupo: "K", homeId: "UZB", awayId: "COL", homeLabel: nil, awayLabel: nil, venue: "Estádio Azteca", city: "Cidade do México"),
        CopaMatch(id: 25, kickoff: "2026-06-18T13:00:00-03:00", stage: "grupos", grupo: "A", homeId: "CZE", awayId: "RSA", homeLabel: nil, awayLabel: nil, venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 26, kickoff: "2026-06-18T16:00:00-03:00", stage: "grupos", grupo: "B", homeId: "SUI", awayId: "BIH", homeLabel: nil, awayLabel: nil, venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 27, kickoff: "2026-06-18T19:00:00-03:00", stage: "grupos", grupo: "B", homeId: "CAN", awayId: "QAT", homeLabel: nil, awayLabel: nil, venue: "BC Place", city: "Vancouver"),
        CopaMatch(id: 28, kickoff: "2026-06-18T22:00:00-03:00", stage: "grupos", grupo: "A", homeId: "MEX", awayId: "KOR", homeLabel: nil, awayLabel: nil, venue: "Estádio Akron", city: "Guadalajara"),
        CopaMatch(id: 29, kickoff: "2026-06-19T16:00:00-03:00", stage: "grupos", grupo: "D", homeId: "USA", awayId: "AUS", homeLabel: nil, awayLabel: nil, venue: "Lumen Field", city: "Seattle"),
        CopaMatch(id: 30, kickoff: "2026-06-19T19:00:00-03:00", stage: "grupos", grupo: "C", homeId: "SCO", awayId: "MAR", homeLabel: nil, awayLabel: nil, venue: "Gillette Stadium", city: "Foxborough"),
        CopaMatch(id: 31, kickoff: "2026-06-19T21:30:00-03:00", stage: "grupos", grupo: "C", homeId: "BRA", awayId: "HAI", homeLabel: nil, awayLabel: nil, venue: "Lincoln Financial Field", city: "Filadélfia"),
        CopaMatch(id: 32, kickoff: "2026-06-20T00:00:00-03:00", stage: "grupos", grupo: "D", homeId: "TUR", awayId: "PAR", homeLabel: nil, awayLabel: nil, venue: "Levi's Stadium", city: "Santa Clara"),
        CopaMatch(id: 33, kickoff: "2026-06-20T14:00:00-03:00", stage: "grupos", grupo: "F", homeId: "NED", awayId: "SWE", homeLabel: nil, awayLabel: nil, venue: "NRG Stadium", city: "Houston"),
        CopaMatch(id: 34, kickoff: "2026-06-20T17:00:00-03:00", stage: "grupos", grupo: "E", homeId: "GER", awayId: "CIV", homeLabel: nil, awayLabel: nil, venue: "BMO Field", city: "Toronto"),
        CopaMatch(id: 35, kickoff: "2026-06-20T21:00:00-03:00", stage: "grupos", grupo: "E", homeId: "ECU", awayId: "CUW", homeLabel: nil, awayLabel: nil, venue: "Arrowhead Stadium", city: "Kansas City"),
        CopaMatch(id: 36, kickoff: "2026-06-21T01:00:00-03:00", stage: "grupos", grupo: "F", homeId: "TUN", awayId: "JPN", homeLabel: nil, awayLabel: nil, venue: "Estádio Monterrey", city: "Monterrey"),
        CopaMatch(id: 37, kickoff: "2026-06-21T13:00:00-03:00", stage: "grupos", grupo: "H", homeId: "ESP", awayId: "KSA", homeLabel: nil, awayLabel: nil, venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 38, kickoff: "2026-06-21T16:00:00-03:00", stage: "grupos", grupo: "G", homeId: "BEL", awayId: "IRN", homeLabel: nil, awayLabel: nil, venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 39, kickoff: "2026-06-21T19:00:00-03:00", stage: "grupos", grupo: "H", homeId: "URU", awayId: "CPV", homeLabel: nil, awayLabel: nil, venue: "Hard Rock Stadium", city: "Miami"),
        CopaMatch(id: 40, kickoff: "2026-06-21T22:00:00-03:00", stage: "grupos", grupo: "G", homeId: "NZL", awayId: "EGY", homeLabel: nil, awayLabel: nil, venue: "BC Place", city: "Vancouver"),
        CopaMatch(id: 41, kickoff: "2026-06-22T14:00:00-03:00", stage: "grupos", grupo: "J", homeId: "ARG", awayId: "AUT", homeLabel: nil, awayLabel: nil, venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 42, kickoff: "2026-06-22T18:00:00-03:00", stage: "grupos", grupo: "I", homeId: "FRA", awayId: "IRQ", homeLabel: nil, awayLabel: nil, venue: "Lincoln Financial Field", city: "Filadélfia"),
        CopaMatch(id: 43, kickoff: "2026-06-22T21:00:00-03:00", stage: "grupos", grupo: "I", homeId: "NOR", awayId: "SEN", homeLabel: nil, awayLabel: nil, venue: "MetLife Stadium", city: "East Rutherford"),
        CopaMatch(id: 44, kickoff: "2026-06-23T00:00:00-03:00", stage: "grupos", grupo: "J", homeId: "JOR", awayId: "ALG", homeLabel: nil, awayLabel: nil, venue: "Levi's Stadium", city: "Santa Clara"),
        CopaMatch(id: 45, kickoff: "2026-06-23T14:00:00-03:00", stage: "grupos", grupo: "K", homeId: "POR", awayId: "UZB", homeLabel: nil, awayLabel: nil, venue: "NRG Stadium", city: "Houston"),
        CopaMatch(id: 46, kickoff: "2026-06-23T17:00:00-03:00", stage: "grupos", grupo: "L", homeId: "ENG", awayId: "GHA", homeLabel: nil, awayLabel: nil, venue: "Gillette Stadium", city: "Foxborough"),
        CopaMatch(id: 47, kickoff: "2026-06-23T20:00:00-03:00", stage: "grupos", grupo: "L", homeId: "PAN", awayId: "CRO", homeLabel: nil, awayLabel: nil, venue: "BMO Field", city: "Toronto"),
        CopaMatch(id: 48, kickoff: "2026-06-23T23:00:00-03:00", stage: "grupos", grupo: "K", homeId: "COL", awayId: "COD", homeLabel: nil, awayLabel: nil, venue: "Estádio Akron", city: "Guadalajara"),
        CopaMatch(id: 49, kickoff: "2026-06-24T16:00:00-03:00", stage: "grupos", grupo: "B", homeId: "SUI", awayId: "CAN", homeLabel: nil, awayLabel: nil, venue: "BC Place", city: "Vancouver"),
        CopaMatch(id: 50, kickoff: "2026-06-24T16:00:00-03:00", stage: "grupos", grupo: "B", homeId: "BIH", awayId: "QAT", homeLabel: nil, awayLabel: nil, venue: "Lumen Field", city: "Seattle"),
        CopaMatch(id: 51, kickoff: "2026-06-24T19:00:00-03:00", stage: "grupos", grupo: "C", homeId: "SCO", awayId: "BRA", homeLabel: nil, awayLabel: nil, venue: "Hard Rock Stadium", city: "Miami"),
        CopaMatch(id: 52, kickoff: "2026-06-24T19:00:00-03:00", stage: "grupos", grupo: "C", homeId: "MAR", awayId: "HAI", homeLabel: nil, awayLabel: nil, venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 53, kickoff: "2026-06-24T22:00:00-03:00", stage: "grupos", grupo: "A", homeId: "CZE", awayId: "MEX", homeLabel: nil, awayLabel: nil, venue: "Estádio Azteca", city: "Cidade do México"),
        CopaMatch(id: 54, kickoff: "2026-06-24T22:00:00-03:00", stage: "grupos", grupo: "A", homeId: "RSA", awayId: "KOR", homeLabel: nil, awayLabel: nil, venue: "Estádio BBVA", city: "Monterrey"),
        CopaMatch(id: 55, kickoff: "2026-06-25T17:00:00-03:00", stage: "grupos", grupo: "E", homeId: "CUW", awayId: "CIV", homeLabel: nil, awayLabel: nil, venue: "Lincoln Financial Field", city: "Filadélfia"),
        CopaMatch(id: 56, kickoff: "2026-06-25T17:00:00-03:00", stage: "grupos", grupo: "E", homeId: "ECU", awayId: "GER", homeLabel: nil, awayLabel: nil, venue: "MetLife Stadium", city: "East Rutherford"),
        CopaMatch(id: 57, kickoff: "2026-06-25T20:00:00-03:00", stage: "grupos", grupo: "F", homeId: "JPN", awayId: "SWE", homeLabel: nil, awayLabel: nil, venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 58, kickoff: "2026-06-25T20:00:00-03:00", stage: "grupos", grupo: "F", homeId: "TUN", awayId: "NED", homeLabel: nil, awayLabel: nil, venue: "Arrowhead Stadium", city: "Kansas City"),
        CopaMatch(id: 59, kickoff: "2026-06-25T23:00:00-03:00", stage: "grupos", grupo: "D", homeId: "TUR", awayId: "USA", homeLabel: nil, awayLabel: nil, venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 60, kickoff: "2026-06-25T23:00:00-03:00", stage: "grupos", grupo: "D", homeId: "PAR", awayId: "AUS", homeLabel: nil, awayLabel: nil, venue: "Levi's Stadium", city: "Santa Clara"),
        CopaMatch(id: 61, kickoff: "2026-06-26T16:00:00-03:00", stage: "grupos", grupo: "I", homeId: "NOR", awayId: "FRA", homeLabel: nil, awayLabel: nil, venue: "Gillette Stadium", city: "Foxborough"),
        CopaMatch(id: 62, kickoff: "2026-06-26T16:00:00-03:00", stage: "grupos", grupo: "I", homeId: "SEN", awayId: "IRQ", homeLabel: nil, awayLabel: nil, venue: "BMO Field", city: "Toronto"),
        CopaMatch(id: 63, kickoff: "2026-06-26T21:00:00-03:00", stage: "grupos", grupo: "H", homeId: "CPV", awayId: "KSA", homeLabel: nil, awayLabel: nil, venue: "NRG Stadium", city: "Houston"),
        CopaMatch(id: 64, kickoff: "2026-06-26T21:00:00-03:00", stage: "grupos", grupo: "H", homeId: "URU", awayId: "ESP", homeLabel: nil, awayLabel: nil, venue: "Estádio Akron", city: "Guadalajara"),
        CopaMatch(id: 65, kickoff: "2026-06-27T00:00:00-03:00", stage: "grupos", grupo: "G", homeId: "EGY", awayId: "IRN", homeLabel: nil, awayLabel: nil, venue: "Lumen Field", city: "Seattle"),
        CopaMatch(id: 66, kickoff: "2026-06-27T00:00:00-03:00", stage: "grupos", grupo: "G", homeId: "NZL", awayId: "BEL", homeLabel: nil, awayLabel: nil, venue: "BC Place", city: "Vancouver"),
        CopaMatch(id: 67, kickoff: "2026-06-27T18:00:00-03:00", stage: "grupos", grupo: "L", homeId: "PAN", awayId: "ENG", homeLabel: nil, awayLabel: nil, venue: "MetLife Stadium", city: "East Rutherford"),
        CopaMatch(id: 68, kickoff: "2026-06-27T18:00:00-03:00", stage: "grupos", grupo: "L", homeId: "CRO", awayId: "GHA", homeLabel: nil, awayLabel: nil, venue: "Lincoln Financial Field", city: "Filadélfia"),
        CopaMatch(id: 69, kickoff: "2026-06-27T20:30:00-03:00", stage: "grupos", grupo: "K", homeId: "COL", awayId: "POR", homeLabel: nil, awayLabel: nil, venue: "Hard Rock Stadium", city: "Miami"),
        CopaMatch(id: 70, kickoff: "2026-06-27T20:30:00-03:00", stage: "grupos", grupo: "K", homeId: "COD", awayId: "UZB", homeLabel: nil, awayLabel: nil, venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 71, kickoff: "2026-06-27T23:00:00-03:00", stage: "grupos", grupo: "J", homeId: "JOR", awayId: "ARG", homeLabel: nil, awayLabel: nil, venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 72, kickoff: "2026-06-27T23:00:00-03:00", stage: "grupos", grupo: "J", homeId: "ALG", awayId: "AUT", homeLabel: nil, awayLabel: nil, venue: "Arrowhead Stadium", city: "Kansas City"),
        CopaMatch(id: 73, kickoff: "2026-06-28T16:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "2º Grupo A", awayLabel: "2º Grupo B", venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 76, kickoff: "2026-06-29T14:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo C", awayLabel: "2º Grupo F", venue: "NRG Stadium", city: "Houston"),
        CopaMatch(id: 74, kickoff: "2026-06-29T17:30:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo E", awayLabel: "3º A/B/C/D/F", venue: "Gillette Stadium", city: "Foxborough"),
        CopaMatch(id: 75, kickoff: "2026-06-29T22:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo F", awayLabel: "2º Grupo C", venue: "Estádio Monterrey", city: "Monterrey"),
        CopaMatch(id: 78, kickoff: "2026-06-30T14:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "2º Grupo E", awayLabel: "2º Grupo I", venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 77, kickoff: "2026-06-30T18:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo I", awayLabel: "3º C/D/F/G/H", venue: "MetLife Stadium", city: "East Rutherford"),
        CopaMatch(id: 79, kickoff: "2026-06-30T22:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo A", awayLabel: "3º C/E/F/H/I", venue: "Estádio Azteca", city: "Cidade do México"),
        CopaMatch(id: 80, kickoff: "2026-07-01T13:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo L", awayLabel: "3º E/H/I/J/K", venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 82, kickoff: "2026-07-01T17:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo G", awayLabel: "3º A/E/H/I/J", venue: "Lumen Field", city: "Seattle"),
        CopaMatch(id: 81, kickoff: "2026-07-01T21:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo D", awayLabel: "3º B/E/F/I/J", venue: "Levi's Stadium", city: "Santa Clara"),
        CopaMatch(id: 84, kickoff: "2026-07-02T16:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo H", awayLabel: "2º Grupo J", venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 83, kickoff: "2026-07-02T20:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "2º Grupo K", awayLabel: "2º Grupo L", venue: "BMO Field", city: "Toronto"),
        CopaMatch(id: 85, kickoff: "2026-07-03T00:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo B", awayLabel: "3º E/F/G/I/J", venue: "BC Place", city: "Vancouver"),
        CopaMatch(id: 87, kickoff: "2026-07-03T15:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "2º Grupo D", awayLabel: "2º Grupo G", venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 86, kickoff: "2026-07-03T19:00:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo J", awayLabel: "2º Grupo H", venue: "Hard Rock Stadium", city: "Miami"),
        CopaMatch(id: 88, kickoff: "2026-07-03T22:30:00-03:00", stage: "32avos", grupo: nil, homeId: nil, awayId: nil, homeLabel: "1º Grupo K", awayLabel: "3º D/E/I/J/L", venue: "Arrowhead Stadium", city: "Kansas City"),
        CopaMatch(id: 90, kickoff: "2026-07-04T14:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 73", awayLabel: "Vencedor Jogo 75", venue: "NRG Stadium", city: "Houston"),
        CopaMatch(id: 89, kickoff: "2026-07-04T18:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 74", awayLabel: "Vencedor Jogo 77", venue: "Lincoln Financial Field", city: "Filadélfia"),
        CopaMatch(id: 91, kickoff: "2026-07-05T17:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 76", awayLabel: "Vencedor Jogo 78", venue: "MetLife Stadium", city: "East Rutherford"),
        CopaMatch(id: 92, kickoff: "2026-07-05T21:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 79", awayLabel: "Vencedor Jogo 80", venue: "Estádio Azteca", city: "Cidade do México"),
        CopaMatch(id: 93, kickoff: "2026-07-06T16:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 83", awayLabel: "Vencedor Jogo 84", venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 94, kickoff: "2026-07-06T18:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 81", awayLabel: "Vencedor Jogo 82", venue: "Lumen Field", city: "Seattle"),
        CopaMatch(id: 95, kickoff: "2026-07-07T13:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 86", awayLabel: "Vencedor Jogo 88", venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 96, kickoff: "2026-07-07T17:00:00-03:00", stage: "oitavas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 85", awayLabel: "Vencedor Jogo 87", venue: "BC Place", city: "Vancouver"),
        CopaMatch(id: 97, kickoff: "2026-07-09T17:00:00-03:00", stage: "quartas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 89", awayLabel: "Vencedor Jogo 90", venue: "Gillette Stadium", city: "Foxborough"),
        CopaMatch(id: 98, kickoff: "2026-07-10T16:00:00-03:00", stage: "quartas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 93", awayLabel: "Vencedor Jogo 94", venue: "SoFi Stadium", city: "Inglewood"),
        CopaMatch(id: 99, kickoff: "2026-07-11T18:00:00-03:00", stage: "quartas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 91", awayLabel: "Vencedor Jogo 92", venue: "Hard Rock Stadium", city: "Miami"),
        CopaMatch(id: 100, kickoff: "2026-07-11T22:00:00-03:00", stage: "quartas", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 95", awayLabel: "Vencedor Jogo 96", venue: "Arrowhead Stadium", city: "Kansas City"),
        CopaMatch(id: 101, kickoff: "2026-07-14T16:00:00-03:00", stage: "semis", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 97", awayLabel: "Vencedor Jogo 98", venue: "AT&T Stadium", city: "Arlington"),
        CopaMatch(id: 102, kickoff: "2026-07-15T16:00:00-03:00", stage: "semis", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 99", awayLabel: "Vencedor Jogo 100", venue: "Mercedes-Benz Stadium", city: "Atlanta"),
        CopaMatch(id: 103, kickoff: "2026-07-18T18:00:00-03:00", stage: "terceiro", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Perdedor Jogo 101", awayLabel: "Perdedor Jogo 102", venue: "Hard Rock Stadium", city: "Miami"),
        CopaMatch(id: 104, kickoff: "2026-07-19T16:00:00-03:00", stage: "final", grupo: nil, homeId: nil, awayId: nil, homeLabel: "Vencedor Jogo 101", awayLabel: "Vencedor Jogo 102", venue: "MetLife Stadium", city: "East Rutherford"),
    ]
}
