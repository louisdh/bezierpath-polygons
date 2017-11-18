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
		
		if points.count == 0 { return }
		
		lineCapStyle = .round
		usesEvenOddFillRule = true
		
		let len = points.count
		
		let prev = points[len - 1]
		let curr = points[0 % len]
		let next = points[1 % len]
		
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
		
		if sides < 3 { return [] }
		
		let angle = degreesToRadians(360 / CGFloat(sides))
		
		let cx = x // x origin
		let cy = y // y origin
		let r  = radius // radius of circle
		
		var i = 0
		var points = [CGPoint]()
		
		while i < sides {
			let xP = cx + r * cos(angle * CGFloat(i))
			let yP = cy + r * sin(angle * CGFloat(i))
			points.append(CGPoint(x: xP, y: yP))
			i += 1
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
		
		// r tan(θ)
		let rTanTheta = adjustedCornerRadius * tan(θ)
		var startPoint = CGPoint()
		
		startPoint.x = curr.x + rTanTheta * c2p.x
		startPoint.y = curr.y + rTanTheta * c2p.y
		
		var endPoint = CGPoint()
		endPoint.x = curr.x + rTanTheta * c2n.x
		endPoint.y = curr.y + rTanTheta * c2n.y
		
		if !first {
			
			// Go perpendicular from start point by corner radius
			var centerPoint = CGPoint()
			centerPoint.x = startPoint.x + c2p.y * adjustedCornerRadius
			centerPoint.y = startPoint.y - c2p.x * adjustedCornerRadius
			
			let startAngle = atan2(c2p.x, -c2p.y)
			let endAngle = startAngle + (2 * θ)
			
			addLine(to: startPoint)
			addArc(withCenter: centerPoint, radius: adjustedCornerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

			
		} else {
			
			move(to: endPoint)
			
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
	public func applyRotation(angle: CGFloat) {
		
		let bounds = self.cgPath.boundingBox
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		
		let toOrigin = CGAffineTransform(translationX: -center.x, y: -center.y)
		
		self.apply(toOrigin)
		
		self.apply(CGAffineTransform(rotationAngle: degreesToRadians(angle)))
		
		let fromOrigin = CGAffineTransform(translationX: center.x, y: center.y)
		self.apply(fromOrigin)
		
	}
	
	@objc
	public func applyScale(scale: CGPoint) {
		
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
