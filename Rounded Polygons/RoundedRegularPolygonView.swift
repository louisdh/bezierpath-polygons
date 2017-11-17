//
//  RoundedPolygonView.swift
//  Rounded Polygons
//
//  Created by Louis D'hauwe on 23/11/15.
//  Copyright © 2015 Silver Fox. All rights reserved.
//

import UIKit

@objc @IBDesignable public class RoundedRegularPolygonView: UIView {

	@objc @IBInspectable var color: UIColor = UIColor.redColor() {
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
	
	@objc @IBInspectable var scale: CGPoint = CGPointMake(1, 1) {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@objc @IBInspectable var sides: Int = 6 {
		didSet {
			self.setNeedsDisplay()
		}
	}

	
    override public func drawRect(rect: CGRect) {
		
		let polygonPath = UIBezierPath(roundedRegularPolygon: rect, numberOfSides: sides, cornerRadius: cornerRadius)

		polygonPath.applyRotation(rotation)
		
		polygonPath.applyScale(scale)
		
		polygonPath.closePath()
		
		color.setFill()
		polygonPath.fill()

    }
	
	override public func intrinsicContentSize() -> CGSize {
		return CGSizeMake(60, 60)
	}

}
