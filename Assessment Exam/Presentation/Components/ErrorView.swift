import GoogleGenerativeAI
import SwiftUI

struct ErrorView: View {
  var error: Error
  @State private var isDetailsSheetPresented = false
  var body: some View {
    HStack {
      Text("An error occurred.")
      Button(action: { isDetailsSheetPresented.toggle() }) {
        Image(systemName: "info.circle")
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .listRowSeparator(.hidden)
    .sheet(isPresented: $isDetailsSheetPresented) {
      ErrorDetailsView(error: error)
    }
  }
}

#Preview {
  NavigationView {
    let errorPromptBlocked = GenerateContentError.promptBlocked(
      response: GenerateContentResponse(candidates: [
        CandidateResponse(content: ModelContent(role: "model", [
          """
            A _hypothetical_ model response.
            Cillum ex aliqua amet aliquip labore amet eiusmod consectetur reprehenderit sit commodo.
          """,
        ]),
        safetyRatings: [
          SafetyRating(category: .dangerousContent, probability: .high),
          SafetyRating(category: .harassment, probability: .low),
          SafetyRating(category: .hateSpeech, probability: .low),
          SafetyRating(category: .sexuallyExplicit, probability: .low),
        ],
        finishReason: FinishReason.other,
        citationMetadata: nil),
      ],
      promptFeedback: nil)
    )
    List {
      MessageView(message: ChatMessage.samples[0])
      MessageView(message: ChatMessage.samples[1])
      ErrorView(error: errorPromptBlocked)
    }
    .listStyle(.plain)
    .navigationTitle("Chat sample")
  }
}
