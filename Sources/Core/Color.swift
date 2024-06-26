//
//  Color.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/26/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

// http://arstechnica.com/apple/2009/02/iphone-development-accessing-uicolor-components/

public protocol KuColor: Codable, Equatable {
    /// usually 0-1 double values but SwiftUI supports extended colors beyond 0-1
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
    func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool
    func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool
    func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool
        
    // named colors
    associatedtype UnderlyingColorType: KuColor // cannot use Self because UIColor is non-final.  But apparently Swift compiler can infer this type without having to manually define it! :)
    static var black: UnderlyingColorType { get }
    static var blue: UnderlyingColorType { get }
    static var brown: UnderlyingColorType { get }
    static var clear: UnderlyingColorType { get }
    static var cyan: UnderlyingColorType { get }
    static var gray: UnderlyingColorType { get }
    static var green: UnderlyingColorType { get }
    static var indigo: UnderlyingColorType { get }
    static var mint: UnderlyingColorType { get }
    static var orange: UnderlyingColorType { get }
    static var pink: UnderlyingColorType { get }
    static var purple: UnderlyingColorType { get }
    static var red: UnderlyingColorType { get }
    static var teal: UnderlyingColorType { get }
    static var white: UnderlyingColorType { get }
    static var yellow: UnderlyingColorType { get }
    // Kudit Added
    static var magenta: UnderlyingColorType { get }
    static var lightGray: UnderlyingColorType { get }
    static var darkGray: UnderlyingColorType { get }
}


// the LosslessStringConvertible extension does not work for KuColor since a color may be initialized by a string but the corresponding unlabelled init function is not the one we want.
public extension KuColor {
    init(string: String?, defaultColor: Self) {
        guard let string else {
            self = defaultColor
            return
        }
        guard let color = Self(string: string) else {
            self = defaultColor
            return
        }
        self = color
    }
}


#if canImport(UIKit)
import UIKit
extension UIColor: KuColor {
    public static var indigo: UIColor {
#if os(watchOS)
        return UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
#else
        return .systemPurple
#endif
    }

    public static var mint: UIColor {
#if os(watchOS)
        return UIColor(red: 0/255, green: 199/255, blue: 190/255, alpha: 1)

#else
        return .systemMint
#endif
    }

    public static var pink: UIColor {
#if os(watchOS)
        return UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)

#else
        return .systemPink
#endif
    }

    public static var teal: UIColor {
#if os(watchOS)
        return UIColor(red: 48/255, green: 176/255, blue: 199/255, alpha: 1)

#else
        return .systemTeal
#endif
    }
}
public extension KuColor {
    var uiColor: UIColor {
        let components = rgbaComponents
        return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
    }
}
public extension UIColor {
    // for coding assistance
    func asData() throws -> Data {
        return try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
    }
    convenience init?(_ data: Data) {
        guard let c = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return nil
        }
        // init with values
        self.init(red: c.redComponent, green: c.greenComponent, blue: c.blueComponent, alpha: c.alphaComponent)
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI
public extension KuColor {
    typealias DefaultColorType = Color
}
extension Color: KuColor {
    public static var lightGray: Color {
        return .init(string: "#CBCBCB", defaultColor: .white)
    }
    
    public static var darkGray: Color {
        return .init(string: "#515151", defaultColor: .black)
    }
    
    public static var magenta: Color {
        return .init(red: 1, green: 0, blue: 1, alpha: 1)
    }

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        self.init(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }
    
