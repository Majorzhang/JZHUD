//
//  JZHUD.swift
//  Equatable
//
//  Created by Jun Zhang on 16/8/30.
//  Copyright © 2016年 Jun Zhang. All rights reserved.
//

import UIKit
let Radius: CGFloat = 20
var Duration: Double = 2.1
let G_PI = CGFloat(M_PI)
enum AnimationStyle {
    case Rotate3d
    case Random
    case Regular
    case Regular_Reverse
}


class JZHUD: UIWindow {
    
    private var circle_1 = UIView()
    private var circle_2 = UIView()
    private var circle_3 = UIView()
    private var timer: NSTimer?
    private var circles: [UIView] = []
    private var loading = false

    static let sharedInstance = JZHUD(frame: UIScreen.mainScreen().bounds)
    private var style: AnimationStyle = .Rotate3d
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(screenRotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    private func createSubviews() {
        frame = UIScreen.mainScreen().bounds
//        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        backgroundColor = UIColor.darkGrayColor()
        circles = [circle_2, circle_1, circle_3]
        let rect2 = CGRect(origin: CGPointMake((width - Radius) * 0.5, (height - Radius) * 0.5), size: CGSize(width: Radius, height: Radius))
        congfig(UIColor.blueColor(), frame: rect2, target: circle_2)
        
        let rect1 = CGRect(origin: CGPointMake(circle_2.x - Radius,circle_2.y), size: CGSize(width: Radius, height: Radius))
        congfig(UIColor.yellowColor(), frame: rect1, target: circle_1)
        
        let rect3 = CGRect(origin: CGPointMake(circle_2.x + Radius,circle_2.y), size: CGSize(width: Radius, height: Radius))
        congfig(UIColor.redColor(), frame: rect3, target: circle_3)
    }
    
    dynamic private func screenRotate() {
        if JZHUD.sharedInstance.loading {
            JZHUD.hideHUD()
            _ = circles.map { $0.transform = CGAffineTransformIdentity}
            delay(0.1) {
                JZHUD.showHUD(JZHUD.sharedInstance.style)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }
    
    private func layoutSubviewsIfNeeded() {
        let rect2 = CGRect(origin: CGPointMake((width - Radius) * 0.5, (height - Radius) * 0.5), size: CGSize(width: Radius, height: Radius))
        circle_2.frame = rect2
        let rect1 = CGRect(origin: CGPointMake(circle_2.x - Radius,circle_2.y), size: CGSize(width: Radius, height: Radius))
        circle_1.frame = rect1
        let rect3 = CGRect(origin: CGPointMake(circle_2.x + Radius,circle_2.y), size: CGSize(width: Radius, height: Radius))
        circle_3.frame = rect3
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
//        layoutSubviewsIfNeeded()
    }
    
    class func showHUD(style: AnimationStyle = .Rotate3d) {
        let hud = JZHUD.sharedInstance
        hud.loading = true
        hud.style = style
        hud.delay(0.05) {
            hud.hidden = false
            hud.makeKeyAndVisible()
            hud.frame = UIScreen.mainScreen().bounds
            hud.layoutSubviewsIfNeeded()
            UIView.animateWithDuration(0.05, animations: { () -> Void in
                hud.alpha = 0.5
                }, completion: { (finished) -> Void in
                    hud.startLoadingAnimation(style)
            })
        }
    }
    
    class func hideHUD() {
        let hud = JZHUD.sharedInstance
        hud.loading = false
        hud.removeAnimations()
        if let timer = hud.timer {
            timer.invalidate()
        }
        hud.hidden = true
    }
}


extension JZHUD {
    
    func delay(seconds: Double,closure:() -> ()) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds)), dispatch_get_main_queue(), closure)
    }
    
    private func removeAnimations() {
        _ = circles.map{ $0.layer.removeAllAnimations()}
    }
    
    private func startLoadingAnimation(style: AnimationStyle) {
        let circlePath1 = UIBezierPath()
        circlePath1.moveToPoint(CGPointMake(width * 0.5 - Radius, height * 0.5 ))
        let circlePath2 = UIBezierPath()
        circlePath2.moveToPoint(CGPointMake(width * 0.5 + Radius, height * 0.5))
        var autoreverses = false
        
        switch style {
        case .Rotate3d:
            Duration = 2.1
            circlePath1.addArcWithCenter(CGPointMake(width * 0.5, height * 0.5), radius: Radius, startAngle: G_PI, endAngle: G_PI * 3, clockwise: true)
            circlePath2.addArcWithCenter(CGPointMake(width/2, height/2), radius: Radius, startAngle: 0, endAngle: CGFloat((360*M_PI)/180), clockwise: true)
        case .Regular_Reverse, .Regular, .Random:
            Duration = 1.4
            autoreverses = (style != .Regular) ? true : false
            circlePath1.addArcWithCenter(CGPointMake(width * 0.5, height * 0.5), radius: Radius, startAngle: G_PI, endAngle: G_PI * 3, clockwise: true)
            circlePath2.addArcWithCenter(CGPointMake(width * 0.5, height * 0.5), radius: Radius, startAngle: 0, endAngle: G_PI * -2, clockwise: false)
        }
        let animation1 = createAnimation()
        animation1.path = circlePath1.CGPath
        animation1.autoreverses = autoreverses
        let animation2 = createAnimation()
        animation2.path = circlePath2.CGPath
        if style != .Random {
            animation2.autoreverses = autoreverses
        }
        circle_1.layer.addAnimation(animation1, forKey: "circle_1_rotation_animation1")
        circle_3.layer.addAnimation(animation2, forKey: "circle_2_rotation_animation2")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(autoScale), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func createAnimation(keyPath: String = "position") -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.removedOnCompletion = true
        animation.duration = Duration
        animation.repeatCount = Float.infinity
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return animation
    }
    
    func autoScale() {
        UIView.animateWithDuration(0.3, delay: 0.1, options: [.CurveEaseOut,.BeginFromCurrentState], animations: { () -> Void in
            self.circle_1.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(-Radius, 0), 0.7, 0.7)
            
            self.circle_3.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(Radius, 0), 0.7, 0.7)
            
            self.circle_2.transform = CGAffineTransformScale(self.circle_2.transform, 0.7, 0.7)
            
            }, completion: { (finished) -> Void in
                UIView.animateWithDuration(0.3, delay: 0.0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: { () -> Void in
                    self.circle_1.transform = CGAffineTransformIdentity
                    self.circle_3.transform = CGAffineTransformIdentity
                    self.circle_2.transform = CGAffineTransformIdentity
                    }, completion: nil)
        })
        
    }
}


extension UIView {
    var width: CGFloat {
        return self.frame.size.width
    }
    var height: CGFloat {
        return self.frame.size.height
    }
    var origin: CGPoint {
        return self.frame.origin
    }
    var x: CGFloat {
        return self.frame.origin.x
    }
    var y: CGFloat {
        return self.frame.origin.y
    }
    
    func congfig(color: UIColor, frame: CGRect, radius: CGFloat = Radius * 0.5, target: UIView) {
        target.frame = frame
        target.backgroundColor = color
        target.layer.cornerRadius = radius
        addSubview(target)
    }
    
}

