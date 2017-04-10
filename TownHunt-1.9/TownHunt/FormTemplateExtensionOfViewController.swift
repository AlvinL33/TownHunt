//
//  FormTemplateExtensionOfViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 22/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class FormTemplateExtensionOfViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillShow(sender: NSNotification){
        self.view.frame.origin.y = -150
    }
    
    func keyboardWillHide(sender: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    
    func isEmailValid(testStr:String) -> Bool {
        let emailRegExPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTester = NSPredicate(format:"SELF MATCHES %@", emailRegExPattern)
        return emailTester.evaluate(with: testStr)
    }
    
    func isAlphanumeric(testStr:String) -> Bool {
        let alphanumericRegExPattern = "^[:alnum:]+$"
        let stringTester = NSPredicate(format:"SELF MATCHES %@", alphanumericRegExPattern)
        return stringTester.evaluate(with: testStr)
    }

}
