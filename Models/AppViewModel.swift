import SwiftUI

@Observable
@MainActor
class AppViewModel {

    private let tripsKey = "saved_trips"

    var trips: [Trip] = []
    var collections: [TripCollection] = []
    var goals: [Goal] = []
    var isLoadingCollections = false
    var isLoadingGoals = false

    @ObservationIgnored
    @AppStorage("saved_trips") private var tripsData: Data = Data()

    init() {
        loadTrips()
        Task {
            await fetchCollections()
            await fetchGoals()
        }
    }

    var recentlyAddedTrips: [Trip] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
        return trips.filter { $0.creationDate >= cutoff }
    }

    func addTrip(_ trip: Trip) {
        trips.append(trip)
        saveTrips()
    }

    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
        saveTrips()
    }

    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            saveTrips()
        }
    }

    func addActivity(to tripID: UUID, name: String) {
        guard let index = trips.firstIndex(where: { $0.id == tripID }) else { return }
        let activity = Activity(name: name, isComplete: false)
        trips[index].activities.append(activity)
        saveTrips()
    }

    func updateActivity(in tripID: UUID, activity: Activity) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripID }),
              let actIndex = trips[tripIndex].activities.firstIndex(where: { $0.id == activity.id })
        else { return }
        trips[tripIndex].activities[actIndex] = activity
        saveTrips()
    }

    func deleteActivity(in tripID: UUID, activityID: UUID) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripID }) else { return }
        trips[tripIndex].activities.removeAll { $0.id == activityID }
        saveTrips()
    }

    func toggleActivity(in tripID: UUID, activityID: UUID) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripID }),
              let actIndex = trips[tripIndex].activities.firstIndex(where: { $0.id == activityID })
        else { return }
        trips[tripIndex].activities[actIndex].isComplete.toggle()
        saveTrips()
    }

    func progress(for goal: Goal) -> Double {
        let relevant: [Trip]
        if let season = goal.seasonCondition {
            relevant = trips.filter {
                $0.collection.season.lowercased() == season.lowercased()
            }
        } else {
            relevant = trips
        }

        let current: Int
        switch goal.type {
        case "activities":
            current = relevant.flatMap { $0.activities }.filter { $0.isComplete }.count
        case "trips":
            current = relevant.count
        default:
            current = 0
        }

        guard goal.goalCount > 0 else { return 0 }
        return min(Double(current) / Double(goal.goalCount), 1.0)
    }

    private func saveTrips() {
        if let encoded = try? JSONEncoder().encode(trips) {
            tripsData = encoded
        }
    }

    private func loadTrips() {
        guard !tripsData.isEmpty,
              let decoded = try? JSONDecoder().decode([Trip].self, from: tripsData)
        else { return }
        trips = decoded
    }

    private let apiKey = "IOS-PFE-2026"
    private let baseURL = "https://ios-pfe.poommomo.workers.dev"

    func fetchCollections() async {
        isLoadingCollections = true
        defer { isLoadingCollections = false }

        guard let url = URL(string: "\(baseURL)/trip_collections") else { return }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let decoded = try? JSONDecoder().decode([TripCollection].self, from: data)
        else { return }

        collections = decoded
    }

    func fetchGoals() async {
        isLoadingGoals = true
        defer { isLoadingGoals = false }

        guard let url = URL(string: "\(baseURL)/goals") else { return }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let decoded = try? JSONDecoder().decode([Goal].self, from: data)
        else { return }

        goals = decoded
    }
}
