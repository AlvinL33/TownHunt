
//
//  NewMapPackCreationViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 27/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class NewPinPackRegisViewController: FormTemplateExtensionOfViewController {

    //var completionHandler : ((_ newPinPackCreationViewController:NewPinPackCreationViewController) -> Void)?
    
    @IBOutlet weak var packNameTextField: UITextField!
    @IBOutlet weak var briefDescripTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var gameTimeTextLabel: UILabel!
    @IBOutlet weak var timeControlStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "newPackDetailsBackgroundImage")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
        timeStepperAction(Any.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createPackButtonTapped(_ sender: Any) {
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            // Initialises pack data variables obtained from the registration form
            let packName = packNameTextField.text
            let packDescrip = briefDescripTextField.text
            let creatorID = UserDefaults.standard.string(forKey: "UserID")
            let creatorName = UserDefaults.standard.string(forKey: "Username")
            let packLocation = locationTextField.text
            let gameTime = String(Int(timeControlStepper.value))
            
            //Sends data to be posted and receives a response
            let responseJSON = DatabaseInteraction().postToDatabase(apiName: "registerNewPinPack.php", postData: "packName=\(packName!)&description=\(packDescrip!)&creatorID=\(creatorID!)&location=\(packLocation!)&gameTime=\(gameTime)"){ (dbResponse: NSDictionary) in
                
                // Default error variables inisialised
                var alertTitle = "ERROR"
                var alertMessage = "JSON File Invalid"
                var isNewPackRegistered = false
                
                // If a database error exists, the  database response message is presented to the user
                if dbResponse["error"]! as! Bool{
                    alertTitle = "ERROR"
                    alertMessage = dbResponse["message"]! as! String
                } // If there is no database error the JSON file is saved
                else if !(dbResponse["error"]! as! Bool){
                    
                    // Prepares pack info to save to local storage
                    let fileName = packName?.replacingOccurrences(of: " ", with: "_")
                    let packInfo = dbResponse["packData"] as! NSDictionary
                    let packID = packInfo["PackID"]! as! String
                    
                    // The NSDictionary which will become the JSON file
                    let jsonToWrite = ["PackName": packName!, "Description": packDescrip!, "PackID": packID, "Location": packLocation!, "TimeLimit": gameTime, "Creator" : creatorName!, "CreatorID": creatorID!, "Version": "0", "Pins": []] as [String : Any]
                    
                    // Stores the pack details (JSON file) to local storage via the LocalStorageHandler class
                    let storageHandler = LocalStorageHandler(fileName: fileName!, subDirectory: "User-\(creatorID!)-Packs", directory: .documentDirectory)
                    if storageHandler.addNewPackToPhone(packData: jsonToWrite as NSDictionary){
                        alertTitle = "Thank You"
                        alertMessage = "Pack Sucessfully Created"
                        isNewPackRegistered = true
                    }
                    else{
                        alertTitle = "ERROR"
                        alertMessage = "Couldn't Save Register Pack"
                    }
                }
                else{
                    alertTitle = "ERROR"
                    alertMessage = "JSON File Invalid"
                }
                
                // Displays a message to the user indicating the sucessfull/unsucessfull creation of a new pack
                DispatchQueue.main.async(execute: {
                    let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                    alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        if isNewPackRegistered{
                            self.dismiss(animated: true, completion: nil)
                        }}))
                    self.present(alertCon, animated: true, completion: nil)
                })
            }
        }else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the getDBAccountStats function until internet connectivity is restored
                self.createPackButtonTapped(Any.self)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func timeStepperAction(_ sender: Any) {
        gameTimeTextLabel.text = "Game Time: \(Int(timeControlStepper.value)) mins"
    }
    

}
