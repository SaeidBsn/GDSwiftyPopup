//
//  GDSwiftyPopup.swift
//  LiberWave
//
//  Created by Saeid Basirnia on 5/12/16.
//  Copyright © 2016 Saeidbsn. All rights reserved.
//

import UIKit

public protocol GDSwiftyPopupDelegate: class{
    func onPopupDismiss()
}

public enum ViewDismissType: Int{
    case fadeOut
    case slideOut
    case bounceOut
    case growOut
}

public enum ViewShowType: Int{
    case fadeIn
    case slideIn
    case bounceIn
    case growIn
}

public enum BackgroundType{
    case blurredLight
    case blurredDark
    case dimmed
    case clear
}

public final class GDSwiftyPopup: UIView {
    public weak var delegate: GDSwiftyPopupDelegate? = nil
    public var dismissOnTouch: Bool = false
    public var dismissOnPopupTouch: Bool = false
    public var autoDismiss: Bool = false
    public var autoDismissDelay: Double = 3.0
    public var showType: ViewShowType = .fadeIn
    public var dismissType: ViewDismissType = .fadeOut
    public var backgroundType: BackgroundType = .dimmed
    
    private var backgroundBlurredView: UIVisualEffectView!
    private var containerView: UIView!
    private var isDismissing: Bool = false
    private var isShowing: Bool = false
    private var backgroundView: UIView!
    private var isPresented: Bool = false
    private var yConstraint: NSLayoutConstraint!
    
    //MARK: - init methods
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init(containerView: UIView){
        super.init(frame: UIScreen.main.bounds)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.containerView = containerView
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
        
        if let _ = backgroundBlurredView{
            self.addSubview(backgroundBlurredView)
        }
        if let _ = backgroundView{
            self.addSubview(backgroundView)
        }
        
        self.show()
        targetView.addSubview(self)
        
        self.setupConstraints()
        self.layoutIfNeeded()
    }
    
    //Setup view behaviors
    private func setupBackgroundView(){
        if backgroundType == .blurredDark{
            let blurEffect = UIBlurEffect(style: .dark)
            self.backgroundBlurredView = UIVisualEffectView(effect: blurEffect)
            self.backgroundBlurredView.frame = self.frame
            self.backgroundBlurredView.isUserInteractionEnabled = true
        }else if backgroundType == .blurredLight{
            let blurEffect = UIBlurEffect(style: .light)
            self.backgroundBlurredView = UIVisualEffectView(effect: blurEffect)
            self.backgroundBlurredView.frame = self.frame
            self.backgroundBlurredView.isUserInteractionEnabled = true
        }else{
            self.backgroundView = UIView()
            self.backgroundView.frame = self.frame
            self.backgroundView.isUserInteractionEnabled = true
            
            if backgroundType == .clear{
                self.backgroundView.backgroundColor = UIColor.clear
            }else if backgroundType == .dimmed{
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            }
        }
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchedRect = self.bounds.insetBy(dx: -10, dy: -10)
        
        if !touchedRect.contains(point){
            return nil
        }
        for v in self.subviews.reversed(){
            let cPoint = v.convert(point, from: self)
            let hitView = v.hitTest(cPoint, with: event)
            
            if hitView != nil{
                if dismissOnTouch{
                    if let _ = self.backgroundView{
                        if hitView == self.backgroundView{
                            dismiss()
                        }
                    }
                    if let _ = self.backgroundBlurredView{
                        if hitView == self.backgroundBlurredView{
                            dismiss()
                        }
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
        return nil
    }
    
    //MARK: - notification funcs
    func keyboardWillShow(notification: NSNotification) {
        guard let _ = yConstraint else{ return }
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.yConstraint.constant = -keyboardFrame.size.height / 2
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview!.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let _ = yConstraint else{ return }
        
        self.yConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview!.layoutIfNeeded()
        })
    }

    func didRotate(_ sender: Notification){
        guard let sView = superview else{ return }
        self.frame = sView.frame
        if let _ = backgroundBlurredView{
            self.backgroundBlurredView.frame = self.frame
        }
        if let _ = backgroundView{
            self.backgroundView.frame = self.frame
        }
    }
    
    //MARK: - setup constraints
    private func setupConstraints(){
        if #available(iOS 9.0, *) {
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20.0).isActive = true
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20.0).isActive = true
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0.0).isActive = true
            containerView.heightAnchor.constraint(lessThanOrEqualToConstant: containerView.frame.height).isActive = true

