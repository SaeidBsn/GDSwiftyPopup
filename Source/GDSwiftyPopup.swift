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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate(_:)), name:  UIDevice.orientationDidChangeNotification, object: nil)
        
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
            guard let topView = UIApplication.shared.keyWindow else { return }
            targetView = topView
        }
        
        setupBackgroundView()
        containerView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        
        if let _ = backgroundBlurredView{
            addSubview(backgroundBlurredView)
        }
        if let _ = backgroundView{
            addSubview(backgroundView)
        }
        show()
        targetView.addSubview(self)
        
        setupConstraints()
        layoutIfNeeded()
    }
    
    //Setup view behaviors
    private func setupBackgroundView(){
        if backgroundType == .blurredDark{
            let blurEffect = UIBlurEffect(style: .dark)
            backgroundBlurredView = UIVisualEffectView(effect: blurEffect)
            backgroundBlurredView.frame = frame
            backgroundBlurredView.isUserInteractionEnabled = true
        }else if backgroundType == .blurredLight{
            let blurEffect = UIBlurEffect(style: .light)
            backgroundBlurredView = UIVisualEffectView(effect: blurEffect)
            backgroundBlurredView.frame = frame
            backgroundBlurredView.isUserInteractionEnabled = true
        }else{
            backgroundView = UIView()
            backgroundView.frame = frame
            backgroundView.isUserInteractionEnabled = true
            
            if backgroundType == .clear{
                backgroundView.backgroundColor = UIColor.clear
            }else if backgroundType == .dimmed{
                backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            }
        }
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchedRect = bounds.insetBy(dx: -10, dy: -10)
        if !touchedRect.contains(point){ return nil }
        for v in subviews.reversed(){
            let cPoint = v.convert(point, from: self)
            let hitView = v.hitTest(cPoint, with: event)
            
            if hitView != nil{
                if dismissOnTouch{
                    if let _ = backgroundView{
                        if hitView == backgroundView{
                            dismiss()
                        }
                    }
                    if let _ = backgroundBlurredView{
                        if hitView == backgroundBlurredView{
                            dismiss()
                        }
                    }
                }
                if dismissOnPopupTouch{
                    if hitView == containerView{
                        dismiss()
                    }
                }
                return hitView
            }
        }
        return nil
    }
    
    //MARK: - notification funcs
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let _ = yConstraint else{ return }
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        yConstraint.constant = -keyboardFrame.size.height / 2
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview!.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        guard let _ = yConstraint else{ return }
        
        yConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layoutIfNeeded()
            self.superview!.layoutIfNeeded()
        })
    }
    
    @objc func didRotate(_ sender: Notification){
        guard let sView = superview else{ return }
        frame = sView.frame
        backgroundBlurredView?.frame = frame
        backgroundView?.frame = frame
    }
    
    //MARK: - setup constraints
    private func setupConstraints(){
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0).isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0.0).isActive = true
        containerView.heightAnchor.constraint(lessThanOrEqualToConstant: containerView.frame.height).isActive = true
        
        yConstraint = containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0)
        yConstraint.isActive = true
        
        if containerView.frame.height > UIScreen.main.bounds.height{
            containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 20.0).isActive = true
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -20.0).isActive = true
        }
    }
    
    private func show(){
        if !isShowing && !isDismissing{
            isShowing = !isShowing
            
            switch showType{
            case .slideIn:
                addSubview(containerView)
                
                var frame = containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 0.2, options: UIView.AnimationOptions(), animations: {
                    self.containerView.center.y = self.center.y
                }, completion: showCompletionBlock())
                
                
            case .bounceIn:
                addSubview(containerView)
                
                var frame = containerView.frame
                frame.origin.y = -50
                containerView.frame = frame
                
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIView.AnimationOptions(), animations: {
                    self.containerView.center.y = self.center.y
                }, completion: showCompletionBlock())
                
                
            case .fadeIn:
                addSubview(containerView)
                
                containerView.alpha = 0.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.containerView.alpha = 1.0
                }, completion: showCompletionBlock())
                
                
            case .growIn:
                addSubview(containerView)
                
                containerView.alpha = 0.0
                containerView.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [], animations: {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: showCompletionBlock())
                
            }
        }
    }
    
    public func dismiss(_ completionTask: (() -> ())? = nil){
        delegate?.onPopupDismiss()
        
        if !isDismissing && isPresented{
            isDismissing = !isDismissing
            
            switch dismissType{
            case .slideOut:
                var frame = containerView.frame
                
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
                var frame = containerView.frame
                
                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: UIView.AnimationOptions(), animations: {
                    frame.origin.y -= 50
                    self.containerView.frame = frame
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIView.AnimationOptions(), animations: {
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
        isDismissing = false
        isPresented = true
        isShowing = false
        
        if autoDismiss{
            setDelayDuration(autoDismissDelay, task: {
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
