# GDSwiftyPopup

Customizable View for presenting any custom view as popups
Popup view can be presented on any view.

![image](https://cloud.githubusercontent.com/assets/9967486/15256618/8501d938-1957-11e6-8292-1aa9203a0428.gif)


# Requirements
- Xcode 10+
- Swift 4.2
- iOS 9+


# Installation
Install manually
------
Drag `GDSwiftyPopup.swift` to your project and use!


# How to use

```swift 
    var popupView: GDSwiftyPopup!

    //Prepare popup view with custom UIView
    popupView = GDSwiftyPopup(containerView: confirmView)
    
    //Select dismiss type
    //Options: None, BounceOut, FadeOut, SlideOut, GrowOut
    popupView.dismissType = .BounceOut
    
    //Select show type
    //Options: None, BounceOt, FadeIn, SlideIn, GrowIn
    popupView.showType = .BounceIn
    
    //Select if background type
    //Options: .dimmed, clear, blurredLight, blurredDark
    popupView.dimmedType = .blurredLight
    
    //Popup view can be automatically dismissed.
    //autoDismiss presents if it should automatically dismissed or not
    //autoDismissDelay presents how long it should take
    popupView.autoDismiss = false
    popupView.autoDismissDelay = 1.0
    
    //Allow dismissing popup with touching the background
    popupView.dismissOnTouch = false
    
    //Allow dismissing popup with touching the popup view
    popupView.dismissOnPopupTouch = false
    
    //Create the popup view and show it
    //popupView.createPopupView(SomeSpecificView) // <- On specific view
    popupView.createPopupView() // <- On app window


    //Dismiss the popup:
    popupView.dismiss()

    //Dismiss with a completion
    popupView.dismiss{
        // some stuff to do
    }
```
