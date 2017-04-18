//
//  RegistrationPageViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 18/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class RegistrationPageViewController: FormTemplateExtensionOfViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userRepeatPassWordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage(imageName: "registrationBackgroundImage")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func registerButtonTapped(_ sender: Any) {
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            let username = usernameTextField.text
            let userEmail = userEmailTextField.text
            let userPassword = userPasswordTextField.text
            let userRepeatPassword = userRepeatPassWordTextField.text
            
            //Check for empty fields
            
            if((username?.isEmpty)! || (userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userRepeatPassword?.isEmpty)!) {
                
                //Display error message
                
                displayAlertMessage(alertTitle: "Data Entry Error", alertMessage: "All fields must be complete")
                
                return
            
            // Checks if email is a valid email address
            } else if !isEmailValid(testStr: userEmail!){
                
                displayAlertMessage(alertTitle: "Email Invalid", alertMessage: "Please enter a valid email")
                return
            
            // Checks if username only contains alphanumberic characters
            } else if !isAlphanumeric(testStr: username!){
                displayAlertMessage(alertTitle: "Username Invalid", alertMessage: "Username must only contain alphanumeric characters")
                return
                
            //Check if username character length is greater than 20
            }else if((username?.characters.count)! > 20){
                
                //Displays error message
                displayAlertMessage(alertTitle: "Username is Greater Than 20 Characters", alertMessage: "Please enter a username which is less than or equal to 20 characters")
                
                return
            
            //Check if passwords are the same
            }else if(userPassword != userRepeatPassword){
                
                //Displays error message
                displayAlertMessage(alertTitle: "Passwords Do Not Match", alertMessage: "Please enter matching passwords")

                return
            } else{
            
                //Sends data to be posted and receives a response
                let responseJSON = dbInteraction.postToDatabase(apiName: "registerUser.php", postData: "username=\(username!)&userEmail=\(userEmail!)&userPassword=\(userPassword!)"){ (dbResponse: NSDictionary) in
                
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
        }else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the register function until internet connectivity is restored
                self.registerButtonTapped(Any.self)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
    }
    
    @IBAction func alreadyHaveAccountButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }


}
