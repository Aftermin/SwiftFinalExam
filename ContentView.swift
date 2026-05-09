import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) var viewModel

    var body: some View {
        TabView {
            Tab("Wishlist", systemImage: "mountain.2") {
                WishlistView()
            }
            Tab("Goals", systemImage: "star.hexagon") {
                GoalsView()
            }
        }
    }
}
