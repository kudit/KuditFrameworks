//
//  KuditLogo.swift
//  Tracker
//
//  Created by Ben Ku on 10/29/20.
//

import SwiftUI

extension Path {
	mutating func addCircle(center: CGPoint, radius: CGFloat, filled: Bool = false) {
		self.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
		if (filled) {
			self.closeSubpath()
		}
	}
}

struct KuditLogo: Shape {
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
		Ball(x: 0.69, y: 0.41, radius: 0.06),
		Ball(x: 0.37, y: 0.75, radius: 0.13),
		Ball(x: 0.22, y: 0.32, radius: 0.07),
		Ball(x: 0.8, y: 0.54, radius: 0.1)
	]

	func path(in rect: CGRect) -> Path {
		let size = min(rect.size.width, rect.size.height)
		let radius = size / 2
		

		//// Bezier Drawing
		var path = Path()
		path.move(to: balls[0].center(for: rect))
		balls.forEach { ball in
			path.addLine(to: ball.center(for: rect))
		}
		balls.forEach { ball in
			path.move(to: ball.center(for: rect))
			path.addEllipse(in: ball.rect(in: rect))
		}
		// draw circle outline
		path.move(to: CGPoint(x: rect.center.x + radius, y: rect.center.y))
		path.addCircle(center: rect.center, radius: radius, filled: true)
		return path
	}
}

struct KuditLogo_Previews: PreviewProvider {
    static var previews: some View {
		KuditLogo()
			.stroke(lineWidth: 5)
//			.fill(Color.blue)
			.padding(10)
			.previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/500.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/500.0/*@END_MENU_TOKEN@*/))
    }
}
