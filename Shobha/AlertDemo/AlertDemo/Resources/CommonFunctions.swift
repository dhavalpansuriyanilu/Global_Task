//
//  CommonFunctions.swift
//  AlertDemo
//
//  Created by 41_MacBook_Air on 13/05/25.
//

import UIKit

enum AnimationType : Int{
    case fade = 0
    case scale = 1
    case rotate = 2
    case slideFromLeft = 3
    case slideFromRight = 4
    case slideFromTop = 5
    case slideFromBottom = 6
    case flipFromLeft = 7
    case flipFromRight = 8
    case shake = 9
    case zoomIn = 10
    case zoomOut = 11
    case bounce = 12
    case pulse = 13
    case linearMovement = 14
    case flipFromTop = 15
    case flipFromBottom = 16
    case curlUp = 17
    case curlDown = 18
    case swing = 19
    case wobble = 20
    case flash = 21
    case glow = 22
    case pop = 23
    case morph = 24
    case fall =  25
    case stretch = 26
    case collapse = 27
    case expand = 28
    case hover =  29
}

extension UIViewController {
    func performAlertAnimation(type: AnimationType, bgView: UIView, opacityView: UIView? = nil, completion: (() -> Void)? = nil) {
        // Reset to identity transform and full opacity before any animation
        bgView.transform = .identity
        bgView.alpha = 1
        bgView.layer.removeAllAnimations()
        
        // Store original frame for slide animations
        let originalFrame = bgView.frame
        let originalCenter = bgView.center
        
        switch type {
        case .zoomIn:
            bgView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            bgView.alpha = 0
            UIView.animate(withDuration: 0.35,
                          delay: 0,
                          usingSpringWithDamping: 0.85,
                          initialSpringVelocity: 0.3,
                          options: [.curveEaseInOut],
                          animations: {
                bgView.transform = .identity
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .zoomOut:
            UIView.animate(withDuration: 0.35, animations: {
                bgView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                bgView.alpha = 0
                opacityView?.alpha = 0
            }, completion: { _ in
                bgView.transform = .identity
                bgView.alpha = 1
                completion?()
            })
            
        case .bounce:
            bgView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            bgView.alpha = 0
            UIView.animate(withDuration: 0.6,
                          delay: 0,
                          usingSpringWithDamping: 0.4,
                          initialSpringVelocity: 6,
                          options: [.curveEaseInOut],
                          animations: {
                bgView.transform = .identity
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .fade:
            bgView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .scale:
            bgView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.3, animations: {
                bgView.transform = .identity
            }, completion: { _ in completion?() })
            
        case .rotate:
            bgView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
            bgView.alpha = 0
            UIView.animate(withDuration: 0.4, animations: {
                bgView.transform = .identity
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .slideFromLeft:
            bgView.frame.origin.x = -bgView.frame.width
            UIView.animate(withDuration: 0.3, animations: {
                bgView.frame = originalFrame
            }, completion: { _ in completion?() })
            
        case .slideFromRight:
            bgView.frame.origin.x = UIScreen.main.bounds.width
            UIView.animate(withDuration: 0.3, animations: {
                bgView.frame = originalFrame
            }, completion: { _ in completion?() })
            
        case .slideFromTop:
            bgView.frame.origin.y = -bgView.frame.height
            UIView.animate(withDuration: 0.3, animations: {
                bgView.frame = originalFrame
            }, completion: { _ in completion?() })
            
        case .slideFromBottom:
            bgView.frame.origin.y = UIScreen.main.bounds.height
            UIView.animate(withDuration: 0.3, animations: {
                bgView.frame = originalFrame
            }, completion: { _ in completion?() })
            
        case .flipFromLeft:
            bgView.alpha = 0
            UIView.transition(with: bgView, duration: 0.4, options: [.transitionFlipFromLeft, .curveEaseInOut], animations: {
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .flipFromRight:
            bgView.alpha = 0
            UIView.transition(with: bgView, duration: 0.4, options: [.transitionFlipFromRight, .curveEaseInOut], animations: {
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .shake:
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.values = [-20, 20, -15, 15, -10, 10, -5, 5, 0]
            animation.duration = 0.5
            animation.isRemovedOnCompletion = true
            bgView.layer.add(animation, forKey: "shake")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion?()
            }
            
        case .pulse:
            UIView.animate(withDuration: 0.15, animations: {
                bgView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, animations: {
                    bgView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.15, animations: {
                        bgView.transform = .identity
                    }, completion: { _ in
                        completion?()
                    })
                })
            })
            
        case .linearMovement:
            bgView.center.x = -bgView.bounds.width
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear], animations: {
                bgView.center = originalCenter
            }, completion: { _ in completion?() })
            
        case .flipFromTop:
            bgView.alpha = 0
            UIView.transition(with: bgView, duration: 0.5, options: [.transitionFlipFromTop, .curveEaseInOut], animations: {
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .flipFromBottom:
            bgView.alpha = 0
            UIView.transition(with: bgView, duration: 0.5, options: [.transitionFlipFromBottom, .curveEaseInOut], animations: {
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .curlUp:
            bgView.alpha = 0
            UIView.transition(with: bgView, duration: 0.5, options: [.transitionCurlUp, .curveEaseInOut], animations: {
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .curlDown:
            bgView.alpha = 0
            UIView.transition(with: bgView, duration: 0.5, options: [.transitionCurlDown, .curveEaseInOut], animations: {
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .swing:
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
            animation.values = [-CGFloat.pi/8, CGFloat.pi/8, -CGFloat.pi/16, CGFloat.pi/16, 0]
            animation.duration = 0.8
            animation.isRemovedOnCompletion = true
            bgView.layer.add(animation, forKey: "swing")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completion?()
            }
            
        case .wobble:
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
            animation.values = [-CGFloat.pi/16, CGFloat.pi/16, -CGFloat.pi/32, CGFloat.pi/32, 0]
            animation.duration = 0.5
            animation.isRemovedOnCompletion = true
            bgView.layer.add(animation, forKey: "wobble")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion?()
            }
            
        case .flash:
            UIView.animate(withDuration: 0.2, animations: {
                bgView.alpha = 0.3
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    bgView.alpha = 1.0
                }, completion: { _ in
                    completion?()
                })
            })
            
        case .glow:
            let glowColor = UIColor.systemYellow.cgColor
            bgView.layer.shadowColor = glowColor
            bgView.layer.shadowRadius = 20
            bgView.layer.shadowOpacity = 1
            bgView.layer.shadowOffset = .zero
            bgView.layer.masksToBounds = false
            
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = 1.0
            animation.isRemovedOnCompletion = true
            bgView.layer.add(animation, forKey: "glow")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                bgView.layer.shadowOpacity = 0
                completion?()
            }
            
        case .pop:
            UIView.animate(withDuration: 0.2, animations: {
                bgView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    bgView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                        bgView.transform = .identity
                    }, completion: { _ in
                        completion?()
                    })
                })
            })
            
        case .morph:
            bgView.transform = CGAffineTransform(scaleX: 0.1, y: 2.0)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
                bgView.transform = .identity
            }, completion: { _ in completion?() })
            
        case .fall:
            bgView.center.y = -bgView.bounds.height
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
                bgView.center.y = originalCenter.y
            }, completion: { _ in completion?() })
            
        case .stretch:
            bgView.transform = CGAffineTransform(scaleX: 1.0, y: 0.5)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                bgView.transform = .identity
            }, completion: { _ in completion?() })
            
        case .collapse:
            UIView.animate(withDuration: 0.4, animations: {
                bgView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                bgView.alpha = 0
            }, completion: { _ in
                bgView.transform = .identity
                bgView.alpha = 1
                completion?()
            })
            
        case .expand:
            bgView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            bgView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                bgView.transform = .identity
                bgView.alpha = 1
            }, completion: { _ in completion?() })
            
        case .hover:
            let animation = CABasicAnimation(keyPath: "position.y")
            animation.duration = 2.0
            animation.repeatCount = .greatestFiniteMagnitude
            animation.autoreverses = true
            animation.fromValue = bgView.center.y - 10
            animation.toValue = bgView.center.y + 10
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.isRemovedOnCompletion = false
            bgView.layer.add(animation, forKey: "hover")
            completion?()
        }
    }
}





