# Assessment Exam

This project is an iOS application that demonstrates the use of generative AI components. The app includes features such as a conversation interface, multimodal input fields, and various UI components.

## Features

- **Conversation Interface**: Interact with AI through a conversation screen.

## Project Structure

- **Models**
  - `ChatMessage`: Model representing a chat message.
- **Presentation**
  - **Screens**
    - **Conversation**
      - `ConversationViewModel`: ViewModel for managing conversation state.
      - `ConversationScreen`: View representing the conversation interface.
  - **Components**
    - `MultimodalInputField`: Custom input field supporting multiple types of input.
    - `InputField`: Basic input field.
    - `ErrorView`: View for displaying error messages.
    - `MessageView`: View for displaying chat messages.
    - `BouncingDots`: Loading animation view.
    - `ErrorDetailsView`: View for displaying detailed error messages.
- **ChatApp**
  - Main application entry point.
- **Assets**
  - Contains image assets for the app.
- **Preview Content**
  - **Preview Assets**: Assets used for SwiftUI previews.

## Dependencies

- **generative-ai-swift**: Integration with generative AI services.
- **NetworkImage**: Utility for handling images over the network.
- **swift-markdown-ui**: Markdown rendering in SwiftUI.

## Requirements

- Xcode 15.3 or later
- iOS 16.0 or later

## Installation

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/ac-opensource/gemini-chat-ios
    cd assessment-exam
    ```

2. **Open the Project in Xcode**:
    ```sh
    open Assessment\ Exam.xcodeproj
    ```
    
3. **Resolve Swift Package Dependencies**:
    - Open the project in Xcode.
    - Xcode will automatically fetch and resolve the dependencies via Swift Package Manager

## Configuration

1. **API Keys**:
    - Navigate to the `APIKey` folder.
    - Add your API keys for the generative AI services as required by the `generative-ai-swift` package.
    - A test API key is already provided but you can replace it with your own

## Running the Project

1. **Select the Target**:
    - Choose the `Assessment Exam` target from the target selector.

2. **Build and Run**:
    - Click the `Run` button (or press `Cmd + R`) to build and run the application on the simulator or a connected device.

## Screenshots


<img width="559" alt="Screenshot 2024-06-13 at 9 44 59 PM" src="https://github.com/ac-opensource/gemini-chat-ios/assets/7637791/23291619-c59a-461a-8495-a69958d5c223">

