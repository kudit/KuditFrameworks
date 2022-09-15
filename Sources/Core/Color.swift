//
//  Color.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/26/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

// http://arstechnica.com/apple/2009/02/iphone-development-accessing-uicolor-components/

public protocol KuColor {
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
    func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool
    func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool
    func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool
}

#if canImport(UIKit)
import UIKit
extension UIColor: KuColor {}
#endif

#if canImport(SwiftUI)
import SwiftUI
extension Color: KuColor {
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: red, green: green, blue: blue)
        // SwiftUI colors do not support Alpha Channel
    }
    
    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        self.init(hue: hue, saturation: saturation, brightness: brightness)
        // SwiftUI colors do not support Alpha Channel
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
            // try using defined values first
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
        alpha?.pointee = 1.0 // SwiftUI colors do not support Alpha Channel
        return true
    }

    public func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        guard let cgColor = cgColor, let components = cgColor.components, components.count == 2 else {
            return false
        }
        
        white?.pointee = components[0]
        alpha?.pointee = 1.0 // SwiftUI colors do not support Alpha Channel
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
#elseif !canImport(UIKit) // Add in functions to make sure they're available on KuColor protocol
public extension KuColor {
    // functions to get around native implementation change with no return
    public func getRed(_ red: UnsafeMutablePointer<CGFloat>?, green: UnsafeMutablePointer<CGFloat>?, blue: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        let _:Void = getRed(red, green: green, blue: blue, alpha: alpha)
        return true
    }
    
    public func getWhite(_ white: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        let _:Void = getWhite(white, alpha: alpha)
        return true
    }
    
    public func getHue(_ hue: UnsafeMutablePointer<CGFloat>?, saturation: UnsafeMutablePointer<CGFloat>?, brightness: UnsafeMutablePointer<CGFloat>?, alpha: UnsafeMutablePointer<CGFloat>?) -> Bool {
        let _:Void = getHue(hue, saturation: saturation, brightness: brightness, alpha: alpha)
        return true
    }
}
#endif


public extension KuColor {
    // MARK: - Get RGB Colors
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
    var redComponent: CGFloat {
        return rgbaComponents.red
    }
    var greenComponent: CGFloat {
        return rgbaComponents.green
    }
    var blueComponent: CGFloat {
        return rgbaComponents.blue
    }
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

    // MARK: - Parsing and Rendering
    /*
     init?(data: Data) {
        if let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NativeColorType.self, from: data) {
            //if let color = NSKeyedUnarchiver.unarchiveObject(with: data) as? Color {
            self.init(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
        } else {
            return nil
        }
    }*/ // Re-implement if necessary, but probably use the Codable protocol versions
    init?(string: String) {
        var source = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if source.contains("#") {
            // TODO: Consolidate with ColorCodable version
            // decode hex
            source = source.removing(characters: "#").uppercased()
            
            // String should be 6 or 3 characters
            guard source.count == 6 || source.count == 3 else {
                print("Unknown color string: \(string)")
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
                print("Invalid color: \(string)")
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
                    print("Could not parse alpha value: \(components[3])")
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
            let map = [
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
                "YellowGreen":"#9ACD32"]
            // might be a CSS color string
            for (key, value) in map {
                if key.lowercased() == source {
                    self.init(string: value)
                    return
                }
            }
            print("Unknown named color: \(string)")
            return nil
        }
    }

    /// Returns a string in the form rgba(R,G,B,A) (should be URL safe as well).
    var cssString: String {
        let components = rgbaComponents
        let string = "rgba(\(Int(components.red*255.0)),\(Int(components.green*255.0)),\(Int(components.blue*255.0)),\(components.alpha))"
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

        // Convert to hex string between 0x00 and 0xFF
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    // MARK: - brightness qualifiers
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

    // MARK: - Highlighting Colors
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
    
    // TESTS
    fileprivate var hsvTest: Color {
        let hsb = self.hsbComponents
        return Color(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness, alpha: self.alphaComponent)
    } 
    fileprivate var rgbTest: Color {
        return Color(string: self.cssString) ?? .black
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
                }.foregroundColor(color.isDark ? .white : .black)
            }
    }
}
struct SwatchTest: View {
    var color: Color
    var body: some View {
        Swatch(color: color, logo: false)
    }
}
struct Color_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Color Tinting")
            Swatch(color: .red.lighterColor)
            Swatch(color: .red)
            Swatch(color: .red.darkerColor)
            Swatch(color: .green.lighterColor)
            Swatch(color: .green)
            Swatch(color: .green.darkerColor)
        }
        VStack {
            Text("HSV Conversion")
            HStack {
                VStack(spacing: 0) {
                    SwatchTest(color: .red)
                    SwatchTest(color: .orange)
                    SwatchTest(color: .yellow)
                    SwatchTest(color: .green)
                    SwatchTest(color: .blue)
                    SwatchTest(color: .purple)
                }
                VStack(spacing: 0) {
                    SwatchTest(color: .red.rgbTest)
                    SwatchTest(color: .orange.rgbTest)
                    SwatchTest(color: .yellow.rgbTest)
                    SwatchTest(color: .green.rgbTest)
                    SwatchTest(color: .blue.rgbTest)
                    SwatchTest(color: .purple.rgbTest)
                }
                VStack(spacing: 0) {
                    SwatchTest(color: .red.hsvTest)
                    SwatchTest(color: .orange.hsvTest)
                    SwatchTest(color: .yellow.hsvTest)
                    SwatchTest(color: .green.hsvTest)
                    SwatchTest(color: .blue.hsvTest)
                    SwatchTest(color: .purple.hsvTest)
                }
                VStack(spacing: 0) {
                    SwatchTest(color: .red.hsvTest.rgbTest)
                    SwatchTest(color: .orange.hsvTest.rgbTest)
                    SwatchTest(color: .yellow.hsvTest.rgbTest)
                    SwatchTest(color: .green.hsvTest.rgbTest)
                    SwatchTest(color: .blue.hsvTest.rgbTest)
                    SwatchTest(color: .purple.hsvTest.rgbTest)
                }
            }
        }
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
                    SwatchTest(color: Color(string: "#ccc") ?? .black)
                    SwatchTest(color: Color(string: "Gray") ?? .white)
                    SwatchTest(color: .gray)
                    SwatchTest(color: Color(string: "#333") ?? .white)
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
#endif
