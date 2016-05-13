//
//  AlertView.swift
//  LiberWave
//
//  Created by Saeid Basirnia on 5/13/16.
//  Copyright © 2016 TalosDigital. All rights reserved.
//

import UIKit

protocol DismissViewDelegate{
    func onDismissed()
}

class AlertView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    var confrimDelegate: DismissViewDelegate? = nil
    
    override func awakeFromNib(){
        self.layer.cornerRadius = 10
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func prepareView(title: String, confirmTitle: String){
        self.titleLabel.text = title
        
        self.dismissButton.setTitle(confirmTitle, forState: .Normal)
        self.dismissButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
        self.dismissButton.layer.cornerRadius = 4.0
        self.dismissButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        self.layoutIfNeeded()
    }
    
    @IBAction func dismiss(sender: UIButton){
        confrimDelegate?.onDismissed()
    }
    
}