    public func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        // Switch for built-in colors
        let zero = CGFloat(0.0)
        let black = (red: zero, green: zero, blue: zero, alpha: zero)
        var rgba = black
        switch self {
        case .blue:
            rgba = (red: 0/255, green: 112/255, blue: 255/255, alpha: 1)
        case .brown:
            rgba = (red: 162/255, green: 132/255, blue: 94/255, alpha: 1)
        case .clear:
            rgba = (red: 0, green: 0, blue: 0, alpha: 0)
        case .cyan:
            rgba = (red: 50/255, green: 173/255, blue: 230/255, alpha: 1)
        case .gray:
            rgba = (red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
        case .lightGray:
            rgba = (red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        case .darkGray:
            rgba = (red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        case .green:
            rgba = (red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
        case .indigo:
            rgba = (red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
        case .mint:
            rgba = (red: 0/255, green: 199/255, blue: 190/255, alpha: 1)
        case .orange:
            rgba = (red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        case .pink:
            rgba = (red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        case .purple:
            rgba = (red: 175/255, green: 82/255, blue: 222/255, alpha: 1)
        case .red:
            rgba = (red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        case .teal:
            rgba = (red: 48/255, green: 176/255, blue: 199/255, alpha: 1)
        case .white: // seems to work already
            rgba = (red: 1, green: 1, blue: 1, alpha: 1)
        case .yellow:
            rgba = (red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        default:
            break
            // nothing.  Default to black.
            // Impossible to calculate for accentColor/primary/secondary/.  Perhaps return something else?
            //print("Unable to determine SwiftUI Color: \(color)")
        }
        if rgba != black {
            // try using defined values first from above
            red?.pointee = rgba.red
            green?.pointee = rgba.green
            blue?.pointee = rgba.blue
            alpha?.pointee = rgba.alpha
            return true
        }
        
        guard let cgColor = cgColor, let components = cgColor.components, components.count >= 3 else {
            return false
        }
        
        red?.pointee = components[0]
        green?.pointee = components[1]
        blue?.pointee = components[2]
        alpha?.pointee = cgColor.alpha
        return true
    }
    
    public func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        guard let cgColor = cgColor, let components = cgColor.components, components.count == 2 else {
            return false
        }
        
        white?.pointee = components[0]
        alpha?.pointee = cgColor.alpha
        return true
    }
    
    public func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        // SwiftUI color will almost guaranteed not be in HSB color space so return false so we can convert from RGB
        return false
//        guard let cgColor = cgColor, let components = cgColor.components, components.count >= 3 else {
//            return false
//        }
//
//        hue?.pointee = components[0]
//        saturation?.pointee = components[1]
//        brightness?.pointee = components[2]
//        alpha?.pointee = 1.0 // SwiftUI colors do not support Alpha Channel
//        return true
    }
}
#elseif canImport(UIKit)
public extension KuColor {
    typealias DefaultColorType = UIColor
}
#else // Add in functions to make sure KuColor functions work even in non-UI environments
public extension KuColor {
    typealias DefaultColorType = Color
}
// create a Color struct that can be used to store color data
public struct Color: KuColor {
    // all values should be 0-1
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat
    
    // functions to get around native implementation change with no return
    public func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        if var red {
            red.pointee = self.red
        }
        if var green {
            green.pointee = self.green
        }
        if var blue {
            blue.pointee = self.blue
        }
        if var alpha {
            alpha.pointee = self.alpha
        }
        return true
    }
    
    public func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        if var white {
            white.pointee = (self.red + self.green + self.blue) / 3
        }
        if var alpha {
            alpha.pointee = self.alpha
        }
        return true
    }
    
    public func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        // use KuColor calculations of HSB
        let components = hsbComponents
        if var hue {
            hue.pointee = components.hue
        }
        if var saturation {
            saturation.pointee = components.saturation
        }
        if var brightness {
            brightness.pointee = components.brightness
        }
        if var alpha {
            alpha.pointee = self.alpha
        }
        return true
    }
}
#endif

public extension KuColor {
    // TODO: Standardize 255
    //    static let eightBitDenominator = 255.0
    // MARK: Get RGB Colors
    /// returns the RGBA values of the color if it can be determined and black-clear if not.
    var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        get {
            let zero = CGFloat(0.0)
            var rgba = (red: zero, green: zero, blue: zero, alpha: zero)
            if getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha) {
                return rgba
            }
            var white = zero
            var alpha = zero
            if getWhite(&white, alpha: &alpha) {
                rgba.red = white // assign brightness to RGB
                rgba.green = white // assign brightness to RGB
                rgba.blue = white // assign brightness to RGB
                rgba.alpha = alpha // same alpha
            }
            //print("Unable to get rgba components of \(self)")
            return rgba
        }
    }
    /// Red component value between 0 and 1
    var redComponent: CGFloat {
        return rgbaComponents.red
    }
    /// Green component value between 0 and 1
    var greenComponent: CGFloat {
        return rgbaComponents.green
    }
    /// Blue component value between 0 and 1
    var blueComponent: CGFloat {
        return rgbaComponents.blue
    }
    /// Alpha component value between 0 and 1
    var alphaComponent: CGFloat {
        return rgbaComponents.alpha
    }
    
    var hsbComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        //print("\(self) HSB COMPONENTS")
        let zero = CGFloat(0.0)
        var hsb = (hue: zero, saturation: zero, brightness: zero)
        if getHue(&hsb.hue, saturation: &hsb.saturation, brightness: &hsb.brightness, alpha: nil) {
            return hsb
        }
        //hsb.saturation = 1.0
        //_ = getWhite(&hsb.brightness, alpha: nil)
        
        // attempt to convert from RGBA
        // based off of https://gist.github.com/FredrikSjoberg/cdea97af68c6bdb0a89e3aba57a966ce
        let rgba = rgbaComponents
        let r = rgba.red
        let g = rgba.green
        let b = rgba.blue
        let min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        let max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else {
            //print("Delta \(self) too small \(min) | \(max)")
            // hue difference is negligable, so likely a grayscale color
            return (0, 0, max) }
        guard max > 0 else {
            //print("Max \(self) too small \(max)")
            return (-1, 0, v) } // Undefined, achromatic grey
        let s = delta / max
        let hue: (CGFloat, CGFloat) -> CGFloat = { max, delta -> CGFloat in
            if r == max { return (g-b)/delta } // between yellow & magenta
            else if g == max { return 2 + (b-r)/delta } // between cyan & yellow
            else { return 4 + (r-g)/delta } // between magenta & cyan
        }
        
        var h = hue(max, delta) * 60 // In degrees
        // make sure not less than 0 and then scale to 0-1
        h = (h < 0 ? h+360 : h) / 360
        hsb = (h,s,v)
        //print("\(self) calculated HSB: \(hsb)")
        return hsb
    }
    var hueComponent: CGFloat {
        return hsbComponents.hue
    }
    var saturationComponent: CGFloat {
        return hsbComponents.saturation
    }
    var brightnessComponent: CGFloat {
        return hsbComponents.brightness
    }
    
