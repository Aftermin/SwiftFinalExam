import SwiftUI

@main
struct MyApp: App {
    @State private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
