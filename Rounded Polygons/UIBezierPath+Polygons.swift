//
//  UIBezierPath+Polygons.swift
//  Rounded Polygons
//
//  Created by Louis D'hauwe on 24/11/15.
//  Copyright © 2015 Silver Fox. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {

	private func addPointsAsRoundedPolygon(points: [CGPoint], cornerRadius: CGFloat) {
		
		guard !points.isEmpty else {
			return
		}
		
		lineCapStyle = .round
		usesEvenOddFillRule = true
		
		let len = points.count
		
		let prev = points[len - 1]
		let curr = points[0 % len]
		let next = points[1 % len]
		
		var cornerRadius = cornerRadius
		
		if cornerRadius < 0 {
			cornerRadius = 0
		} else {
			let maxCornerRadius = points[0].distance(to: points[1]) / 2.0
			if cornerRadius > maxCornerRadius {
				cornerRadius = maxCornerRadius
			}
		}
		
		addPoint(prev: prev, curr: curr, next: next, cornerRadius: cornerRadius, first: true)
		
		for i in 0..<len {
			
			let p = points[i]
			let c = points[(i + 1) % len]
			let n = points[(i + 2) % len]
			
			addPoint(prev: p, curr: c, next: n, cornerRadius: cornerRadius, first: false)
			
		}
		
		close()
		
	}
	
	private func polygonPoints(sides: Int, x: CGFloat, y: CGFloat, radius: CGFloat) -> [CGPoint] {
		
		guard sides >= 3 else {
			return []
		}
		
		let angle = degreesToRadians(360 / CGFloat(sides))
		
		let cx = x // x origin
		let cy = y // y origin
		let r  = radius // radius of circle
		
		var points = [CGPoint]()
		points.reserveCapacity(sides)
		
		for i in 0..<sides {
			
			let i = CGFloat(i)
			
			let pX = cx + r * cos(angle * i)
			let pY = cy + r * sin(angle * i)
			points.append(CGPoint(x: pX, y: pY))
			
		}
		
		return points
	}

	private func addPoint(prev: CGPoint, curr: CGPoint, next: CGPoint, cornerRadius: CGFloat, first: Bool) {
		
		// prev <- curr
		var c2p = CGPoint(x: prev.x - curr.x, y: prev.y - curr.y)
		
		// next <- curr
		var c2n = CGPoint(x: next.x - curr.x, y: next.y - curr.y)
		
		// normalize
		let magP = sqrt(c2p.x * c2p.x + c2p.y * c2p.y)
		let magN = sqrt(c2n.x * c2n.x + c2n.y * c2n.y)
		
		c2p.x /= magP
		c2p.y /= magP
		c2n.x /= magN
		c2n.y /= magN
		
		// angles
		let ω = acos(c2n.x * c2p.x + c2n.y * c2p.y)
		let θ = (.pi / 2) - (ω / 2)
		
		let adjustedCornerRadius = cornerRadius / θ * (.pi / 4)
		
		// r * tan(θ)
		let rTanθ = adjustedCornerRadius * tan(θ)

		let startX = curr.x + rTanθ * c2p.x
		let startY = curr.y + rTanθ * c2p.y
		let start = CGPoint(x: startX, y: startY)

		if !first {
			
			// Go perpendicular from start point by corner radius
			let centerX = start.x + c2p.y * adjustedCornerRadius
			let centerY = start.y - c2p.x * adjustedCornerRadius
			let center = CGPoint(x: centerX, y: centerY)

			let startAngle = atan2(c2p.x, -c2p.y)
			let endAngle = startAngle + (2 * θ)
			
			addLine(to: start)
			
			addArc(withCenter: center, radius: adjustedCornerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
			
		} else {
			
			let endX = curr.x + rTanθ * c2n.x
			let endY = curr.y + rTanθ * c2n.y
			let end = CGPoint(x: endX, y: endY)

			move(to: end)
			
		}
		
	}
	
}

public extension UIBezierPath {

	@objc
	public convenience init(roundedRegularPolygon rect: CGRect, numberOfSides: Int, cornerRadius: CGFloat) {
		
		guard numberOfSides > 2 else {
			self.init()
			return
		}
		
		self.init()
		
		let points = polygonPoints(sides: numberOfSides, x: rect.width / 2, y: rect.height / 2, radius: min(rect.width, rect.height) / 2)
		
		self.addPointsAsRoundedPolygon(points: points, cornerRadius: cornerRadius)
		
	}

}

public extension UIBezierPath {

	@objc
	public func applyRotation(_ angle: CGFloat) {
		
		let bounds = self.cgPath.boundingBox
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		
		let toOrigin = CGAffineTransform(translationX: -center.x, y: -center.y)
		
		self.apply(toOrigin)
		
		self.apply(CGAffineTransform(rotationAngle: degreesToRadians(angle)))
		
		let fromOrigin = CGAffineTransform(translationX: center.x, y: center.y)
		self.apply(fromOrigin)
		
	}
	
	@objc
	public func applyScale(_ scale: CGPoint) {
		
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		
		let toOrigin = CGAffineTransform(translationX: -center.x, y: -center.y)
		
		apply(toOrigin)
		
		apply(CGAffineTransform(scaleX: scale.x, y: scale.y))
		
		let fromOrigin = CGAffineTransform(translationX: center.x, y: center.y)
		apply(fromOrigin)
		
	}
	
}

func degreesToRadians(_ value: Double) -> CGFloat {
	return CGFloat(value * .pi / 180.0)
}

func degreesToRadians(_ value: CGFloat) -> CGFloat {
	return degreesToRadians(Double(value))
}

func radiansToDegrees(_ value: Double) -> CGFloat {
	return CGFloat((180.0 / .pi) * value)
}

func radiansToDegrees(_ value: CGFloat) -> CGFloat {
	return radiansToDegrees(Double(value))
}

extension CGPoint {
	
	func distance(to point: CGPoint) -> CGFloat {
		let a = self
		let b = point
		return hypot(a.x-b.x, a.y-b.y)
	}
	
}