    /// can use to convert between KuColor protocol objects like UIColor or SwiftUI Color.
    init(color: any KuColor) {
        self.init(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
    }
}

#if canImport(SwiftUI)
import SwiftUI

let DEFAULT_CONTENT = EmptyView()
struct Swatch: View {
    var color: Color
    var logo: Bool = false
    init(color: Color, logo: Bool = false) {
        self.color = color
        self.logo = logo
    }
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .frame(size: 50)
            .foregroundColor(color)
            .overlay {
                ZStack {
                    if logo {
                        Image(systemName: "applelogo")
                            .imageScale(.large)
                    } else {
                        Text("\(self.color.hexString)")
                            .bold()
                    }
                }
                .foregroundColor(color.contrastingColor) // isDark ? .white : .black
            }
    }
}
struct SwatchTest: View {
    var color: Color
    var body: some View {
        Swatch(color: color, logo: true)
    }
}
struct HSVConversionTestView: View {
    public var body: some View {
        VStack {
            Text("HSV Conversion")
            ForEach([Color].rainbow, id: \.self) { color in
                HStack(spacing: 0) {
                    // primary named colors
                    SwatchTest(color: color)
                    // css conversion tests
                    SwatchTest(color: color.rgbConverted)
                    // hsv conversion tests
                    SwatchTest(color: color.hsvConverted)
                    // rgb converted tests
                    SwatchTest(color: color.cssConverted)
                }
            }
        }
    }
}

#Preview("HSV Conversion") {
    HSVConversionTestView()
}
#endif


// MARK: - Comparisons

// adding equatable conformance for colors
public extension KuColor {
    static func ==(lhs:Self, rhs:Self) -> Bool {
        return lhs.redComponent == rhs.redComponent
        && lhs.greenComponent == rhs.greenComponent
        && lhs.blueComponent == rhs.blueComponent
        && lhs.alphaComponent == rhs.alphaComponent
    }
    
