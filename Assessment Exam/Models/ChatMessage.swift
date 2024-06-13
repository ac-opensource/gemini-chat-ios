import Foundation
import _PhotosUI_SwiftUI
import PhotosUI
import SwiftUI

enum Participant {
  case system
  case user
}

struct ChatMessage: Identifiable, Equatable {
  let id = UUID().uuidString
  var message: String
  var images: [Image]
  let participant: Participant
  var pending = false

  static func pending(participant: Participant) -> ChatMessage {
    Self(message: "", images: [], participant: participant, pending: true)
  }
}

extension ChatMessage {
  static var samples: [ChatMessage] = [
    .init(message: "Hi there! How can I help you today?", images: [], participant: .system),
    .init(message: "Could you show me a simple loop in Swift?", images: [], participant: .user),
    .init(message: """
    Absolutely! Here's an example of a basic loop in Swift:

    # Sample 1
    ```
    for number in 1...5 {
      print("Hello, world!")
    }
    ```

    This loop outputs "Hello, world!" five times. The `for` loop goes through a range from 1 to 5. The variable `number` takes on each value in this range, and the loop's code executes accordingly.

    **Here's another basic loop in Swift:**
    ```swift
    var total = 0
    for number in 1...100 {
      total += number
    }
    print("The total of numbers from 1 to 100 is \\(total).")
    ```

    This loop calculates the total sum of numbers from 1 to 100. The variable `total` starts at 0. The `for` loop iterates over each number from 1 to 100, with `number` being assigned each value. Each `number` is then added to `total`. After the loop completes, the final sum is printed.
    """, images: [], participant: .system),
  ]

  static var sample = samples[2]
}
