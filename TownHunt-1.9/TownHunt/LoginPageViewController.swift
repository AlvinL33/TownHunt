//
//  LoginPageViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 18/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class LoginPageViewController: FormTemplateExtensionOfViewController {

    //var completionHandler: ((_ loginPageViewController:LoginPageViewController) -> Void)?
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "loginBackgroundImage")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            let userEmail = userEmailTextField.text
            let userPassword = userPasswordTextField.text
        
            if((userEmail?.isEmpty)! || (userPassword?.isEmpty)!) {
                
                //Display error message
                
                displayAlertMessage(alertTitle: "Data Entry Error", alertMessage: "All fields must be complete")
                
                return
            } else if !isEmailValid(testStr: userEmail!){
                
                displayAlertMessage(alertTitle: "Email Invalid", alertMessage: "Please enter a valid email")
                return
            }

            //Sends data to be posted and receives a response
            let responseJSON = dbInteraction.postToDatabase(apiName: "loginUser.php", postData: "userEmail=\(userEmail!)&userPassword=\(userPassword!)"){ (dbResponse: NSDictionary) in
                
                //If there is an error, the error is presented to the user
                
                var alertTitle = "ERROR"
                var alertMessage = "JSON File Invalid"
                var isAccountFound = false
                
                if dbResponse["error"]! as! Bool{
                    print("error: \(dbResponse["error"]!)")
                    alertTitle = "ERROR"
                    alertMessage = dbResponse["message"]! as! String
                }
                else if !(dbResponse["error"]! as! Bool){
                    alertTitle = "Thank You"
                    alertMessage = "Successfully Logged In"
                    
                    isAccountFound = true
                    
                    let accountDetails = dbResponse["accountInfo"]! as! NSDictionary
                    print(accountDetails["Email"] as! String)
                    
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    UserDefaults.standard.set(accountDetails["UserID"]! as! String, forKey: "UserID")
                    UserDefaults.standard.set(accountDetails["Username"]! as! String, forKey: "Username")
                    UserDefaults.standard.set(accountDetails["Email"]! as! String, forKey: "UserEmail")
                    UserDefaults.standard.synchronize()
                }
                else{
                    alertTitle = "ERROR"
                    alertMessage = "JSON File Invalid"
                }
                
                DispatchQueue.main.async(execute: {
                    let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                    alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        if isAccountFound{
                            self.dismiss(animated: true, completion: nil)
                            ModalTransitionMediator.instance.sendModalViewDismissed(modelChanged: true)
                        }}))
                    self.present(alertCon, animated: true, completion: nil)
                })
            }
        }else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the function until internet connectivity is restored
                self.loginButtonTapped(Any.self)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
        
    }
    
    override func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }

}
