//
//  CompactTripCollectionView.swift
//  FPE
//

import SwiftUI

struct CompactTripCollectionView: View {
    var tripCollection: TripCollection
    var trips: [Trip]

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(trips) { trip in
                        NavigationLink {
                            TripDetailView(trip: trip)
                        } label: {
                            TripCard(trip: trip, isFeatured: false)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
            .scrollIndicators(.hidden, axes: .horizontal)
            .padding(.bottom, 30)
        } header: {
            VStack(alignment: .leading, spacing: 0) {
                Text(tripCollection.name)
                    .font(.title3)
                    .fontWidth(.expanded)
                if let subtitle = tripCollection.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .lineLimit(2)
        }
        .padding(.horizontal, 16)
    }
}
