//
//  RoundedButton.swift
//  TownHunt
//
//  Created by iD Student on 7/27/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        //setTitleColor(tintColor, for: UIControlState())
        //setTitleColor(UIColor.white, for: .highlighted)
    }
}
