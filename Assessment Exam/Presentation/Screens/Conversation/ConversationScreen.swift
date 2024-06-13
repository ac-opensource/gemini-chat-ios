import GoogleGenerativeAI
import PhotosUI
import SwiftUI

struct ConversationScreen: View {
  @EnvironmentObject
  var viewModel: ConversationViewModel

  @State
  private var userPrompt = ""

  @State
  private var selectedItems = [PhotosPickerItem]()

  enum FocusedField: Hashable {
    case message
  }

  @FocusState
  var focusedField: FocusedField?

  var body: some View {
    VStack {
      ScrollViewReader { scrollViewProxy in
        List {
          ForEach(viewModel.messages) { message in
            MessageView(message: message)
          }
          if let error = viewModel.error {
            ErrorView(error: error)
              .tag("errorView")
          }
        }
        .listStyle(.plain)
        .onChange(of: viewModel.messages, perform: { newValue in
          if viewModel.hasError {
            // wait for a short moment to make sure we can actually scroll to the bottom
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              withAnimation {
                scrollViewProxy.scrollTo("errorView", anchor: .bottom)
              }
              focusedField = .message
            }
          } else {
            guard let lastMessage = viewModel.messages.last else { return }

            // wait for a short moment to make sure we can actually scroll to the bottom
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              withAnimation {
                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
              }
              focusedField = .message
            }
          }
        })
      }
      MultimodalInputField(text: $userPrompt, selection: $selectedItems) {
        Image(systemName: viewModel.busy ? "stop.circle.fill" : "arrow.up.circle.fill")
          .font(.title)
      }
        .focused($focusedField, equals: .message)
        .onSubmit {
          sendOrStop()
        }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(action: newChat) {
          Image(systemName: "square.and.pencil")
        }
      }
    }
    .navigationTitle("Sample Chat App")
    .onAppear {
      focusedField = .message
    }
  }

  private func sendMessage() {
    Task {
      let prompt = userPrompt
      let images = selectedItems
      userPrompt = ""
      selectedItems.removeAll()
      await viewModel.sendMessage(prompt, images: images, streaming: true)
    }
  }

  private func sendOrStop() {
    focusedField = nil

    if viewModel.busy {
      viewModel.stop()
    } else {
      sendMessage()
    }
  }

  private func newChat() {
    viewModel.startNewChat()
  }
}

struct ConversationScreen_Previews: PreviewProvider {
  struct ContainerView: View {
    @StateObject var viewModel = ConversationViewModel()

    var body: some View {
      ConversationScreen()
        .environmentObject(viewModel)
        .onAppear {
          viewModel.messages = ChatMessage.samples
        }
    }
  }

  static var previews: some View {
    NavigationStack {
      ConversationScreen()
    }
  }
}
