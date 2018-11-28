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
    }
    
    func prepareView(_ title: String, confirmTitle: String){
        self.titleLabel.text = title
        
        self.dismissButton.setTitle(confirmTitle, for: UIControl.State())
        self.dismissButton.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.dismissButton.layer.cornerRadius = 4.0
        self.dismissButton.setTitleColor(UIColor.white, for: UIControl.State())
        
        self.layoutIfNeeded()
    }
    
    @IBAction func dismiss(_ sender: UIButton){
        confrimDelegate?.onDismissed()
    }
    
}
