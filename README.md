# GDSwiftyPopup

Customizable View for presenting any custom view as popups
Popup view can be presented on any view.

![image](https://cloud.githubusercontent.com/assets/9967486/15256618/8501d938-1957-11e6-8292-1aa9203a0428.gif)


# Requirements
xcode 8+

swift 3+

iOS 8+


# Installation
Install manually
------
Drag "GDSwiftyPopup.swift" to your project and use!

Install using Cocoapods
------
Soon!



# How to use
```    
    var popupView: GDSwiftyPopup!

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
    
    //create the popup view and show it in current view / any view or nil for 
    //showing on app window
    popupView.createPopupView(self.view, centerPoint: CGPointMake(self.view.center.x, self.view.center.y))


    //to dismiss the alert use:
    popupView.dismiss()

    //or with completion
    popupView.dismiss{
        // some stuff to do
    }
```