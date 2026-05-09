//
//  TripCollection.swift
//  FPE
//

import Foundation

struct TripCollection: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var subtitle: String?
    var season: String
    var isFeatured: Bool = false

    enum CodingKeys: String, CodingKey {
        case name
        case subtitle
        case season
        case isFeatured
    }

    init(id: UUID = UUID(), name: String, subtitle: String? = nil, season: String, isFeatured: Bool = false) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.season = season
        self.isFeatured = isFeatured
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.season = try container.decode(String.self, forKey: .season)
        self.isFeatured = try container.decodeIfPresent(Bool.self, forKey: .isFeatured) ?? false
    }
}
