import Foundation
import _PhotosUI_SwiftUI
import GoogleGenerativeAI
import SwiftUI

@MainActor
class ConversationViewModel: ObservableObject {
  private static let largestImageDimension = 768.0

  /// This array holds both the user's and the system's chat messages
  @Published var messages = [ChatMessage]()

  /// Indicates we're waiting for the model to finish
  @Published var busy = false

  @Published var error: Error?
  var hasError: Bool {
    return error != nil
  }

  private var model: GenerativeModel
  private var chat: Chat
  private var stopGenerating = false

  private var chatTask: Task<Void, Never>?

  init() {
    model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: APIKey.default)
    chat = model.startChat()
  }

  func sendMessage(_ text: String, images: [PhotosPickerItem], streaming: Bool = true) async {
    error = nil
    if streaming {
      await internalSendMessageStreaming(text, images: images)
    } else {
      await internalSendMessage(text)
    }
  }

  func startNewChat() {
    stop()
    error = nil
    chat = model.startChat()
    messages.removeAll()
  }

  func stop() {
    chatTask?.cancel()
    error = nil
  }

  private func internalSendMessageStreaming(_ text: String, images: [PhotosPickerItem]) async {
    chatTask?.cancel()

    chatTask = Task {
      busy = true
      defer {
        busy = false
      }

      var selectedImages: [Image] = []

      for item in images {
        if let data = try? await item.loadTransferable(type: Data.self) {
          if let uiImage = UIImage(data: data) {
            let image = Image(uiImage: uiImage)
            selectedImages.append(image)
          }
        }
      }
      
      // first, add the user's message to the chat
      let userMessage = ChatMessage(message: text, images: selectedImages, participant: .user)
      messages.append(userMessage)

      // add a pending message while we're waiting for a response from the backend
      let systemMessage = ChatMessage.pending(participant: .system)
      messages.append(systemMessage)

      var parts = [any ThrowingPartsRepresentable]()
      
      for item in images {
        if let data = try? await item.loadTransferable(type: Data.self) {
          guard let image = UIImage(data: data) else {
            continue
          }
          if image.size.fits(largestDimension: ConversationViewModel.largestImageDimension) {
            parts.append(image)
          } else {
            guard let resizedImage = image
              .preparingThumbnail(of: image.size
                .aspectFit(largestDimension: ConversationViewModel.largestImageDimension)) else {
              continue
            }

            parts.append(resizedImage)
          }
        }
      }

      do {
        let responseStream = chat.sendMessageStream(text, parts)
        for try await chunk in responseStream {
          
          messages[messages.count - 1].pending = false
          if let text = chunk.text {
            messages[messages.count - 1].message += text
          }
        }
      } catch {
        self.error = error
        print(error.localizedDescription)
        messages.removeLast()
      }
    }
  }

  private func internalSendMessage(_ text: String) async {
    chatTask?.cancel()

    chatTask = Task {
      busy = true
      defer {
        busy = false
      }

      // first, add the user's message to the chat
      let userMessage = ChatMessage(message: text, images: [], participant: .user)
      messages.append(userMessage)

      // add a pending message while we're waiting for a response from the backend
      let systemMessage = ChatMessage.pending(participant: .system)
      messages.append(systemMessage)

      do {
        var response: GenerateContentResponse?
        response = try await chat.sendMessage(text)

        if let responseText = response?.text {
          // replace pending message with backend response
          messages[messages.count - 1].message = responseText
          messages[messages.count - 1].pending = false
        }
      } catch {
        self.error = error
        print(error.localizedDescription)
        messages.removeLast()
      }
    }
  }
}

private extension CGSize {
  func fits(largestDimension length: CGFloat) -> Bool {
    return width <= length && height <= length
  }

  func aspectFit(largestDimension length: CGFloat) -> CGSize {
    let aspectRatio = width / height
    if width > height {
      let width = min(self.width, length)
      return CGSize(width: width, height: round(width / aspectRatio))
    } else {
      let height = min(self.height, length)
      return CGSize(width: round(height * aspectRatio), height: height)
    }
  }
}
