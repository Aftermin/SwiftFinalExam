//
//  Trip.swift
//  FPE
//

import Foundation

struct Trip: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var imageData: Data?
    var collection: TripCollection
    var activities: [Activity]
    var creationDate: Date = Date()

    var completionRate: Double {
        guard !activities.isEmpty else { return 0.0 }
        return Double(activities.filter { $0.isComplete }.count) / Double(activities.count)
    }
}
