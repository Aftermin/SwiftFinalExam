import SwiftUI

struct TripDetailView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.dismiss) var dismiss

    var trip: Trip

    @State private var showAddActivity = false
    @State private var editingActivity: Activity? = nil
    @State private var sortOption: SortOption = .dateDescending
    @State private var showDeleteTripAlert = false

    enum SortOption: String, CaseIterable {
        case dateDescending = "ล่าสุดก่อน"
        case completedFirst = "เสร็จแล้วก่อน"
        case incompleteFirst = "ยังไม่เสร็จก่อน"
    }

    var currentTrip: Trip {
        viewModel.trips.first { $0.id == trip.id } ?? trip
    }

    var sortedActivities: [Activity] {
        switch sortOption {
        case .dateDescending:
            return currentTrip.activities.sorted { $0.creationDate > $1.creationDate }
        case .completedFirst:
            return currentTrip.activities.sorted { $0.isComplete && !$1.isComplete }
        case .incompleteFirst:
            return currentTrip.activities.sorted { !$0.isComplete && $1.isComplete }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                tripImage
                progressSection
                activitiesHeader
                activitiesList
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .navigationTitle(currentTrip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteTripAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .alert("Do you want to delete this trip", isPresented: $showDeleteTripAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteTrip(currentTrip)
                dismiss()
            }
            Button("Cancle", role: .cancel) {}
        } message: {
            Text("All data of \(currentTrip.name) will be deleted.")
        }
        .sheet(isPresented: $showAddActivity) {
            ActivityFormView(tripID: currentTrip.id, existingActivity: nil)
        }
        .sheet(item: $editingActivity) { activity in
            ActivityFormView(tripID: currentTrip.id, existingActivity: activity)
        }
    }

    private var tripImage: some View {
        ZStack {
            if let data = currentTrip.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(Int(currentTrip.completionRate * 100))%")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Activity Progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            CustomProgressBar(value: currentTrip.completionRate)
                .frame(height: 8)
                .tint(.accentColor)
        }
        .padding(.horizontal)
    }

    private var activitiesHeader: some View {
        HStack {
            Text("Activities")
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            sortMenu
            Button {
                showAddActivity = true
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.horizontal)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundStyle(Color.accentColor)
        }
    }

    private var activitiesList: some View {
        Group {
            if sortedActivities.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("Activity is empty")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(sortedActivities) { activity in
                        ActivityRow(
                            activity: activity,
                            onToggle: {
                                viewModel.toggleActivity(
                                    in: currentTrip.id,
                                    activityID: activity.id
                                )
                            },
                            onEdit: {
                                editingActivity = activity
                            },
                            onDelete: {
                                viewModel.deleteActivity(
                                    in: currentTrip.id,
                                    activityID: activity.id
                                )
                            }
                        )
                        if activity.id != sortedActivities.last?.id {
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
}

struct ActivityRow: View {
    var activity: Activity
    var onToggle: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                onToggle()
            } label: {
                Image(systemName: activity.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(activity.isComplete ? Color.accentColor : .secondary)
            }
            .buttonStyle(.plain)

            Text(activity.name)
                .font(.body)
                .foregroundStyle(activity.isComplete ? .secondary : .primary)
                .strikethrough(activity.isComplete, color: .secondary)

            Spacer()

            Menu {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct ActivityFormView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.dismiss) var dismiss

    var tripID: UUID
    var existingActivity: Activity?

    @State private var name = ""
    @State private var showAlert = false

    var isEditing: Bool { existingActivity != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    TextField("Activity title", text: $name)
                }
            }
            .navigationTitle(isEditing ? "Edit Activity" : "Add New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                    }
                    .tint(.accentColor)
                }
            }
            .alert("Please provide a name for the Activity", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Activity name cannot be empty")
            }
            .onAppear {
                if let activity = existingActivity {
                    name = activity.name
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showAlert = true
            return
        }
        if var activity = existingActivity {
            activity.name = trimmed
            viewModel.updateActivity(in: tripID, activity: activity)
        } else {
            viewModel.addActivity(to: tripID, name: trimmed)
        }
        dismiss()
    }
}
