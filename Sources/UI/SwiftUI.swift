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

#if !os(tvOS)
struct ConvertTestView: View {
	@State private var count: Int = 1
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
				Slider(value: .convert(from: $count), in: 1...8, step: 1)
			}
		}
		.padding()
	}
}
#Preview("Convert Test") {
	ConvertTestView()
}
#endif
