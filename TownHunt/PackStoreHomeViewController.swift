//
//  PinStoreHomeViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 10/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class PackStoreHomeViewController: UIViewController {
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackgroundImage(imageName: "packStoreHomeBackground")
        
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // Preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PackStoreHomeToLocalTableList"{
            let navigationController = segue.destination as! UINavigationController
            if let nextViewController = navigationController.topViewController as? PackStoreListTableViewController{
                nextViewController.loadLocalPacksFlag = true
                navigationController.title = "List of Local Packs"
            }
        }
    }

}
