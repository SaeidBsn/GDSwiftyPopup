//
//  ViewController.swift
//  GDSwiftyPopup
//
//  Created by Saeid Basirnia on 5/13/16.
//  Copyright © 2016 Saeidbsn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DismissViewDelegate {
    
    var popupView: GDSwiftyPopup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPopup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func show(sender: AnyObject){
        createPopup()
    }
    
    func createPopup(){
        let confirmView = NSBundle.mainBundle().loadNibNamed("AlertView", owner: self, options: nil)[0] as? AlertView
        confirmView?.confrimDelegate = self
        confirmView?.prepareView("I am a sample view! here can be any custom view!! :D", confirmTitle: "OK")
        
        //prepare popup view with custom UIView
        popupView = GDSwiftyPopup(containerView: confirmView!)
        
        //select dismiss type of popup view
        //Options: None, BounceOut, FadeOut, SlideOut, GrowOut
        popupView.dismissType = .BounceOut
        
        //select show type of popup view
        //Options: None, BounceOt, FadeIn, SlideIn, GrowIn
        popupView.showType = .BounceIn
        
        //select if background should be dimmed or not
        //Options: Dimmed, Clear
        popupView.dimmedType = .Dimmed
        
        //Popup view can be automatically dismissed.
        //autoDismiss presents if it should automatically dismissed or not
        //autoDismissDelay presents how long it should take
        popupView.autoDismiss = false
        popupView.autoDismissDelay = 1.0
        
        //allow closing popup with touching popup view background
        popupView.dismissOnTouch = false
        
        //allow closing popup with touching popup view itself
        popupView.dismissOnPopupTouch = false
        
        //create the popup view and show it in current view
        popupView.createPopupView(self.view, centerPoint: CGPointMake(self.view.center.x, self.view.center.y))
    }
    
    func onDismissed() {
        popupView.dismiss()
    }
}

