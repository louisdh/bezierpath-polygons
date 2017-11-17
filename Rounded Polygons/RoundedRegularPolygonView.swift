//
//  RoundedPolygonView.swift
//  Rounded Polygons
//
//  Created by Louis D'hauwe on 23/11/15.
//  Copyright © 2015 Silver Fox. All rights reserved.
//

import UIKit

@objc @IBDesignable
public class RoundedRegularPolygonView: UIView {

	@objc @IBInspectable var color: UIColor = .red {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@objc @IBInspectable var rotation: CGFloat = 0.0 {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@objc @IBInspectable var cornerRadius: CGFloat = 0.0 {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@objc @IBInspectable var scale: CGPoint = CGPoint(x: 1, y: 1) {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@objc @IBInspectable var sides: Int = 6 {
		didSet {
			self.setNeedsDisplay()
		}
	}

	
	override public func draw(_ rect: CGRect) {
		
		let polygonPath = UIBezierPath(roundedRegularPolygon: rect, numberOfSides: sides, cornerRadius: cornerRadius)

		polygonPath.applyRotation(angle: rotation)
		
		polygonPath.applyScale(scale: scale)
		
		polygonPath.close()
		
		color.setFill()
		polygonPath.fill()

    }
	
	override public var intrinsicContentSize: CGSize {
		return CGSize(width: 60, height: 60)
	}

}
