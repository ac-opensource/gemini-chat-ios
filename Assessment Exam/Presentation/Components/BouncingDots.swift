import SwiftUI

struct BouncingDots: View {
  @State
  private var dot1YOffset: CGFloat = 0.0

  @State
  private var dot2YOffset: CGFloat = 0.0

  @State
  private var dot3YOffset: CGFloat = 0.0

  let animation = Animation.easeInOut(duration: 0.8)
    .repeatForever(autoreverses: true)

  var body: some View {
    HStack(spacing: 8) {
      Circle()
        .fill(Color.white)
        .frame(width: 10, height: 10)
        .offset(y: dot1YOffset)
        .onAppear {
          withAnimation(self.animation.delay(0.0)) {
            self.dot1YOffset = -5
          }
        }
      Circle()
        .fill(Color.white)
        .frame(width: 10, height: 10)
        .offset(y: dot2YOffset)
        .onAppear {
          withAnimation(self.animation.delay(0.2)) {
            self.dot2YOffset = -5
          }
        }
      Circle()
        .fill(Color.white)
        .frame(width: 10, height: 10)
        .offset(y: dot3YOffset)
        .onAppear {
          withAnimation(self.animation.delay(0.4)) {
            self.dot3YOffset = -5
          }
        }
    }
    .onAppear {
      let baseOffset: CGFloat = -2

      self.dot1YOffset = baseOffset
      self.dot2YOffset = baseOffset
      self.dot3YOffset = baseOffset
    }
  }
}

struct BouncingDots_Previews: PreviewProvider {
  static var previews: some View {
    BouncingDots()
      .frame(width: 200, height: 50)
      .background(.blue)
      .roundedCorner(10, corners: [.allCorners])
  }
}