    // Converted values for testing/comparing
    var hsvConverted: Self {
        let hsb = self.hsbComponents
        return Self(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: self.alphaComponent)
    }
    var rgbConverted: Self {
        let rgba = self.rgbaComponents
        return Self(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
    var cssConverted: Self {
        return Self(string: self.cssString, defaultColor: Self(red: 0, green: 0, blue: 0, alpha: 0))
    }
}

#if canImport(SwiftUI)
import SwiftUI

public extension KuColor {
    
    // MARK: brightness qualifiers
    var isDark: Bool {
        if hueComponent == 0 && saturationComponent == 1 {
            return brightnessComponent < 0.5
        } else {
            return brightnessComponent < 0.5 || redComponent + greenComponent + blueComponent < 1.5 // handle "pure" colors
        }
    }
    var isLight: Bool {
        return !isDark
    }
    
    // MARK: Highlighting Colors
    private func _colorWithBrightness(multiplier: CGFloat) -> Self {
        var hsb = hsbComponents
        //print("HSB: \(hsb)")
        hsb.brightness *= multiplier
        return Self(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: alphaComponent)
    }
    
    var darkerColor: Self {
        return _colorWithBrightness(multiplier: 0.5)
    }
    
    var lighterColor: Self {
        return _colorWithBrightness(multiplier: 2)
    }
    // https://dallinjared.medium.com/swiftui-tutorial-contrasting-text-over-background-color-2e7af57c1b20
    /// Returns the luminance value which is `0.2126*red + 0.7152*green + 0.0722*blue`
    var luminance: Double {
        return 0.2126 * self.redComponent + 0.7152 * self.greenComponent + 0.0722 * self.blueComponent
    }
    /// returns either white or black depending on the base color to make sure it's visible against the background.  In the future we may want to change this to some sort of vibrancy.  Note, if you're using this on accentColor on a view that has changed the tint, will give a contrassting color for the Asset color named "AccentColor" and not the actual color value since actual color values can't be read.
    var contrastingColor: Color {
#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        // Fix so primary color - dark mode shows black
        if let color = self as? Color, color == .primary || color == .secondary {
            return Color(UIColor.systemBackground)
        }
        if let color = self as? Color, color == .accentColor {
            // pull from assets rather than from the color which will just return a blue color
            if let uiColor = UIColor(named: "AccentColor") {
                return uiColor.contrastingColor
            }
        } 
#endif
        //        return isDark ? .white : .black
        return luminance < 0.6 ? .white : .black
    }
}

struct ColorTintingTestView: View {
    public var body: some View {
        VStack {
            Text("Color Tinting")
            HStack {
                ForEach([Color].rainbow, id: \.self) { color in
                    VStack {
                        Swatch(color: color.lighterColor)
                        Swatch(color: color)
                        Swatch(color: color.darkerColor)
                    }
                }
            }
        }
    }
}
#Preview("Color Tinting") {
    ColorTintingTestView()
}

struct LightnessTestView: View {
    var body: some View {
        VStack {
            Text("Lightness Tests")
                .bold()
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    SwatchTest(color: .red)
                    SwatchTest(color: .orange)
                    SwatchTest(color: .yellow)
                    SwatchTest(color: .green)
                    SwatchTest(color: .blue)
                    SwatchTest(color: .purple)
                }
                VStack(spacing: 0) {
                    SwatchTest(color: Color(string:Color.red.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.orange.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.yellow.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.green.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.blue.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.purple.hexString) ?? .black)
                }
                VStack(spacing: 0) {
                    SwatchTest(color: .white)
                    SwatchTest(color: .lightGray)
                    SwatchTest(color: Color(string: "Gray") ?? .white)
                    SwatchTest(color: .gray)
                    SwatchTest(color: .darkGray)
                    SwatchTest(color: .black)
                }
                VStack(spacing: 0) {
                    
                    SwatchTest(color: .accentColor)
                    SwatchTest(color: .primary)
                    SwatchTest(color: .secondary)
                    SwatchTest(color: Color(string:"SkyBlue") ?? .black)
                    SwatchTest(color: Color(string:"Beige") ?? .black)
                    SwatchTest(color: Color(string:"LightGray") ?? .black)
                }
                VStack(spacing: 0) {
                    SwatchTest(color: Color(string:Color.pink.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.brown.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.mint.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.teal.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.cyan.hexString) ?? .black)
                    SwatchTest(color: Color(string:Color.indigo.hexString) ?? .black)
                }
                VStack(spacing: 0) {
                    SwatchTest(color: .pink)
                    SwatchTest(color: .brown)
                    SwatchTest(color: .mint)
                    SwatchTest(color: .teal)
                    SwatchTest(color: .cyan)
                    SwatchTest(color: .indigo)
                }
            }
            
        }.padding().background(.gray)
    }
}

#Preview("Lightness Tests") {
    LightnessTestView()
}


#endif

// MARK: - CSS/String intialization

