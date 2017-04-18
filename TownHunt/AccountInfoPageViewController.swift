//
//  AccountInfoPageViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 18/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class AccountInfoPageViewController: UIViewController, ModalTransitionListener {

    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
    @IBOutlet weak var userIDInfoLabel: UILabel!
    @IBOutlet weak var usernameInfoLabel: UILabel!
    @IBOutlet weak var emailInfoLabel: UILabel!
    @IBOutlet weak var noPacksPlayedInfoLabel: UILabel!
    @IBOutlet weak var noPacksCreatedInfoLabel: UILabel!
    @IBOutlet weak var totCompPointsLabel: UILabel!
    
    private var noPacksPlayed = 0
    private var noPacksCreated = 0
    private var totCompPoints = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ModalTransitionMediator.instance.setListener(listener: self)
        
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        setBackgroundImage(imageName: "accountInfoBackgroundImage")
        
        loadAccountDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func LogoutButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.removeObject(forKey: "UserID")
        UserDefaults.standard.removeObject(forKey: "Username")
        UserDefaults.standard.removeObject(forKey: "UserEmail")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "loginViewAfterLogout", sender: self)
        
    }
    
    private func getDBAccountStats(userID: String){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            let responseJSON = DatabaseInteraction().postToDatabase(apiName: "getAccountStats.php", postData: "userID=\(userID)"){ (dbResponse: NSDictionary) in
                
                //If there is an error, the error is presented to the user
                
                self.noPacksPlayed = Int(dbResponse["totalNumPacksPlayed"]! as! String)!
                self.noPacksCreated = Int(dbResponse["totalNumPacksCreated"]! as! String)!
                self.totCompPoints = Int(dbResponse["totalNumCompPoints"]! as! String)!
                
                print(self.noPacksPlayed)
                print(self.noPacksCreated)
                print(self.totCompPoints)
                
                DispatchQueue.main.async(execute: {
                    self.noPacksPlayedInfoLabel.text = "No Of Packs Played: \(self.noPacksPlayed)"
                    self.noPacksCreatedInfoLabel.text = "No Of Packs Created: \(self.noPacksCreated)"
                    self.totCompPointsLabel.text = "Total Competitive Points: \(self.totCompPoints)"
                })
            }
        }else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the getDBAccountStats function until internet connectivity is restored
                self.getDBAccountStats(userID: userID)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
    }

    private func loadAccountDetails(){
        
        let userID = UserDefaults.standard.string(forKey: "UserID")!
        let username = UserDefaults.standard.string(forKey: "Username")!
        let userEmail = UserDefaults.standard.string(forKey: "UserEmail")!
        
        userIDInfoLabel.text = "User ID: \(userID)"
        usernameInfoLabel.text = "Username: \(username)"
        emailInfoLabel.text = "Email: \(userEmail)"
        getDBAccountStats(userID: userID)
    }
    
    func modalViewDismissed(){
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.loadAccountDetails()
    }
}
