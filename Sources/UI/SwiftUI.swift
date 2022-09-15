import SwiftUI

public extension View {
    func padding(size: CGFloat) -> some View {
        padding(EdgeInsets(top: size, leading: size, bottom: size, trailing: size))
    }

    func frame(size: CGFloat, alignment: Alignment = .center) -> some View {
        frame(width: size, height: size, alignment: alignment)
    }
}
