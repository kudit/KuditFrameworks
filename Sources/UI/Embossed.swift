#if canImport(SwiftUI)
import SwiftUI

struct EmbossedModifier: ViewModifier {
    @State var offset = 4.0
    @State var blur = 4.0
    @State var lightColor = Color.white.opacity(0.5)
    @State var darkColor = Color.black.opacity(0.5)
    func body(content: Content) -> some View {
        content
            .shadow(color: darkColor, radius: blur, x: offset, y: offset)
            .shadow(color: lightColor, radius: blur, x: -offset, y: -offset)
    }
}

public extension View {
    func embossed(offset: Double = 4.0, blur: Double = 4.0) -> some View {
        modifier(EmbossedModifier(offset: offset, blur: blur))
    }
}

#Preview("Embossed") {
    ZStack {
        Color.yellow
        Circle()
            .fill(.yellow)
            .embossed(blur: 0)
            .padding()
            .padding()
            .padding()
    }
}
#endif
