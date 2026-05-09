//
//  GoalsView.swift
//  FPE
//

import SwiftUI

struct GoalsView: View {
    @Environment(AppViewModel.self) var viewModel
    @State private var selectedGoal: Goal? = nil

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoadingGoals {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                } else if viewModel.goals.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "star.hexagon")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Goal is empty")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.goals) { goal in
                            GoalCard(
                                goal: goal,
                                progress: viewModel.progress(for: goal)
                            )
                            .onTapGesture {
                                selectedGoal = goal
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .title) {
                    ExpandedNavigationTitle(title: "Goals")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            .sheet(item: $selectedGoal) { goal in
                GoalDetailSheet(
                    goal: goal,
                    progress: viewModel.progress(for: goal)
                )
            }
        }
    }
}

struct GoalCard: View {
    var goal: Goal
    var progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            goalImage
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                progressInfo
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var goalImage: some View {
        ZStack {
            if let urlString = goal.imageUrl,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 12,
            topTrailingRadius: 12
        ))
    }

    private var progressInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            CustomProgressBar(value: progress)
                .frame(height: 6)
                .tint(.yellow)
            let current = Int(progress * Double(goal.goalCount))
            Text("\(current) of \(goal.goalCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct GoalDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    var goal: Goal
    var progress: Double

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    goalImage
                    VStack(alignment: .leading, spacing: 12) {
                        Text(goal.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(goal.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Divider()
                        progressSection
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Goal Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var goalImage: some View {
        ZStack {
            if let urlString = goal.imageUrl,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                    }
                }
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
        .clipped()
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress")
                .font(.headline)
            CustomProgressBar(value: progress)
                .frame(height: 8)
                .tint(.yellow)
            let current = Int(progress * Double(goal.goalCount))
            HStack {
                Text("\(current) of \(goal.goalCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    GoalsView()
}
