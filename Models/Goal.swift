//
//  Goal.swift
//  FPE
//

import Foundation

struct Goal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var imageUrl: String?
    var goalCount: Int
    var type: String
    var seasonCondition: String?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case imageUrl
        case goalCount
        case type
        case seasonCondition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.goalCount = try container.decode(Int.self, forKey: .goalCount)
        self.type = try container.decode(String.self, forKey: .type)
        self.seasonCondition = try container.decodeIfPresent(String.self, forKey: .seasonCondition)
    }
}
