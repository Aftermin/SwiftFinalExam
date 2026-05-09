//
//  TripCard.swift
//  PFE
//
//  Created by Amén on 09-05-2026.
//

import SwiftUI

struct TripCard: View {
    var trip: Trip
    var isFeatured: Bool

    var body: some View {
        if isFeatured {
            expandedCard
        } else {
            compactCard
        }
    }

    private var expandedCard: some View {
        VStack(alignment: .leading, spacing: 5) {
            tripImage(width: 325, height: 260)
            VStack(alignment: .leading, spacing: 0) {
                Text(trip.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let subtitle = trip.collection.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(2)
        }
        .frame(width: 325)
    }

    private var compactCard: some View {
        VStack(alignment: .leading, spacing: 5) {
            tripImage(width: 180, height: 260)
            Text(trip.name)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
        .frame(width: 180)
    }

    private func tripImage(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            if let data = trip.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomLeading) {
            activityTag
        }
    }

    @ViewBuilder
    private var activityTag: some View {
        if !trip.activities.isEmpty {
            let count = trip.activities.count
            Text("\(count) \(count == 1 ? "ACTIVITY" : "ACTIVITIES")")
                .font(.footnote)
                .fontWidth(.condensed)
                .foregroundStyle(.secondary)
                .padding(4)
                .background(.regularMaterial, in: .rect(cornerRadius: 8))
                .padding([.leading, .bottom], 8)
        }
    }
}
