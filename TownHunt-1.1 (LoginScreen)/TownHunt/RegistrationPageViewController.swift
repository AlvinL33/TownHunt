//
//  RegistrationPageViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 18/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class RegistrationPageViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userRepeatPassWordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "registrationBackgroundImage")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func registerButtonTapped(_ sender: Any) {
        
        let username = usernameTextField.text
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        let userRepeatPassword = userRepeatPassWordTextField.text
        
        //Check for empty fields
        
        if((username?.isEmpty)! || (userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userRepeatPassword?.isEmpty)!) {
            
            //Display error message
            
            displayAlertMessage(alertTitle: "Data Entry Error", alertMessage: "All fields must be complete")
            
            return
        }
        
        //Check if passwords are the same
        
        if(userPassword != userRepeatPassword){
            
            //Displays error message
            displayAlertMessage(alertTitle: "ERROR", alertMessage: "Passwords do not match")

            return
        }
        
        //Sends data to be posted and receives a response
        let responseJSON = DatabaseInteraction().postToDatabase(apiName: "registerUser.php", postData: "username=\(username!)&userEmail=\(userEmail!)&userPassword=\(userPassword!)"){ (dbResponse: NSDictionary) in
        
        //If there is an error, the error is presented to the user
            
            var alertTitle = "ERROR"
            var alertMessage = "JSON File Invalid"
            var isUserRegistered = false
            
            if dbResponse["error"]! as! Bool{
                print("error: \(dbResponse["error"]!)")
                alertTitle = "ERROR"
                alertMessage = dbResponse["message"]! as! String
            }
            else if !(dbResponse["error"]! as! Bool){
                alertTitle = "Thank You"
                alertMessage = dbResponse["message"]! as! String
                isUserRegistered = true
            }
            else{
                alertTitle = "ERROR"
                alertMessage = "JSON File Invalid"
            }
            
            DispatchQueue.main.async(execute: {
                let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    if isUserRegistered{
                        self.dismiss(animated: true, completion: nil)
                    }}))
                self.present(alertCon, animated: true, completion: nil)
            })
        }
    
    }
    
    @IBAction func alreadyHaveAccountButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }


}
