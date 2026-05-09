//
//  WishlistView.swift
//  FPE
//

import SwiftUI

struct WishlistView: View {
    @Environment(AppViewModel.self) var viewModel
    @State private var showAddTrip = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !viewModel.recentlyAddedTrips.isEmpty {
                        RecentTripsView(recentlyAddedTrips: viewModel.recentlyAddedTrips)
                            .padding(.bottom, 20)
                    }

                    if viewModel.trips.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "mountain.2")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                                .padding(.top, 100)
                            Text("No list in your wishlist")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Press + for add your first Trip")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        ForEach(viewModel.collections) { collection in
                            let tripsInCollection = viewModel.trips.filter {
                                $0.collection.name == collection.name
                            }
                            if !tripsInCollection.isEmpty {
                                if collection.isFeatured {
                                    ExpandedTripCollectionView(
                                        tripCollection: collection,
                                        trips: tripsInCollection
                                    )
                                } else {
                                    CompactTripCollectionView(
                                        tripCollection: collection,
                                        trips: tripsInCollection
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.never)
            .contentMargins(.bottom, 30, for: .scrollContent)
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .title) {
                    ExpandedNavigationTitle(title: "Wishlist")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTrip = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(.accentColor)
                }
            }
            .navigationTitle("Travel Wishlist")
            .toolbarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .sheet(isPresented: $showAddTrip) {
                AddTripView()
            }
        }
        
    }
}

#Preview {
    WishlistView()
}
