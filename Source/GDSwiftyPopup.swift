//
//  GDSwiftyPopup.swift
//  LiberWave
//
//  Created by Saeid Basirnia on 5/12/16.
//  Copyright © 2016 Saeidbsn. All rights reserved.
//

import UIKit

enum ViewDismissType: Int{
    case none
    case fadeOut
    case slideOut
    case bounceOut
    case growOut
}

enum ViewShowType: Int{
    case none
    case fadeIn
    case slideIn
    case bounceIn
    case growIn
}

enum ViewDimmedType{
    case dimmed
    case clear
}

class GDSwiftyPopup: UIView {
    var containerView: UIView!
    var backgroundView: UIView!
    
    var dismissOnTouch: Bool = false
    var dismissOnPopupTouch: Bool = false
    
    var isDismissing: Bool = false
    var isShowing: Bool = false
    var isPresented: Bool = false
    
    var autoDismiss: Bool = false
    var autoDismissDelay: Double = 3.0
    
    var showType: ViewShowType = .none
    var dismissType: ViewDismissType = .none
    var dimmedType: ViewDimmedType = .dimmed
    
    
    //Initialize view
    init(containerView: UIView){
        super.init(frame: UIScreen.main.bounds)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.containerView = containerView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Setup View
    func createPopupView(_ inView: UIView, centerPoint: CGPoint){
        self.setupBackgroundView()
        self.containerView.isUserInteractionEnabled = true
        self.containerView.center = centerPoint
        self.isUserInteractionEnabled = true
        
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
        self.backgroundView.isUserInteractionEnabled = true
        
        if dimmedType == .clear{
            self.backgroundView.backgroundColor = UIColor.clear
        }else if dimmedType == .dimmed{
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        }else{
            self.backgroundView.removeFromSuperview()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchedRect = self.bounds.insetBy(dx: -10, dy: -10)
        
        if touchedRect.contains(point){
            for v in self.subviews.reversed(){
                let cPoint = v.convert(point, from: self)
                let hitView = v.hitTest(cPoint, with: event)
                
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
    func didRotate(_ sender: Notification){
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            guard let sView = superview else{
                return
            }
            self.frame = sView.frame
            self.backgroundView.frame = self.frame
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
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
            attribute: .right,
            relatedBy: .equal,
            toItem: self,
            attribute: .right,
            multiplier: 1.0,
            constant: -20)
        let leftConstraint = NSLayoutConstraint(
            item: self.containerView,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1.0,
            constant: 20)
        let centerConstraint = NSLayoutConstraint(
            item: self.containerView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0)
        
        self.addConstraints([rightConstraint, leftConstraint, centerConstraint])
    }
    
    private func show(){
        if !isShowing && !isDismissing{
            isShowing = !isShowing
            
            switch showType{
            case .none:
                self.addSubview(self.containerView)
                
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [], animations: {
                    }, completion: showCompletionBlock())
                
                break
            case .slideIn:
                self.addSubview(self.containerView)
                
                var frame = self.containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                    self.containerView.center.y = self.center.y
                    }, completion: showCompletionBlock())
                
                break
            case .bounceIn:
                self.addSubview(self.containerView)
                
                var frame = self.containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                    self.containerView.center.y = self.center.y
                    }, completion: showCompletionBlock())
                
                break
            case .fadeIn:
                self.addSubview(self.containerView)
                
                self.containerView.alpha = 0.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.containerView.alpha = 1.0
                    }, completion: showCompletionBlock())
                
                break
            case .growIn:
                self.addSubview(self.containerView)
                
                self.containerView.alpha = 0.0
                self.containerView.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [], animations: {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: showCompletionBlock())
                break
            }
        }
    }
    
    func dismiss(){
        if !isDismissing && isPresented{
            isDismissing = !isDismissing
            
            switch dismissType{
            case .none:
                self.isDismissing = false
                self.isPresented = false
                self.isShowing = false
                
                self.removeFromSuperview()
                
                break
            case .slideOut:
                var frame = self.containerView.frame
                
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 0.2, options: [.curveEaseOut], animations: {
                    frame.origin.y = self.frame.height + 50
                    self.containerView.frame = frame
                    }, completion: { _ in
                        self.isDismissing = false
                        self.isPresented = false
                        self.isShowing = false
                        
                        self.removeFromSuperview()
                })
                
                break
            case .bounceOut:
                var frame = self.containerView.frame
                
                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                    frame.origin.y -= 50
                    self.containerView.frame = frame
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                            frame.origin.y = self.frame.height + 50
                            self.containerView.frame = frame
                            }, completion:  { _ in
                                self.isDismissing = false
                                self.isPresented = false
                                self.isShowing = false
                                
                                self.removeFromSuperview()
                        })
                })
                break
            case .fadeOut:
                UIView.animate(withDuration: 0.5, animations: {
                    self.containerView.alpha = 0.0
                    }, completion: { _ in
                        self.isDismissing = false
                        self.isPresented = false
                        self.isShowing = false
                        
                        self.removeFromSuperview()
                })
                
                break
            case .growOut:
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseIn], animations: {
                    self.containerView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseIn], animations: {
                            self.containerView.alpha = 0.0
                            self.containerView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                            }, completion: { _ in
                                self.isDismissing = false
                                self.isPresented = false
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
        self.isPresented = true
        self.isShowing = false
        
        if autoDismiss{
            self.setDelayDuration(autoDismissDelay, task: {
                self.dismiss()
            })
        }
        return { _ in Void() }
    }
}

extension GDSwiftyPopup{
    func setDelayDuration(_ delayDuration: Double, task:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delayDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: task)
    }
}
