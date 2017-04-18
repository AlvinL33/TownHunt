//
//  UIViewControllerExtension.swift
//  TownHunt
//
//  Created by Alvin Lee on 15/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func setBackgroundImage(imageName: String){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: imageName)?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    
}
