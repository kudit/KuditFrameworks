import SwiftUI

public extension View {
    func padding(size: CGFloat) -> some View {
        padding(EdgeInsets(top: size, leading: size, bottom: size, trailing: size))
    }
}