            yConstraint = containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0)
            yConstraint.isActive = true
            
            if containerView.frame.height > UIScreen.main.bounds.height{
                containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20.0).isActive = true
                containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -20.0).isActive = true
            }
        } else {
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
                constant: 20)

            let bottomConstraint = NSLayoutConstraint(
                item: self.containerView,
                attribute: .bottom,
                relatedBy: .greaterThanOrEqual,
                toItem: self,
                attribute: .bottom,
                multiplier: 1.0,
                constant: -20)
            
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

            let centerX = NSLayoutConstraint(
                item: self.containerView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0)

            self.yConstraint = NSLayoutConstraint(
                item: self.containerView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0)
            
            self.addConstraints([leftConstraint, rightConstraint, yConstraint, centerX, height, topConstraint, bottomConstraint])
        }
    }
    
    private func show(){
        if !isShowing && !isDismissing{
            isShowing = !isShowing
            
            switch showType{
            case .slideIn:
                self.addSubview(self.containerView)
                
                var frame = self.containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                    self.containerView.center.y = self.center.y
                }, completion: showCompletionBlock())
                
                
            case .bounceIn:
                self.addSubview(self.containerView)
                
                var frame = self.containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                    self.containerView.center.y = self.center.y
                }, completion: showCompletionBlock())
                
                
            case .fadeIn:
                self.addSubview(self.containerView)
                
                self.containerView.alpha = 0.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.containerView.alpha = 1.0
                }, completion: showCompletionBlock())
                
                
            case .growIn:
                self.addSubview(self.containerView)
                
                self.containerView.alpha = 0.0
                self.containerView.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [], animations: {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: showCompletionBlock())
                
            }
        }
    }
    
    public func dismiss(_ completionTask: (() -> ())? = nil){
        self.delegate?.onPopupDismiss()
        
        if !isDismissing && isPresented{
            isDismissing = !isDismissing
            
            switch dismissType{
            case .slideOut:
                var frame = self.containerView.frame
                
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 0.2, options: [.curveEaseOut], animations: {
                    frame.origin.y = self.frame.height + 50
                    self.containerView.frame = frame
                    self.alpha = 0
                }, completion: { _ in
                    self.isDismissing = false
                    self.isPresented = false
                    self.isShowing = false
                    
                    self.removeFromSuperview()
                    completionTask?()
                })
                
                
            case .bounceOut:
                var frame = self.containerView.frame
                
                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                    frame.origin.y -= 50
                    self.containerView.frame = frame
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(), animations: {
                        frame.origin.y = self.frame.height + 50
                        self.containerView.frame = frame
                        self.alpha = 0
                    }, completion:  { _ in
                        self.isDismissing = false
                        self.isPresented = false
                        self.isShowing = false
                        
                        self.removeFromSuperview()
                        completionTask?()
                    })
                })
                
            case .fadeOut:
                UIView.animate(withDuration: 0.5, animations: {
                    self.containerView.alpha = 0.0
                    self.alpha = 0
                }, completion: { _ in
                    self.isDismissing = false
                    self.isPresented = false
                    self.isShowing = false
                    
                    self.removeFromSuperview()
                    completionTask?()
                })
                
            case .growOut:
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseIn], animations: {
                    self.containerView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseIn], animations: {
                        self.containerView.alpha = 0.0
                        self.containerView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        self.alpha = 0
                    }, completion: { _ in
                        self.isDismissing = false
                        self.isPresented = false
                        self.isShowing = false
                        
                        self.removeFromSuperview()
                        completionTask?()
                    })
                })
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
        let time = DispatchTime.now() + delayDuration
        DispatchQueue.main.asyncAfter(deadline: time, execute: task)
    }
}
