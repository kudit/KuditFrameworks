//
//  KuditLogo.swift
//  Tracker
//
//  Created by Ben Ku on 10/29/20.
//

import SwiftUI

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

struct KuditLogoShape: Shape {
    var ballsOnly = false
    struct Ball {
        var x: CGFloat
        var y: CGFloat
        var radius: CGFloat
        func center(for rect: CGRect) -> CGPoint {
            rect.squaring(UnitPoint(x: x, y: y))
        }
        func rect(in rect: CGRect) -> CGRect {
            let center = self.center(for: rect)
            let fullradius = rect.squareSize * radius
            return CGRect(origin: CGPoint(x: center.x - fullradius, y: center.y - fullradius), size: CGSize(width: fullradius * 2, height: fullradius * 2))
        }
    }

    let balls = [
        Ball(x: 0.69, y: 0.30, radius: 0.06), // NE
        Ball(x: 0.37, y: 0.75, radius: 0.13), // SW
        Ball(x: 0.32, y: 0.22, radius: 0.07), // NW
        Ball(x: 0.8, y: 0.54, radius: 0.1) // E
    ]

    func path(in rect: CGRect) -> Path {
        //let size = min(rect.size.width, rect.size.height)
        //let radius = size / 2
        
        //// Bezier Drawing
        var path = Path()
        if (!ballsOnly) {
            path.move(to: balls[0].center(for: rect))
            balls.forEach { ball in
                let center = ball.center(for: rect)
                path.addLine(to: center)
            }
            // draw circle outline
            let circle = Circle()
                .path(in: rect)
            path.addPath(circle)
        }
        balls.forEach { ball in
            let ballRect = ball.rect(in: rect)
            let circle = Circle()
                .path(in: ballRect)
            path.addPath(circle, transform: .init(scaleX: 1, y: 1))
        }
        return path
    }
}

struct KuditLogo: View {
    var weight: CGFloat = 1
    var body: some View {
        ZStack {
            KuditLogoShape()
                .stroke(lineWidth: weight)
                .fill(Color.accentColor)
            KuditLogoShape(ballsOnly: true)
                .fill(Color.accentColor)
        }
    }
}

struct KuditLogo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    KuditLogo()
                    //.stroke(lineWidth: 7)
                    //.fill(Color.blue)
                    KuditLogo(weight: 4)
                        .accentColor(.blue)
                    //.stroke(lineWidth: 7)
                    KuditLogo(weight: 4)
                        .accentColor(.black)
                    
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
        }
        //.previewLayout(.fixed(width: 500, height: 500   ))
    }
}