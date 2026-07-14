import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [CordageEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 23

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("batchtwine_entries.json")
    }()

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    func seed() {
        entries = [
        CordageEntry(name: "Dogbane Cord", fiber: "Dogbane", technique: "Reverse wrap", length: "12 ft", notes: "Strong, thin, for snares"),
        CordageEntry(name: "Yucca Fiber Rope", fiber: "Yucca leaf", technique: "Two-ply twist", length: "20 ft", notes: "Retted 3 days first"),
        CordageEntry(name: "Nettle Twine", fiber: "Stinging nettle", technique: "Drop spindle", length: "8 ft", notes: "Fine gauge, for jewelry")
        ]
        save()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(name: String, fiber: String, technique: String, length: String, notes: String) {
        guard canAddMore else { return }
        let entry = CordageEntry(name: name, fiber: fiber, technique: technique, length: length, notes: notes)
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: CordageEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: CordageEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([CordageEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
