//
//  RecentTripsView.swift
//  FPE
//

import SwiftUI

struct RecentTripsView: View {
    var recentlyAddedTrips: [Trip]

    var body: some View {
        TabView {
            ForEach(recentlyAddedTrips) { trip in
                NavigationLink {
                    TripDetailView(trip: trip)
                } label: {
                    Rectangle()
                        .fill(.background)
                        .overlay {
                            if let data = trip.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.3))
                            }
                        }
                        .clipped()
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading) {
                                Text("RECENTLY ADDED")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.yellow)

                                Text(trip.name)
                                    .font(.title)
                                    .fontWidth(.expanded)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 54)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .tabViewStyle(.page)
        .containerRelativeFrame([.horizontal, .vertical]) { length, axis in
            axis == .vertical ? length / 1.3 : length
        }
    }
}
