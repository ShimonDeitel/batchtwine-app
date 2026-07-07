import Foundation

struct CordageEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var fiber: String
    var technique: String
    var length: String
    var notes: String
    var dateCreated: Date = Date()
}