public extension KuColor {
    // MARK: Codable
    // Kudit Codable conformance (simplified) based off of
    //https://gist.github.com/ConfusedVorlon/276bd7ac6c41a99ea0514a34ee9afc3d?permalink_comment_id=4096859#gistcomment-4096859
    init(from decoder: Decoder) throws {
        if let data = try? Data(from: decoder) {
            // likely data representation of UIColor
#if canImport(UIKit)
            guard let color = UIColor(data) else {
                throw DecodingError.dataCorruptedError(
                    in: try decoder.singleValueContainer(),
                    debugDescription: "Invalid Color Data"
                )
            }
            // convert in case this is actually a SwiftUI Color initing from a UIColor as in ShoutIt legacy data
            self.init(color: color)
#else
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Decoding color from data is not supported in macOS without catalyst."
            )
#endif
        } else if let string = try? String(from: decoder) {
            guard let color = Color(string: string) else {
                throw DecodingError.dataCorruptedError(
                    in: try decoder.singleValueContainer(),
                    debugDescription: "Invalid Color String \"\(string)\""
                )
            }
            self.init(color: color)
        } else {
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Could not decode Color"
            )
        }
        //        let data = try container.decode(Data.self)
        //        guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
        //            throw DecodingError.dataCorruptedError(
        //                in: container,
        //                debugDescription: "Invalid color"
        //            )
        //        }
        //        wrappedValue = color
        //
        //        else if let data = try? UIColor
        //        } else if let data = try? Data(from: decoder), let uiColor = UIColor(data)
        //
        //        }
        // TODO: check to see if we can value decode this?  • Unable to decode Color data: Foundation.(unknown context at $181152d90).JSONDecoderImpl
        //decoder.singleValueContainer().decode()
        throw CustomError("Unable to decode Color data: \(String(describing: decoder))")
        //        self.init(string: string)!
    }
    
    // for coding
    func encode(to encoder: Encoder) throws {
        try pretty.encode(to: encoder)
    }
    
    
    // MARK: Parsing and Rendering
    static var namedColorMap: [String:String] {[
        "AliceBlue":"#F0F8FF",
        "AntiqueWhite":"#FAEBD7",
        "Aqua":"#00FFFF",
        "Aquamarine":"#7FFFD4",
        "Azure":"#F0FFFF",
        "Beige":"#F5F5DC",
        "Bisque":"#FFE4C4",
        "Black":"#000000",
        "BlanchedAlmond":"#FFEBCD",
        "Blue":"#0000FF",
        "BlueViolet":"#8A2BE2",
        "Brown":"#A52A2A",
        "BurlyWood":"#DEB887",
        "CadetBlue":"#5F9EA0",
        "Chartreuse":"#7FFF00",
        "Chocolate":"#D2691E",
        "Coral":"#FF7F50",
        "CornflowerBlue":"#6495ED",
        "Cornsilk":"#FFF8DC",
        "Crimson":"#DC143C",
        "Cyan":"#00FFFF",
        "DarkBlue":"#00008B",
        "DarkCyan":"#008B8B",
        "DarkGoldenRod":"#B8860B",
        "DarkGray":"#A9A9A9",
        "DarkGreen":"#006400",
        "DarkKhaki":"#BDB76B",
        "DarkMagenta":"#8B008B",
        "DarkOliveGreen":"#556B2F",
        "DarkOrange":"#FF8C00",
        "DarkOrchid":"#9932CC",
        "DarkRed":"#8B0000",
        "DarkSalmon":"#E9967A",
        "DarkSeaGreen":"#8FBC8F",
        "DarkSlateBlue":"#483D8B",
        "DarkSlateGray":"#2F4F4F",
        "DarkTurquoise":"#00CED1",
        "DarkViolet":"#9400D3",
        "DeepPink":"#FF1493",
        "DeepSkyBlue":"#00BFFF",
        "DimGray":"#696969",
        "DodgerBlue":"#1E90FF",
        "FireBrick":"#B22222",
        "FloralWhite":"#FFFAF0",
        "ForestGreen":"#228B22",
        "Fuchsia":"#FF00FF",
        "Gainsboro":"#DCDCDC",
        "GhostWhite":"#F8F8FF",
        "Gold":"#FFD700",
        "GoldenRod":"#DAA520",
        "Gray":"#808080",
        "Green":"#008000",
        "GreenYellow":"#ADFF2F",
        "HoneyDew":"#F0FFF0",
        "HotPink":"#FF69B4",
        "IndianRed":"#CD5C5C",
        "Indigo":"#4B0082",
        "Ivory":"#FFFFF0",
        "Khaki":"#F0E68C",
        "Lavender":"#E6E6FA",
        "LavenderBlush":"#FFF0F5",
        "LawnGreen":"#7CFC00",
        "LemonChiffon":"#FFFACD",
        "LightBlue":"#ADD8E6",
        "LightCoral":"#F08080",
        "LightCyan":"#E0FFFF",
        "LightGoldenRodYellow":"#FAFAD2",
        "LightGray":"#D3D3D3",
        "LightGreen":"#90EE90",
        "LightPink":"#FFB6C1",
        "LightSalmon":"#FFA07A",
        "LightSeaGreen":"#20B2AA",
        "LightSkyBlue":"#87CEFA",
        "LightSlateGray":"#778899",
        "LightSteelBlue":"#B0C4DE",
        "LightYellow":"#FFFFE0",
        "Lime":"#00FF00",
        "LimeGreen":"#32CD32",
        "Linen":"#FAF0E6",
        "Magenta":"#FF00FF",
        "Maroon":"#800000",
        "MediumAquaMarine":"#66CDAA",
        "MediumBlue":"#0000CD",
        "MediumOrchid":"#BA55D3",
        "MediumPurple":"#9370DB",
        "MediumSeaGreen":"#3CB371",
        "MediumSlateBlue":"#7B68EE",
        "MediumSpringGreen":"#00FA9A",
        "MediumTurquoise":"#48D1CC",
        "MediumVioletRed":"#C71585",
        "MidnightBlue":"#191970",
        "MintCream":"#F5FFFA",
        "MistyRose":"#FFE4E1",
        "Moccasin":"#FFE4B5",
        "NavajoWhite":"#FFDEAD",
        "Navy":"#000080",
        "OldLace":"#FDF5E6",
        "Olive":"#808000",
        "OliveDrab":"#6B8E23",
        "Orange":"#FFA500",
        "OrangeRed":"#FF4500",
        "Orchid":"#DA70D6",
        "PaleGoldenRod":"#EEE8AA",
        "PaleGreen":"#98FB98",
        "PaleTurquoise":"#AFEEEE",
        "PaleVioletRed":"#DB7093",
        "PapayaWhip":"#FFEFD5",
        "PeachPuff":"#FFDAB9",
        "Peru":"#CD853F",
        "Pink":"#FFC0CB",
        "Plum":"#DDA0DD",
        "PowderBlue":"#B0E0E6",
        "Purple":"#800080",
        "RebeccaPurple":"#663399",
        "Red":"#FF0000",
        "RosyBrown":"#BC8F8F",
        "RoyalBlue":"#4169E1",
        "SaddleBrown":"#8B4513",
        "Salmon":"#FA8072",
        "SandyBrown":"#F4A460",
        "SeaGreen":"#2E8B57",
        "SeaShell":"#FFF5EE",
        "Sienna":"#A0522D",
        "Silver":"#C0C0C0",
        "SkyBlue":"#87CEEB",
        "SlateBlue":"#6A5ACD",
        "SlateGray":"#708090",
        "Snow":"#FFFAFA",
        "SpringGreen":"#00FF7F",
        "SteelBlue":"#4682B4",
        "Tan":"#D2B48C",
        "Teal":"#008080",
        "Thistle":"#D8BFD8",
        "Tomato":"#FF6347",
        "Turquoise":"#40E0D0",
        "Violet":"#EE82EE",
        "Wheat":"#F5DEB3",
        "White":"#FFFFFF",
        "WhiteSmoke":"#F5F5F5",
        "Yellow":"#FFFF00",
        "YellowGreen":"#9ACD32"]}
    
    /**
     KF: Creates a Color from the given string in #HEX format, named CSS string, rgb(), or rgba() format.  Important to have named parameter string: to differentiate from SwiftUI Color(_:String) init from a named color in an asset bundle.
     
     - Parameter string: The string to be converted.
     
     - Returns: A new color or`nil` if we cannot parse the string.
     */
    init?(string: String) {
        var source = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if source.contains("#") {
            // TODO: Consolidate with ColorCodable version
            // decode hex
            source = source.removing(characters: "#").uppercased()
            
            // String should be 6 or 3 characters
            guard source.count == 6 || source.count == 3 else {
                debug("Unknown color string: \(string)", level: DebugLevel.colorLogging ? .WARNING : .SILENT)
                return nil
            }
            let shortForm = (source.count == 3)
            
            // Separate into r, g, b substrings
            var range = NSRange(location: 0, length: (shortForm == true ? 1 : 2))
            var rString = source.substring(with: range)
            range.location += range.length
            var gString = source.substring(with: range)
            range.location += range.length
            var bString = source.substring(with: range)
            
            // expand short form
            if shortForm {
                rString += rString
                gString += gString
                bString += bString
            }
            
            // Scan values
            var r: UInt64 = 0
            var g: UInt64 = 0
            var b: UInt64 = 0
            Scanner(string: rString).scanHexInt64(&r)
            Scanner(string: gString).scanHexInt64(&g)
            Scanner(string: bString).scanHexInt64(&b)
            
            self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
        } else if source.contains("rgba(") || source.contains("rgb(") {
            // css rgb color style
            let includesAlpha = string.contains("rgba(")
            
            // decode RGBA
            source = source.replacingOccurrences(of: ["rgba(","rgb(",")"," "], with: "")
            
            // Separate into components by removing commas and spaces
            let components = source.components(separatedBy: ",")
            if (components.count != 4 && includesAlpha) || (components.count != 3 && !includesAlpha) {
                debug("Invalid color: \(string)", level: .DEBUG)
                return nil
            }
            
            let componentValues = components.map { Double($0) }
            
            // make sure cast succeeded
            for value in componentValues {
                guard value != nil else {
                    print("Could not parse rgb value: \(string)")
                    return nil
                }
            }
            
            // Create the color
            var alphaValue:CGFloat = 1.0
            if includesAlpha {
                guard let componentAlpha = componentValues[3] else {
                    debug("Could not parse alpha value: \(components[3])", level: !DebugLevel.colorLogging ? .SILENT : .DEBUG)
                    return nil
                }
                alphaValue = CGFloat(componentAlpha)
            }
            // determine if 0—1 double value or a 255 number
            if components[0].contains(".") {
                self.init(red: CGFloat(componentValues[0]!),
                          green: CGFloat(componentValues[1]!),
                          blue: CGFloat(componentValues[2]!),
                          alpha: alphaValue)
            } else {
                self.init(red: CGFloat(componentValues[0]!)/255.0,
                          green: CGFloat(componentValues[1]!)/255.0,
                          blue: CGFloat(componentValues[2]!)/255.0,
                          alpha: alphaValue)
            }
        } else {
            // check for HTML/CSS named colors.
            // might be a CSS color string
            for (colorName, hex) in Self.namedColorMap {
                if colorName.lowercased() == source { // source is already lowercased above
                    self.init(string: hex)
                    return
                }
            }
            debug("Unknown named color: \(string)", level: !DebugLevel.colorLogging ? .SILENT : .NOTICE)
            return nil
        }
    }
    
    /// Returns a string in the form rgba(R,G,B,A) (should be URL safe as well). Will drop the alpha if it is 1.0 and do rgb(R,G,B) in double numbers from 0 to 255.
    var cssString: String {
        let components = rgbaComponents
        let eightBits = "\(Int(components.red*255.0)),\(Int(components.green*255.0)),\(Int(components.blue*255.0))"
        let opaque = components.alpha == 1.0
        let alphaComponentString = opaque ? "" : ",\(components.alpha)"
        let string = "rgb\(opaque ? "" : "a")(\(eightBits)\(alphaComponentString))"
        //print(string)
        return string
    }
    
    var hexString: String {
        let components = rgbaComponents
        var r = components.red
        var g = components.green
        var b = components.blue
        
        // Fix range if needed
        if r < 0.0 { r = 0.0 }
        if g < 0.0 { g = 0.0 }
        if b < 0.0 { b = 0.0 }
        
        if r > 1.0 { r = 1.0 }
        if g > 1.0 { g = 1.0 }
        if b > 1.0 { b = 1.0 }
        
        // Convert to hex string between 0x00 and 0xFF (rounding so very close to FF goes to FF rather than being floored to FE).
        return String(format: "#%02X%02X%02X", Int(round(r * 255.0)), Int(round(g * 255.0)), Int(round(b * 255.0)))
    }
    /// Returns the "nicest" version of the color that we can.  If there is a named color, we use that.  If HEX is available, use that, otherwise, use rgb or rgba versions if there is extended color space or alpha..
    var pretty: String {
        guard alphaComponent == 1.0 else {
            return cssString
        }
        guard let hexColor = Self(string: hexString) else {
            // unable to initialize color from the converted hexString.  This should not be possible.
            debug("Unable to convert color \(self) to hexString \(self.hexString) and back.", level: .ERROR)
            return cssString
        }
        // convert to hex and make sure converting back gets the same numbers (otherwise, it's probably an extended color space)
        guard hexColor == self else {
            debug("This color can't be represented as hex: \(self) != \(hexColor) (saving as: \(cssString))", level: !DebugLevel.colorLogging ? .SILENT : .NOTICE)
            return cssString
        }
        // we should show named color names if available
        if let colorName = Self.namedColorMap.firstKey(for: hexString) {
            return colorName
        } else {
            return hexString
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

struct NamedColorsListTestView: View {
    public var body: some View {
        List {
            ForEach(Color.namedColorMap.sorted(by: <), id: \.key) { key, value in
                let color = Color(string: key, defaultColor: .black)
                HStack {
                    Text(key)
                    Spacer()
                    Text(value)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(color)
                }
                .foregroundStyle(color.contrastingColor)
            }
        }
    }
}

#Preview("Named Colors") {
    NamedColorsListTestView()
}

struct ColorPrettyTestView: View {
    public var body: some View {
        VStack {
            Text("Pretty output of various colors.")
                .font(.title)
            Text("red -> \"\(Color(string: "red", defaultColor: .black).pretty)\"")
            Text("red rgb -> \"\(Color(red: 1, green: 0, blue: 0, alpha: 1).pretty)\"")
            Text("red alpha color -> \"\(Color(red: 1, green: 0, blue: 0, alpha: 0.5).pretty)\"")
            Text("red rgba -> \"\(Color(string: "rgba(255,0,0,0.5)", defaultColor: .black).pretty)\"")
            Text("red hex -> \"\(Color(string: "#F00", defaultColor: .black).pretty)\"")
            Text("red rgb expanded -> \"\(Color(red: 1.1, green: 0, blue: 0, alpha: 1).pretty)\"")
            Text("white -> \"\(Color.white.pretty)\"")
            Text("black -> \"\(Color.black.pretty)\"")
        }
    }
}

#Preview("Pretty Text") {
    ColorPrettyTestView()
}

#endif


// MARK: - Colorsets/groups
// doesn't really make sense directly on color since it's not a color, it's a set of colors
//public extension KuColor where UnderlyingColorType == Self {
//    static var rainbow: [UnderlyingColorType] { [Self].rainbow }
//    static var prioritized: [Self] { [Self].prioritized }
//    static var named: [UnderlyingColorType] { [Self].named }
//    static var grayscale: [UnderlyingColorType] { [Self].grayscale }
//}
public extension Array where Element: KuColor, Element.UnderlyingColorType == Element {
    /// ROYGBIV(purple for violet)
    static var rainbow: [Element] { [.red, .orange, .yellow, .green, .blue, .indigo, .purple] }
    /// Primary colors, secondary colors, tertiary colors
    static var prioritized: [Element] { [.red, .green, .blue, .yellow, .magenta, .cyan, .orange, .purple, .mint, .indigo, .brown] }
    /// All Apple named colors (adds cyan and magenta)
    static var named: [Element] { [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .magenta, .pink, .brown, .clear, .gray, .black, .white] }
    /// Grayscale colors from white to black
    static var grayscale: [Element] { [.white, .lightGray, .gray, .darkGray, .black] }
}
// MARK: DOT Colors
public extension KuColor where UnderlyingColorType == Self {
    //     Blue - 294
    /// Services
    static var dotBlue: Self { .init(string: "rgb(0,63,135)", defaultColor: .black ) }
    //     Brown - 469
    /// Recreational
    static var dotBrown: Self { .init(string: "rgb(96,51,17)", defaultColor: .black ) }
    //     Green - 342
    /// Location guide, direction guidance
    static var dotGreen: Self { .init(string: "rgb(0,107,84)", defaultColor: .black ) }
    //     Green-Colored Pavement - 802
    /// Bicycle Lanes
    static var dotGreenPavement: Self { .init(string: "rgb(96,221,73)", defaultColor: .black ) }
    //     Orange - 152
    /// temporary traffic control
    static var dotOrange: Self { .init(string: "rgb(221,117,0)", defaultColor: .black ) }
    //     Pink - 198
    /// Incident Management
    static var dotPink: Self { .init(string: "rgb(119,45,53)", defaultColor: .black ) }
    //     Purple - 259
    /// Toll collection
    static var dotPurple: Self { .init(string: "rgb(114,22,107)", defaultColor: .black ) }
    //     Red - 187
    /// stop or prohibition
    static var dotRed: Self { .init(string: "rgb(175,30,45)", defaultColor: .black ) }
    //     Red-Colored Pavement - 485
    /// Transit Only
    static var dotRedPavement: Self { .init(string: "rgb(216,30,5)", defaultColor: .black ) }
    //     Yellow - 116
    /// Warning
    static var dotYellow: Self { .init(string: "rgb(252,209,22)", defaultColor: .black ) }
    //     Yellow-Green - 382
    /// Pedestrian warning
    static var dotYellowGreen: Self { .init(string: "rgb(186,216,10)", defaultColor: .black ) }
}

public extension Array where Element: KuColor, Element.UnderlyingColorType == Element {
    /// DOT Colors
    static var dotColors: [Element] { [.dotBlue, .dotBrown, .dotGreen, .dotGreenPavement, .dotOrange, .dotPink, .dotPurple, .dotRed, .dotRedPavement, .dotYellow, .dotYellowGreen] }
    
    /// A list of named color sets for debugging/picking.  Can't just use dictionary since we care about the order.
    static var namedColorsets: [(String, [Element])] {
        return [
            ("Rainbow", [Element].rainbow),
            ("Prioritized", .prioritized),
            ("Named", .named),
            ("Grayscale", .grayscale),
            ("DOT", .dotColors),
        ]
    }
}

public extension KuColor {
    /// For quickly initializing a color using the nth item in a colorset.  Extension of KuColor so we can type . and start initializing for autocomplete.
    static func nth(_ nth: Int, of colorset: [Self]) -> Self {
        return colorset[nth: nth]
    }
}

#if canImport(SwiftUI)
import SwiftUI

public struct ColorBarTestView: View {
    public var text: String?
    public var colors: [Color]
    // auto-generated doesn't work externally.  need to explicitly define so can be public.
    public init(text: String? = nil, colors: [Color]) {
        self.text = text
        self.colors = colors
    }
    public var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    color
                }
            }
            if let text {
                Text(text)
                    .font(.title).bold()
                    .foregroundStyle(.white)
                    .shadow(radius: 1)
            }
        }
    }
}

struct ColorsetsTestView: View {
    var colorsets = [Color].namedColorsets
    public var body: some View {
        VStack {
            ForEach(colorsets.indices, id: \.self) { index in
                let (label, colorset) = colorsets[index]
                ColorBarTestView(text: label, colors: colorset)
            }
        }
    }
}

#Preview("Colorsets") {
    ColorsetsTestView()
}

#endif

#if canImport(SwiftUI)
import SwiftUI

public struct ColorTestView: View {
    public init() {}
    public var body: some View {
        TabView {
            ColorsetsTestView()
            HSVConversionTestView()
            LightnessTestView()
            ColorPrettyTestView()
            NamedColorsListTestView()
            ColorTintingTestView()
        }
        .tabViewStyle(.pageBackport)
    }
}

#Preview("All Tests") {
    ColorTestView()
}

#endif
