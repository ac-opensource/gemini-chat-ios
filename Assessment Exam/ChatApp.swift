import SwiftUI

@main
struct ChatApp: App {
  @StateObject
  var viewModel = ConversationViewModel()

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        ConversationScreen()
          .environmentObject(viewModel)
      }
    }
  }
}
