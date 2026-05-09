//
//  AddTripView.swift
//  PFE
//
//  Created by Amén on 09-05-2026.
//

import SwiftUI
import PhotosUI

struct AddTripView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var selectedCollection: TripCollection? = nil
    @State private var imageData: Data? = nil
    @State private var photosPickerItem: PhotosPickerItem? = nil
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 200)

                            if let data = imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 36))
                                        .foregroundStyle(.secondary)
                                    Text("Select Photo")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }

                Section("Trip Title") {
                    TextField("Trip Title", text: $title)
                }

                Section("Collection") {
                    if viewModel.collections.isEmpty {
                        Text("Loading...")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Collection", selection: $selectedCollection) {
                            ForEach(viewModel.collections) { collection in
                                Text(collection.name)
                                    .tag(Optional(collection))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTrip()
                    }
                    .tint(.accentColor)
                }
            }
            .alert("Please fill your trip title", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Need your trip title to save it")
            }
            .onChange(of: photosPickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .onAppear {
                if let first = viewModel.collections.first {
                    selectedCollection = first
                }
            }
            .onChange(of: viewModel.collections) { _, newCollections in
                if selectedCollection == nil, let first = newCollections.first {
                    selectedCollection = first
                }
            }
        }
    }

    private func saveTrip() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showAlert = true
            return
        }
        guard let collection = selectedCollection else {
            showAlert = true
            return
        }

        let newTrip = Trip(
            name: trimmed,
            imageData: imageData,
            collection: collection,
            activities: [],
            creationDate: Date()
        )
        viewModel.addTrip(newTrip)
        dismiss()
    }
}
