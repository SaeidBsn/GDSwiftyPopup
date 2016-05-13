//
//  GDSwiftyPopup.swift
//  LiberWave
//
//  Created by Saeid Basirnia on 5/12/16.
//  Copyright © 2016 Saeidbsn. All rights reserved.
//

import UIKit

enum ViewDismissType: Int{
    case None
    case FadeOut
    case SlideOut
    case BounceOut
    case GrowOut
}

enum ViewShowType{
    case None
    case FadeIn
    case SlideIn
    case BounceIn
    case GrowIn
}

enum ViewDimmedType{
    case Dimmed
    case Clear
}

class GDSwiftyPopup: UIView {
    private var containerView: UIView!
    private var backgroundView: UIView!
    
    var dimmedBackground: Bool = true
    var dismissOnTouch: Bool = false
    var dismissOnPopupTouch: Bool = false
    
    var isDismissing: Bool = false
    var isShowing: Bool = false
    var isShow: Bool = false
    
    var autoDismiss: Bool = false
    var autoDismissDelay: Double = 3.0
    
    var showType: ViewShowType = .None
    var dismissType: ViewDismissType = .None
    var dimmedType: ViewDimmedType = .Dimmed
    
    
    //Initialize view
    init(containerView: UIView){
        super.init(frame: UIScreen.mainScreen().bounds)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didRotate(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.containerView = containerView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Setup View
    func createPopupView(inView: UIView, centerPoint: CGPoint){
        self.setupBackgroundView()
        self.containerView.userInteractionEnabled = true
        self.containerView.center = centerPoint
        self.userInteractionEnabled = true
        
        self.addSubview(backgroundView)
        
        self.show()
        inView.addSubview(self)
        
        self.setupConstraints()
        self.layoutIfNeeded()
    }
    
    //Setup view behaviors
    func setupBackgroundView(){
        self.backgroundView = UIView()
        self.backgroundView.frame = self.frame
        self.backgroundView.userInteractionEnabled = true
        
        if dimmedType == .Clear{
            self.backgroundView.backgroundColor = UIColor.clearColor()
        }else if dimmedType == .Dimmed{
            self.backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        }else{
            self.backgroundView.removeFromSuperview()
        }
    }
    
    func dimBackground(){
        if dimmedBackground{
            self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        }else{
            self.backgroundColor = UIColor.clearColor()
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let touchedRect = CGRectInset(self.bounds, -10, -10)
        
        if CGRectContainsPoint(touchedRect, point){
            for v in self.subviews.reverse(){
                let cPoint = v.convertPoint(point, fromView: self)
                let hitView = v.hitTest(cPoint, withEvent: event)
                
                if (hitView != nil){
                    if dismissOnTouch{
                        if hitView == self.backgroundView{
                            dismiss()
                        }
                    }
                    if dismissOnPopupTouch{
                        if hitView == self.containerView{
                            dismiss()
                        }
                    }
                    return hitView
                }
            }
        }
        return nil
    }
    
    
    //Action functions
    func didRotate(sender: NSNotification){
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
            guard let sView = superview else{
                return
            }
            self.frame = sView.frame
            self.backgroundView.frame = self.frame
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
            guard let sView = superview else{
                return
            }
            self.frame = sView.frame
            self.backgroundView.frame = self.frame
        }
    }
    
    func setupConstraints(){
        let rightConstraint = NSLayoutConstraint(
            item: self.containerView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Right,
            multiplier: 1.0,
            constant: -20)
        let leftConstraint = NSLayoutConstraint(
            item: self.containerView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Left,
            multiplier: 1.0,
            constant: 20)
        let centerConstraint = NSLayoutConstraint(
            item: self.containerView,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)
        
        self.addConstraints([rightConstraint, leftConstraint, centerConstraint])
    }
    
    func show(){
        if !isShowing && !isDismissing{
            isShowing = !isShowing
            
            switch showType{
            case .None:
                self.addSubview(self.containerView)
                
                UIView.animateWithDuration(0.1, delay: 0.0, options: [], animations: {
                    }, completion: showCompletionBlock())
                
                break
            case .SlideIn:
                self.addSubview(self.containerView)
                
                var frame = self.containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 0.2, options: [.CurveEaseInOut], animations: {
                    self.containerView.center.y = self.center.y
                    }, completion: showCompletionBlock())
                
                break
            case .BounceIn:
                self.addSubview(self.containerView)
                
                var frame = self.containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [.CurveEaseInOut], animations: {
                    self.containerView.center.y = self.center.y
                    }, completion: showCompletionBlock())
                
                break
            case .FadeIn:
                self.addSubview(self.containerView)
                
                self.containerView.alpha = 0.0
                UIView.animateWithDuration(0.5, animations: {
                    self.containerView.alpha = 1.0
                    }, completion: showCompletionBlock())
                
                break
            case .GrowIn:
                self.addSubview(self.containerView)
                
                self.containerView.alpha = 0.0
                self.containerView.transform = CGAffineTransformMakeScale(0, 0)
                
                UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [], animations: {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }, completion: showCompletionBlock())
                break
            }
        }
    }
    
    func dismiss(){
        if !isDismissing && isShow{
            isDismissing = !isDismissing
            
            switch dismissType{
            case .None:
                self.isDismissing = false
                self.isShow = false
                self.isShowing = false
                
                self.removeFromSuperview()
                
                break
            case .SlideOut:
                var frame = self.containerView.frame
                
                UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 0.2, options: [.CurveEaseOut], animations: {
                    frame.origin.y = self.frame.height + 50
                    self.containerView.frame = frame
                    }, completion: { _ in
                        self.isDismissing = false
                        self.isShow = false
                        self.isShowing = false
                        
                        self.removeFromSuperview()
                })
                
                break
            case .BounceOut:
                var frame = self.containerView.frame
                
                UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: [.CurveEaseInOut], animations: {
                    frame.origin.y -= 50
                    self.containerView.frame = frame
                    }, completion: { _ in
                        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [.CurveEaseInOut], animations: {
                            frame.origin.y = self.frame.height + 50
                            self.containerView.frame = frame
                            }, completion:  { _ in
                                self.isDismissing = false
                                self.isShow = false
                                self.isShowing = false
                                
                                self.removeFromSuperview()
                        })
                })
                break
            case .FadeOut:
                UIView.animateWithDuration(0.5, animations: {
                    self.containerView.alpha = 0.0
                    }, completion: { _ in
                        self.isDismissing = false
                        self.isShow = false
                        self.isShowing = false
                        
                        self.removeFromSuperview()
                })
                
                break
            case .GrowOut:
                UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.CurveEaseIn], animations: {
                    self.containerView.transform = CGAffineTransformMakeScale(1.3, 1.3)
                    }, completion: { _ in
                        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.CurveEaseIn], animations: {
                            self.containerView.alpha = 0.0
                            self.containerView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                            }, completion: { _ in
                                self.isDismissing = false
                                self.isShow = false
                                self.isShowing = false
                                
                                self.removeFromSuperview()
                        })
                })
                
                break
            }
        }
    }
    
    func showCompletionBlock() -> (Bool) -> (){
        self.isDismissing = false
        self.isShow = true
        self.isShowing = false
        
        if autoDismiss{
            self.setDelayDuration(autoDismissDelay, task: {
                self.dismiss()
            })
        }
        return { _ in true }
    }
}

extension GDSwiftyPopup{
    func setDelayDuration(delayDuration: Double, task:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delayDuration * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), task)
    }
}
