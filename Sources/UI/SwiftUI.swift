#if canImport(SwiftUI)
import SwiftUI

// MARK: - Padding and spacing

public extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

public extension View {
    func padding(size: CGFloat) -> some View {
        padding(EdgeInsets(top: size, leading: size, bottom: size, trailing: size))
    }

    func frame(size: CGFloat, alignment: Alignment = .center) -> some View {
        frame(width: size, height: size, alignment: alignment)
    }
}


// MARK: - Conditional modifier
/// https://www.avanderlee.com/swiftui/conditional-view-modifier/
public extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
public extension View {
    /// Applies the given transform.  If using a branching call, both views must be the identical type or use `AnyView(erasing: VIEWCODE)`.
    /// - Parameters:
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: The modified `View`.
    @ViewBuilder func closure<Content: View>(transform: (Self) -> Content) -> some View {
        transform(self)
    }
}

#Preview("Closure Test") {
    VStack {
        Text("Normal")
        Text("conditional inclusion")
            .closure { content in
                if #available(iOS 1, *) {
                    AnyView(erasing: content.background(.green).border(.pink, width: 4))
                } else {
                    AnyView(erasing: content.background(.blue))
                }
            }
    }
}



// MARK: - For sliders with Ints (and other binding conversions)
/// https://stackoverflow.com/questions/65736518/how-do-i-create-a-slider-in-swiftui-for-an-int-type-property
/// Slider(value: .convert(from: $count), in: 1...8, step: 1)
public extension Binding {
    static func convert<TInt, TFloat>(from intBinding: Binding<TInt>) -> Binding<TFloat> 
        where TInt:   BinaryInteger, TFloat: BinaryFloatingPoint {
            
        Binding<TFloat> (
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0) }
        )
    }
    
    static func convert<TFloat, TInt>(from floatBinding: Binding<TFloat>) -> Binding<TInt> 
        where TFloat: BinaryFloatingPoint, TInt:   BinaryInteger {
            
        Binding<TInt> (
            get: { TInt(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFloat($0) }
        )
    }
}

struct ConvertTestView: View {
    @State private var count: Int = 3
    var body: some View {
        VStack{
            HStack {
                ForEach(1...count, id: \.self) { n in
                    Text("\(n)")
                        .font(.title).bold().foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.blue)
                }
            }
            .frame(maxHeight: 64)
            HStack {
                Text("Count: \(count)")
#if os(tvOS)
                Group {
                    Button("Decrease") {
                        count--
                    }.disabled(count < 2)
                    Button("Increase") {
                        count++
                    }
                }.buttonStyle(.bordered)
#else
                Slider(value: .convert(from: $count), in: 1...8, step: 1)
#endif
            }
        }
        .padding()
    }
}
#Preview("Convert Test") {
    ConvertTestView()
}

// Support fill and stroke
public extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

public extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
public extension Image {
    static var appIcon: Image? {
        #if canImport(UIKit)
        if let image = UIImage(named: "AppIcon") {
            return Image(uiImage: image)
        }
//        // for visionOS, may have different images
//        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
//           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
//           let files = primary["CFBundleIconFiles"] as? [String],
//           let icon = files.last,
//            let image = UIImage(named: icon)
//        {
//            debug("Icons: \(icons), Primary: \(primary), Files: \(files)", level: .DEBUG)
//            return Image(uiImage: image)
//        }
        #elseif canImport(AppKit)
        if let image = NSImage(named: "AppIcon") {
            return Image(nsImage: image)
        }
        #endif
        return nil
    }
}

// MARK: - Backport Compatibility

#if os(macOS) && !targetEnvironment(macCatalyst)
public extension TabViewStyle where Self == DefaultTabViewStyle {
    // can't just name segmented because marked as explicitly unavailable
    static var pageBackport: DefaultTabViewStyle {
        return .automatic
    }
}
#else
public extension TabViewStyle where Self == PageTabViewStyle {
    // can't just name segmented because marked as explicitly unavailable
    static var pageBackport: PageTabViewStyle {
        return .page
    }
}
#endif



public extension View {
    func backgroundMaterial() -> some View {
        self
            .padding()
            .background {
                if #available(watchOS 10.0, *) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                } else {
                    // Fallback on earlier versions
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray)
                }
            }
    }
}

public extension View {
    func navigationWrapper() -> some View {
        Group {
            if #available(iOS 16, macOS 13, macCatalyst 16, tvOS 16, watchOS 9, visionOS 1, *) {
                NavigationStack {
                    self
                }
            } else {
                NavigationView {
                    self
                }
#if !os(macOS)
        .navigationViewStyle(.stack)
#endif
            }
        }
    }
}

public extension View {
    func scrollWrapper() -> some View {
        ScrollView {
            self
        }
    }
}

#Preview("Material Test") {
    ZStack {
        Color.clear
        Text("Test Material View")
            .backgroundMaterial()
    }.background(.conicGradient(colors: .rainbow, center: .center))
}

// MARK: - Menu compatibility for watchOS
#if os(watchOS)

public struct Menu<Content: View, LabelView: View>: View {
    var content: () -> Content
    var label: () -> LabelView
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> LabelView
    ) {
        self.content = content
        self.label = label
    }
    public var body: some View {
        NavigationLink(destination: {
            content().scrollWrapper()
        }, label: label)
    }
}
public extension Menu where LabelView == Text {
    init(
        _ title: some StringProtocol,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(content: content, label: {
            Text(title)
        })
    }
}
public extension Menu where LabelView == Image {
    init(
        _ title: some StringProtocol,
        symbolName: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(content: content, label: {
            Image(symbolName: symbolName)
        })
    }
}
#endif

#Preview("Watch Menu test") {
    NavigationView {
        Menu("KC") {
            ForEach(["suit.diamond", "star", "suit.spade.fill","suit.heart","suit.club","star.fill"], id: \.self) { symbol in
                Button {
                    // Perform an action here.
                    print(String(describing: symbol))
                } label: {
                    Image(systemName: symbol)
                }
            }
        }
    }
}


#endif
