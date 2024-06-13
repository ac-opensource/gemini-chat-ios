import GoogleGenerativeAI
import MarkdownUI
import SwiftUI

extension SafetySetting.HarmCategory: CustomStringConvertible {
  public var description: String {
    switch self {
    case .dangerousContent: "Dangerous content"
    case .harassment: "Harassment"
    case .hateSpeech: "Hate speech"
    case .sexuallyExplicit: "Sexually explicit"
    case .unknown: "Unknown"
    case .unspecified: "Unspecified"
    }
  }
}

extension SafetyRating.HarmProbability: CustomStringConvertible {
  public var description: String {
    switch self {
    case .high: "High"
    case .low: "Low"
    case .medium: "Medium"
    case .negligible: "Negligible"
    case .unknown: "Unknown"
    case .unspecified: "Unspecified"
    }
  }
}

private struct SubtitleFormRow: View {
  var title: String
  var value: String

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.subheadline)
      Text(value)
    }
  }
}

private struct SubtitleMarkdownFormRow: View {
  var title: String
  var value: String

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.subheadline)
      Markdown(value)
    }
  }
}

private struct SafetyRatingsSection: View {
  var ratings: [SafetyRating]

  var body: some View {
    Section("Safety ratings") {
      List(ratings, id: \.self) { rating in
        HStack {
          Text("\(String(describing: rating.category))")
            .font(.subheadline)
          Spacer()
          Text("\(String(describing: rating.probability))")
        }
      }
    }
  }
}

struct ErrorDetailsView: View {
  var error: Error

  var body: some View {
    NavigationView {
      Form {
        switch error {
        case let GenerateContentError.internalError(underlying: underlyingError):
          Section("Error Type") {
            Text("Internal error")
          }

          Section("Details") {
            SubtitleFormRow(title: "Error description",
                            value: underlyingError.localizedDescription)
          }

        case let GenerateContentError.promptBlocked(response: generateContentResponse):
          Section("Error Type") {
            Text("Your prompt was blocked")
          }

          Section("Details") {
            if let reason = generateContentResponse.promptFeedback?.blockReason {
              SubtitleFormRow(title: "Reason for blocking", value: reason.rawValue)
            }

            if let text = generateContentResponse.text {
              SubtitleMarkdownFormRow(title: "Last chunk for the response", value: text)
            }
          }

          if let ratings = generateContentResponse.candidates.first?.safetyRatings {
            SafetyRatingsSection(ratings: ratings)
          }

        case let GenerateContentError.responseStoppedEarly(
          reason: finishReason,
          response: generateContentResponse
        ):

          Section("Error Type") {
            Text("Response stopped early")
          }

          Section("Details") {
            SubtitleFormRow(title: "Reason for finishing early", value: finishReason.rawValue)

            if let text = generateContentResponse.text {
              SubtitleMarkdownFormRow(title: "Last chunk for the response", value: text)
            }
          }

          if let ratings = generateContentResponse.candidates.first?.safetyRatings {
            SafetyRatingsSection(ratings: ratings)
          }

        case GenerateContentError.invalidAPIKey:
          Section("Error Type") {
            Text("Invalid API Key")
          }

          Section("Details") {
            SubtitleFormRow(title: "Error description", value: error.localizedDescription)
            SubtitleMarkdownFormRow(
              title: "Help",
              value: """
              Please provide a valid value for `API_KEY` in the `GenerativeAI-Info.plist` file.
              """
            )
          }

        case GenerateContentError.unsupportedUserLocation:
          Section("Error Type") {
            Text("Unsupported User Location")
          }

          Section("Details") {
            SubtitleFormRow(title: "Error description", value: error.localizedDescription)
            SubtitleMarkdownFormRow(
              title: "Help",
              value: """
              The API is unsupported in your location (country / territory); please see the list of
              [available regions](https://ai.google.dev/available_regions#available_regions).
              """
            )
          }

        default:
          Section("Error Type") {
            Text("Some other error")
          }

          Section("Details") {
            SubtitleFormRow(title: "Error description", value: error.localizedDescription)
          }
        }
      }
      .navigationTitle("Error details")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview("Response Stopped Early") {
  let error = GenerateContentError.responseStoppedEarly(
    reason: .maxTokens,
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
      finishReason: FinishReason.maxTokens,
      citationMetadata: nil),
    ],
    promptFeedback: nil)
  )

  return ErrorDetailsView(error: error)
}

#Preview("Prompt Blocked") {
  let error = GenerateContentError.promptBlocked(
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

  return ErrorDetailsView(error: error)
}

#Preview("Invalid API Key") {
  ErrorDetailsView(error: GenerateContentError.invalidAPIKey(message: "Fix API key placeholder"))
}

#Preview("Unsupported User Location") {
  ErrorDetailsView(error: GenerateContentError.unsupportedUserLocation)
}
