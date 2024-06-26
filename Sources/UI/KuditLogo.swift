//
//  KuditLogo.swift
//  Tracker
//
//  Created by Ben Ku on 10/29/20.
//

/*extension Path {
    mutating func addCircle(center: CGPoint, radius: CGFloat, filled: Bool = false) {
        if (filled) {
            self.move(to: center)
        }
        self.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        if (filled) {
            self.move(to: center)
        }
    }
}*/

#if canImport(SwiftUI)
import SwiftUI

public struct KuditLogoShape: Shape {
    public var ballsOnly = false
    private struct Ball {
        var x: Double
        var y: Double
        var radius: Double
        func center(for rect: CGRect) -> CGPoint {
            rect.squaring(UnitPoint(x: x, y: y))
        }
        func rect(in rect: CGRect) -> CGRect {
            let center = self.center(for: rect)
            let fullradius = rect.squareSize * radius
            return CGRect(origin: CGPoint(x: center.x - fullradius, y: center.y - fullradius), size: CGSize(width: fullradius * 2, height: fullradius * 2))
        }
    }

    private static let balls = [
        Ball(x: 0.69, y: 0.30, radius: 0.06), // NE
        Ball(x: 0.37, y: 0.75, radius: 0.13), // SW
        Ball(x: 0.32, y: 0.22, radius: 0.07), // NW
        Ball(x: 0.8, y: 0.54, radius: 0.1) // E
    ]

    public func path(in rect: CGRect) -> Path {
        //let size = min(rect.size.width, rect.size.height)
        //let radius = size / 2
        
        //// Bezier Drawing
        var path = Path()
        if (!ballsOnly) {
            path.move(to: Self.balls[0].center(for: rect))
            Self.balls.forEach { ball in
                let center = ball.center(for: rect)
                path.addLine(to: center)
            }
            // draw circle outline
            let circle = Circle()
                .path(in: rect)
            path.addPath(circle)
        }
        Self.balls.forEach { ball in
            let ballRect = ball.rect(in: rect)
            let circle = Circle()
                .path(in: ballRect)
            path.addPath(circle, transform: .init(scaleX: 1, y: 1))
        }
        return path
    }
    public init(ballsOnly: Bool = false) {
        self.ballsOnly = ballsOnly
    }
}

public struct KuditLogo: View {
    public var weight: Double
    public var color: Color
    public var body: some View {
        ZStack {
            KuditLogoShape()
                .stroke(lineWidth: weight)
                .fill(color)
            KuditLogoShape(ballsOnly: true)
                .fill(color)
        }
    }
    public init(weight: Double = 1, color: Color = .accentColor) {
        self.weight = weight
        self.color = color
    }
}

struct TestPreview: View {
    var body: some View {
        Form {
            Section {
                KuditLogo()
                //.stroke(lineWidth: 7)
                //.fill(Color.blue)
                KuditLogo(weight: 4)
                    .accentColor(.blue)
                //.stroke(lineWidth: 7)
                ColorBarTestView(colors: .rainbow)
                    .mask {
                        KuditLogo(weight: 4)
                            .padding(2)
                    }
                    .frame(size: 100)
                KuditLogo(weight: 1, color: .accentColor)
                    .frame(size: 44)
            }
            
        }.environment(\.defaultMinListRowHeight, 200)
            .navigationTitle("SwiftUI")
            .toolbar {
                HStack {
                    Button(action: {
                        print("button kudit")
                    }) {
                        KuditLogo(weight: 1)
                            .aspectRatio(1, contentMode: .fill)
                    }
                    Button(action: {
                        print("share action")
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                    }
                    Button("Hello") {
                        print("hello world")
                    }
                }
            }
        #if !os(macOS)
            .navigationViewStyle(.stack)
        #endif
            //.previewLayout(.fixed(width: 500, height: 500   ))
    }
}

struct TestWrapper: View {
    var body: some View {
        if #available(macOS 13, watchOS 9.0, tvOS 16.0, iOS 16.0, *) { // errors if macOS 13 or watchOS 9 which is what we want.
            NavigationStack {
                TestPreview()
            }
        } else {
            // Fallback on earlier versions
            NavigationView {
                TestPreview()
            }
        }
    }
}

#Preview("Tests") {
    TestWrapper()
}
#endif
