//
//  PackSearchViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 10/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class PackStoreSearchViewController: FormTemplateExtensionOfViewController {

    @IBOutlet weak var packNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var creatorTextField: UITextField!
    
    public var searchDataToPost = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackgroundImage(imageName: "packStoreSearchBackground")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func prepareSearchForCreatorsPack(){
        packNameTextField.text = ""
        locationTextField.text = ""
        creatorTextField.text = UserDefaults.standard.string(forKey: "Username")
        prepareSearchDataToPost()
    }
    
    private func prepareSearchDataToPost(){
        let packNameFrag = packNameTextField.text!
        let locationFrag = locationTextField.text!
        let creatorUsernameFrag = creatorTextField.text!
        searchDataToPost = "usernameFragment=\(creatorUsernameFrag)&packNameFragment=\(packNameFrag)&locationFragment=\(locationFrag)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNavCon = segue.destination as! UINavigationController
        if let targetController = destNavCon.topViewController as? PackStoreListTableViewController {
            if segue.identifier == "PackSearchToCreatorsPacksTable"{
                prepareSearchForCreatorsPack()
            } else if segue.identifier == "PackSearchToSearchResultsPacksTable"{
                prepareSearchDataToPost()
            }
            targetController.searchDataToPost = self.searchDataToPost
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
