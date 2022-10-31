//
//  Extensions.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/6/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

extension UIViewController {
    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImage {
    
    func imageResize (sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}

extension SKAction {
    @objc public class func moveBy(x deltaX: CGFloat, y deltaY: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let moveByX = animate(keyPath: \SKNode.position.x, byValue: deltaX, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let moveByY = animate(keyPath: \SKNode.position.y, byValue: deltaY, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([moveByX, moveByY])
    }
        
        public class func animate<T>(keyPath: ReferenceWritableKeyPath<T, CGFloat>, byValue initialDistance: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
            
            return animate(_keyPath: keyPath, byValue: initialDistance, toValue: nil, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        }
        
        public class func animate<T>(keyPath: ReferenceWritableKeyPath<T, CGFloat>, toValue finalValue: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
            
            return animate(_keyPath: keyPath, byValue: nil, toValue: finalValue, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        }
        
        private class func animate<T>(_keyPath: ReferenceWritableKeyPath<T, CGFloat>, byValue: CGFloat!, toValue: CGFloat!, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
            
            var initialValue: CGFloat!
            var naturalFrequency: CGFloat = 0
            var dampedFrequency: CGFloat = 0
            var t1: CGFloat = 0
            var t2: CGFloat = 0
            var A: CGFloat = 0
            var B: CGFloat = 0
            var finalValue: CGFloat! = toValue
            var initialDistance: CGFloat! = byValue
            
            let animation = SKAction.customAction(withDuration: duration, actionBlock: {
                (node, elapsedTime) in
                
                if let propertyToAnimation = node as? T {
                    
                    if initialValue == nil {
                        
                        initialValue = propertyToAnimation[keyPath: _keyPath]
                        initialDistance = initialDistance ?? finalValue - initialValue!
                        finalValue = finalValue ?? initialValue! + initialDistance
                        
                        var magicNumber: CGFloat! // picked manually to visually match the behavior of UIKit
                        if dampingRatio < 1 { magicNumber = 8 / dampingRatio }
                        else if dampingRatio == 1 { magicNumber = 10 }
                        else { magicNumber = 12 * dampingRatio }
                        
                        naturalFrequency = magicNumber / CGFloat(duration)
                        dampedFrequency = naturalFrequency * sqrt(1 - pow(dampingRatio, 2))
                        t1 = 1 / (naturalFrequency * (dampingRatio - sqrt(pow(dampingRatio, 2) - 1)))
                        t2 = 1 / (naturalFrequency * (dampingRatio + sqrt(pow(dampingRatio, 2) - 1)))
                        
                        if dampingRatio < 1 {
                            A = initialDistance
                            B = (dampingRatio * naturalFrequency - velocity) * initialDistance / dampedFrequency
                        } else if dampingRatio == 1 {
                            A = initialDistance
                            B = (naturalFrequency - velocity) * initialDistance
                        } else {
                            A = (t1 * t2 / (t1 - t2))
                            A *= initialDistance * (1/t2 - velocity)
                            B = (t1 * t2 / (t2 - t1))
                            B *= initialDistance * (1/t1 - velocity)
                        }
                    }
                    
                    var currentValue: CGFloat!
                    
                    if elapsedTime < CGFloat(duration) {
                        
                        if dampingRatio < 1 {
                            
                            let dampingExp:CGFloat = exp(-dampingRatio * naturalFrequency * elapsedTime)
                            let ADamp:CGFloat = A * cos(dampedFrequency * elapsedTime)
                            let BDamp:CGFloat = B * sin(dampedFrequency * elapsedTime)
                            
                            currentValue = finalValue - dampingExp * (ADamp + BDamp)
                        } else if dampingRatio == 1 {
                            
                            let dampingExp: CGFloat = exp(-dampingRatio * naturalFrequency * elapsedTime)
                            
                            currentValue = finalValue - dampingExp * (A + B * elapsedTime)
                        } else {
                            
                            let ADamp:CGFloat =  A * exp(-elapsedTime/t1)
                            let BDamp:CGFloat = B * exp(-elapsedTime/t2)
                            currentValue = finalValue - ADamp - BDamp
                        }
                    } else {
                        currentValue = finalValue
                    }
                    propertyToAnimation[keyPath: _keyPath] = currentValue
                }
            })
            
            if delay > 0 {
                return SKAction.sequence([SKAction.wait(forDuration: delay), animation])
            } else {
                return animation
            }
        }
}
