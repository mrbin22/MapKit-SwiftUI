
import Foundation

struct StationModel: Codable {
    let response: Response
}

// MARK: - Response
struct Response: Codable {
    let station: [Station]
}

// MARK: - Station
struct Station: Codable, Hashable {
    let name, prefecture, line: String
    let x, y: Double
    let postal, distance: String
    let prev: String?
    let next: String
}
