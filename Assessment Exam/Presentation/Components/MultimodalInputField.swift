import PhotosUI
import SwiftUI

public struct MultimodalInputField<Label>: View where Label: View {
  @Binding public var text: String
  @Binding public var selection: [PhotosPickerItem]
  private var label: () -> Label

  @Environment(\.submitHandler) var submitHandler

  @State private var selectedImages = [Image]()

  @State private var isChooseAttachmentTypePickerShowing = false
  @State private var isAttachmentPickerShowing = false

  private func showChooseAttachmentTypePicker() {
    isChooseAttachmentTypePickerShowing.toggle()
  }

  private func showAttachmentPicker() {
    isAttachmentPickerShowing.toggle()
  }

  private func submit() {
    if let submitHandler {
      submitHandler()
    }
  }

  public init(text: Binding<String>,
              selection: Binding<[PhotosPickerItem]>,
              @ViewBuilder label: @escaping () -> Label) {
    _text = text
    _selection = selection
    self.label = label
  }

  public var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .top) {
        Button(action: showChooseAttachmentTypePicker) {
          Image(systemName: "plus")
        }
        .padding(.top, 10)

        VStack(alignment: .leading) {
          TextField(
            "Upload an image, and then ask a question about it",
            text: $text,
            axis: .vertical
          )
          .padding(.vertical, 4)
          .onSubmit(submit)

          if selectedImages.count > 0 {
            ScrollView(.horizontal) {
              LazyHStack {
                ForEach(0 ..< selectedImages.count, id: \.self) { i in
                  HStack {
                    selectedImages[i]
                      .resizable()
                      .scaledToFill()
                      .frame(width: 50, height: 50)
                      .cornerRadius(8)
                  }
                }
              }
            }
            .frame(height: 50)
          }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .overlay {
          RoundedRectangle(
            cornerRadius: 8,
            style: .continuous
          )
          .stroke(Color(UIColor.systemFill), lineWidth: 1)
        }

        Button(action: submit, label: label)
          .padding(.bottom, 4)
      }
    }
    .padding(.horizontal)
    .confirmationDialog(
      "Select an image",
      isPresented: $isChooseAttachmentTypePickerShowing,
      titleVisibility: .hidden
    ) {
      Button(action: showAttachmentPicker) {
        Text("Photo & Video Library")
      }
    }
    .photosPicker(isPresented: $isAttachmentPickerShowing, selection: $selection)
    .onChange(of: selection) { _ in
      Task {
        selectedImages.removeAll()

        for item in selection {
          if let data = try? await item.loadTransferable(type: Data.self) {
            if let uiImage = UIImage(data: data) {
              let image = Image(uiImage: uiImage)
              selectedImages.append(image)
            }
          }
        }
      }
    }
  }
}

#Preview {
  struct Wrapper: View {
    @State var userInput: String = ""
    @State var selectedItems = [PhotosPickerItem]()

    @State private var selectedImages = [Image]()

    var body: some View {
      MultimodalInputField(text: $userInput, selection: $selectedItems) {
        Image(systemName: "arrow.up.circle.fill")
          .font(.title)
      }
        .onChange(of: selectedItems) { _ in
          Task {
            selectedImages.removeAll()

            for item in selectedItems {
              if let data = try? await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                  let image = Image(uiImage: uiImage)
                  selectedImages.append(image)
                }
              }
            }
          }
        }

      List {
        ForEach(0 ..< $selectedImages.count, id: \.self) { i in
          HStack {
            selectedImages[i]
              .resizable()
              .scaledToFill()
              .frame(width: .infinity)
              .cornerRadius(8)
          }
        }
      }
    }
  }

  return Wrapper()
}
