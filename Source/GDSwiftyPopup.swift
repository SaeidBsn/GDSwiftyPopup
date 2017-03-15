//
//  GDSwiftyPopup.swift
//  LiberWave
//
//  Created by Saeid Basirnia on 5/12/16.
//  Copyright © 2016 Saeidbsn. All rights reserved.
//

import UIKit

protocol GDSwiftyPopupDelegate{
    func onPopupDismiss()
}

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
    var delegate: GDSwiftyPopupDelegate? = nil
    public var containerView: UIView!
    
    open var dismissOnTouch: Bool = false
    open var dismissOnPopupTouch: Bool = false
    
    open var isDismissing: Bool = false
    open var isShowing: Bool = false
    
    open var autoDismiss: Bool = false
    open var autoDismissDelay: Double = 3.0
    
    open var showType: ViewShowType = .none
    open var dismissType: ViewDismissType = .none
    open var dimmedType: ViewDimmedType = .dimmed
    
    private var backgroundView: UIView!
    private var isPresented: Bool = false
    
    
    //Initialize view
    public init(containerView: UIView){
        super.init(frame: UIScreen.main.bounds)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.containerView = containerView
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Setup View
    public func createPopupView(_ onView: UIView? = nil){
        var targetView: UIView!
        if let target = onView{
            targetView = target
        }else{
            targetView = UIApplication.shared.delegate!.window!
        }
        
        self.setupBackgroundView()
        self.containerView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        self.addSubview(backgroundView)
        
        self.show()
        targetView.addSubview(self)
        
        self.setupConstraints()
        self.layoutIfNeeded()
    }
    
    //Setup view behaviors
    private func setupBackgroundView(){
        self.backgroundView = UIView()
        self.backgroundView.frame = self.frame
        self.backgroundView.isUserInteractionEnabled = true
        
        if dimmedType == .clear{
            self.backgroundView.backgroundColor = UIColor.clear
        }else if dimmedType == .dimmed{
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
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
    
    private func setupConstraints(){
        let height = NSLayoutConstraint(
            item: self.containerView,
            attribute: .height,
            relatedBy: .lessThanOrEqual,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: self.containerView.frame.height)
        
        let topConstraint = NSLayoutConstraint(
            item: self.containerView,
            attribute: .top,
            relatedBy: .greaterThanOrEqual,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 25)
        let bottomConstraint = NSLayoutConstraint(
            item: self.containerView,
            attribute: .bottom,
            relatedBy: .greaterThanOrEqual,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -25)
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
        let centerY = NSLayoutConstraint(
            item: self.containerView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0)
        let centerX = NSLayoutConstraint(
            item: self.containerView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        
        self.addConstraints([leftConstraint, rightConstraint, centerY, centerX, height, topConstraint, bottomConstraint])
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
    
    public func dismiss(_ completionTask: (() -> ())? = nil){
        self.delegate?.onPopupDismiss()
        
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
                    completionTask?()
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
                        completionTask?()
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
                    completionTask?()
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
                        completionTask?()
                    })
                })
                
                break
            }
        }
    }
    
    private func showCompletionBlock() -> (Bool) -> (){
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
    func setDelayDuration(_ delayDuration: Double, task: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delayDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: task)
    }
}
