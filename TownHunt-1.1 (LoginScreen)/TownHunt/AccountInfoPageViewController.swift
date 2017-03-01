//
//  AccountInfoPageViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 18/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class AccountInfoPageViewController: UIViewController {

    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
    @IBOutlet weak var userIDInfoLabel: UILabel!
    @IBOutlet weak var usernameInfoLabel: UILabel!
    @IBOutlet weak var emailInfoLabel: UILabel!
    @IBOutlet weak var noPacksPlayedInfoLabel: UILabel!
    @IBOutlet weak var noPacksCreatedInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "accountInfoBackgroundImage")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
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

    private func loadAccountDetails(){
        userIDInfoLabel.text = "User ID: \(UserDefaults.standard.string(forKey: "UserID")!)"
        usernameInfoLabel.text = "Username: \(UserDefaults.standard.string(forKey: "Username")!)"
        emailInfoLabel.text = "Email: \(UserDefaults.standard.string(forKey: "UserEmail")!)"
        noPacksPlayedInfoLabel.text = "No Of Packs Played: 0"
        noPacksCreatedInfoLabel.text = "No Of Packs Created: 0"

    }
}
