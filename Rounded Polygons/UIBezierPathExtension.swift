//
//  UIBezierPathExtension.swift
//  Rounded Polygons
//
//  Created by Louis D'hauwe on 24/11/15.
//  Copyright © 2015 Silver Fox. All rights reserved.
//

import Foundation
import UIKit


public extension UIBezierPath {
	
	private func addPoint(prev: CGPoint, curr: CGPoint, next: CGPoint, cornerRadius: CGFloat, first: Bool) {
		
		// prev <- curr
		var c2p = CGPointMake(prev.x - curr.x, prev.y - curr.y)
		
		// next <- curr
		var c2n = CGPointMake(next.x - curr.x, next.y - curr.y)
		
		// normalize
		let magP = sqrt(c2p.x * c2p.x + c2p.y * c2p.y)
		let magN = sqrt(c2n.x * c2n.x + c2n.y * c2n.y)
		
		c2p.x /= magP
		c2p.y /= magP
		c2n.x /= magN
		c2n.y /= magN
		
		// angles
		let ω = acos(c2n.x * c2p.x + c2n.y * c2p.y)
		let θ = CGFloat(M_PI_2) - (ω / 2)
		
		let adjustedCornerRadius = cornerRadius / θ * CGFloat(M_PI_4)
		
		// r tan(θ)
		let rTanTheta = adjustedCornerRadius * tan(θ)
		var startPoint = CGPoint()
		
		startPoint.x = curr.x + rTanTheta * c2p.x
		startPoint.y = curr.y + rTanTheta * c2p.y
		
		var endPoint = CGPoint()
		endPoint.x = curr.x + rTanTheta * c2n.x
		endPoint.y = curr.y + rTanTheta * c2n.y
		
		if (!first) {
			
			// go perpendicular from start point by corner radius
			var centerPoint = CGPoint()
			centerPoint.x = startPoint.x + c2p.y * adjustedCornerRadius
			centerPoint.y = startPoint.y - c2p.x * adjustedCornerRadius
			
			let startAngle = atan2(c2p.x, -c2p.y)
			let endAngle = startAngle + (2 * θ)
			
			addLineToPoint(startPoint)
			addArcWithCenter(centerPoint, radius: adjustedCornerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

			
		} else {
			
			moveToPoint(endPoint)
			
		}
		
	}
	
	@objc public convenience init(roundedRegularPolygon rect: CGRect, numberOfSides: Int, cornerRadius: CGFloat) {
		assert(numberOfSides > 2)
		
		self.init()
		
		let points = polygonPoints(numberOfSides, x: rect.width / 2, y: rect.height / 2, radius: min(rect.width, rect.height) / 2)
		
		self.addPointsAsRoundedPolygon(points, cornerRadius: cornerRadius)
		
	}
	
	public func addPointsAsRoundedPolygon(points: [CGPoint], cornerRadius: CGFloat) {
		
		lineCapStyle = .Round
		usesEvenOddFillRule = true
		
		let len = points.count
		
		let prev = points[len - 1]
		let curr = points[0 % len]
		let next = points[1 % len]
		
		
		addPoint(prev, curr: curr, next: next, cornerRadius: cornerRadius, first: true)
		
		for i in 0..<len {
			
			let p = points[i]
			let c = points[(i + 1) % len]
			let n = points[(i + 2) % len]
			
			addPoint(p, curr: c, next: n, cornerRadius: cornerRadius, first: false)

		}
		
		closePath()
		
	}
	
	public func polygonPoints(sides: Int, x: CGFloat, y: CGFloat, radius: CGFloat) -> [CGPoint] {
		
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
			i++
		}
		
		return points
	}
	
	
	@objc public func applyRotation(angle: CGFloat) {
		
		let bounds = CGPathGetBoundingBox(self.CGPath)
		let center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
		
		let toOrigin = CGAffineTransformMakeTranslation(-center.x, -center.y)
		
		self.applyTransform(toOrigin)
		
		self.applyTransform(CGAffineTransformMakeRotation(degreesToRadians(angle)))
		
		let fromOrigin = CGAffineTransformMakeTranslation(center.x, center.y)
		self.applyTransform(fromOrigin)
		
	}
	
	@objc public func applyScale(scale: CGPoint) {
		
		let center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
		
		let toOrigin = CGAffineTransformMakeTranslation(-center.x, -center.y)
		
		applyTransform(toOrigin)
		
		applyTransform(CGAffineTransformMakeScale(scale.x, scale.y))
		
		let fromOrigin = CGAffineTransformMakeTranslation(center.x, center.y)
		applyTransform(fromOrigin)
		
	}
	
	
}

func degreesToRadians(value: Double) -> CGFloat {
	return CGFloat(value * M_PI / 180.0)
}

func degreesToRadians(value: CGFloat) -> CGFloat {
	return degreesToRadians(Double(value))
}

func radiansToDegrees(value: Double) -> CGFloat {
	return CGFloat((180.0 / M_PI) * value)
}

func radiansToDegrees(value: CGFloat) -> CGFloat {
	return radiansToDegrees(Double(value))
}
