//
//  PackListTableViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 10/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class PackStoreListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var infoBarButton: UIButton!
    @IBOutlet var packListTable: UITableView!
    
    public var loadLocalPacksFlag = false
    public var searchDataToPost = ""
    public var packListTableData = [[String: String]]()
    public var selectedPackDetails = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        packListTable.delegate = self
        packListTable.dataSource = self
        
        if !searchDataToPost.isEmpty{
            self.navigationItem.title = "Store Search Results"
            searchDatabaseForPacks()
        } else if loadLocalPacksFlag == true{
            self.navigationItem.title = "List Of Local Packs"
            loadLocalPacksIntoView()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateInfoBarMessage(message: String){
        infoBarButton.setTitle(message, for: UIControlState())
    }
    
    private func loadDataIntoTable(data: [[String: String]]){
        packListTableData = data.sorted{ ($0["PackName"])! < ($1["PackName"])! }
        packListTable.reloadData()
    }
    
    private func loadLocalPacksIntoView(){
        packListTableData = [[String: String]]()
        let defaults = UserDefaults.standard
        // Retrieves the list of user ids whose packs are found in local storage
        if let listOfUsersOnPhone = defaults.array(forKey: "listOfLocalUserIDs"){
            // Iterates over every id and retrieves all packs on the phone
            for userID in listOfUsersOnPhone as! [String]{
                let userPackSubDirectory = "UserID-\(userID)-Packs"
                if let displayNameFilenamePairs = defaults.dictionary(forKey: userPackSubDirectory) {
                    // Appends all pack names and their creator user id to the allPacksDict
                    for filename in Array(displayNameFilenamePairs.values){
                        let storageHandler = LocalStorageHandler(fileName: filename as! String, subDirectory: userPackSubDirectory, directory: .documentDirectory)
                        var packOnPhone = storageHandler.retrieveJSONData() as! [String:Any]
                        packOnPhone.removeValue(forKey: "Pins")
                        packListTableData.append(packOnPhone as! [String:String])
                    }
                }
                
            }
        }
        loadDataIntoTable(data: packListTableData)
        if packListTableData.isEmpty{
            updateInfoBarMessage(message: "0 Results Found")
            let alertCon = UIAlertController(title: "Error", message: "No packs found on the device. Search for and download some packs!", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil) }))
            self.present(alertCon, animated: true, completion: nil)
        }else{
            updateInfoBarMessage(message: "\(packListTableData.count) Result(s) Found")
        }
    }
    
    private func downloadPackFromDB(packID: String){
        retrieveDataFromDatabase(api: "getPinsFromPack.php", postData: "packID=\(packID)")
    }
    
    private func searchDatabaseForPacks(){
        retrieveDataFromDatabase(api: "packSearch.php", postData: searchDataToPost)
    }
    
    private func getFileNameAndSubDirString(packName: String, creatorID: String) -> [String:String]{
        let fileName = (packName).replacingOccurrences(of: " ", with: "_")
        let subDirect = "UserID-\(creatorID)-Packs"
        return ["fileName":fileName, "subDirectory": subDirect]
    }
    
    private func deleteSelectedLocalPack(packName: String, packLocation: String, creatorID: String){
        let filePathDetails = getFileNameAndSubDirString(packName: packName, creatorID: creatorID)
        let storageHandler = LocalStorageHandler(fileName: filePathDetails["fileName"]!, subDirectory: filePathDetails["subDirectory"]!, directory: .documentDirectory)
        if storageHandler.deleteFile(packName: packName, packLocation: packLocation, creatorID: creatorID) {
            displayAlertMessage(alertTitle: "Success", alertMessage: "\(packName) was deleted from the phone")
            loadLocalPacksIntoView()
        } else{
            displayAlertMessage(alertTitle: "Error", alertMessage: "\(packName) could not be deleted from the phone")
        }
        
    }
    
    private func savePackToLocalStorage(storageHandler: LocalStorageHandler, dataToWrite: NSDictionary){
        // If there is an error with saving the json file, the user is presented with an alert with details of the error
        if storageHandler.addNewPackToPhone(packData: dataToWrite as NSDictionary){
            displayAlertMessage(alertTitle: "Success", alertMessage: "\(dataToWrite["PackName"]! as! String) Saved To Phone")
        } else{
            displayAlertMessage(alertTitle: "Error", alertMessage: "\(dataToWrite["PackName"]! as! String) Wasn't 'Saved To Phone")
        }
    }
    
    private func preparePackToSave(pins: [[String:String]], didContainPins: Bool){
        var jsonToWrite = selectedPackDetails
        jsonToWrite.removeValue(forKey: "CreatorUsername")
        
        if didContainPins{
            jsonToWrite["Pins"] = pins
        } else{
            jsonToWrite["Pins"] = []
        }
        
        let filePathDetails = getFileNameAndSubDirString(packName: jsonToWrite["PackName"] as! String, creatorID: jsonToWrite["CreatorID"] as! String)
        
        //Stores the pack details (JSON file) to local storage via the LocalStorageHandler class
        let storageHandler = LocalStorageHandler(fileName: filePathDetails["fileName"]!, subDirectory: filePathDetails["subDirectory"]!, directory: .documentDirectory)
        
        if storageHandler.getDoesFileExist() == true{
            let alertCon = UIAlertController(title: "A Version Of The Pack Exists On The Phone", message: "Do you want to overwrite the version on the phone with the downloaded pack?", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertCon.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
                self.savePackToLocalStorage(storageHandler: storageHandler, dataToWrite: jsonToWrite as NSDictionary)}))
            self.present(alertCon, animated: true, completion: nil)
        } else{
            self.savePackToLocalStorage(storageHandler: storageHandler, dataToWrite: jsonToWrite as NSDictionary)
        }

    }
    
    private func retrieveDataFromDatabase(api: String, postData: String){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            let responseJSON = dbInteraction.postToDatabase(apiName: api, postData: postData){ (dbResponse: NSDictionary) in
                
                let isError = dbResponse["error"]! as! Bool
                var errorMessage = ""
                
                if isError{
                    errorMessage = dbResponse["message"]! as! String
                }
                
                // Displays a message to the user indicating the sucessfull/unsucessfull creation of a new pack
                DispatchQueue.main.async(execute: {
                    if isError{
                        let alertCon = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                            if api == "packSearch.php"{ self.dismiss(animated: true, completion: nil) }}))
                        self.present(alertCon, animated: true, completion: nil)
                    } else{
                        if api == "packSearch.php"{
                            let searchResults = dbResponse["searchResult"] as! [[String: String]]
                            self.loadDataIntoTable(data: searchResults)
                            self.updateInfoBarMessage(message: "\(searchResults.count) Pack(s) Found")
                        } else if api == "getPinsFromPack.php"{
                            let packContainsPinsFlag = dbResponse["packContainsPinsFlag"]! as! Bool
                            if  packContainsPinsFlag {
                                self.preparePackToSave(pins: dbResponse["Pins"] as! [[String: String]], didContainPins: true)
                            } else{
                                self.preparePackToSave(pins: [[:]], didContainPins: false)
                            }
                        }
                    }

                })
            }
        } else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the function until internet connectivity is restored
                self.retrieveDataFromDatabase(api: api, postData: postData)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packListTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "packInfoCell", for: indexPath) as! PackStoreListTableViewCell
        
        let pack = packListTableData[indexPath.row]
        cell.packNameLabel?.text = pack["PackName"]!
        cell.locationLabel?.text = "Location: \(pack["Location"]!)"
        cell.descriptionLabel?.text = pack["Description"]!
        if let creatorUsername = pack["CreatorUsername"]{
            cell.creatorNameLabel?.text = "Made By: \(creatorUsername)"
        } else{
            cell.creatorNameLabel?.text = ""
        }
        cell.gameTimeLabel?.text = "Time Cap:\(pack["TimeLimit"]!)mins"
        
        return cell
    }
    @IBAction func helpButtonTapped(_ sender: Any) {
        var alertMessage = "Tap a pack to"
        if loadLocalPacksFlag == true{
            alertMessage = alertMessage + " delete it from the phone"
        } else{
            alertMessage = alertMessage + " download it onto the phone"
        }
        displayAlertMessage(alertTitle: "Help", alertMessage: alertMessage)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPackDetails = packListTableData[indexPath.row]
        if loadLocalPacksFlag == true{
            let alertCon = UIAlertController(title: selectedPackDetails["PackName"]! as? String, message: "Location: \(selectedPackDetails["Location"]!)\n\nAbout: \(selectedPackDetails["Description"]!)!\n\nTime Cap: \(selectedPackDetails["TimeLimit"]!)mins\n\nVersion: \(selectedPackDetails["Version"]!)", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
                self.deleteSelectedLocalPack(packName: self.selectedPackDetails["PackName"]! as! String, packLocation: self.selectedPackDetails["Location"]! as! String, creatorID: self.selectedPackDetails["CreatorID"]! as! String)
            }))
            alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertCon, animated: true, completion: nil)
        } else{
            let alertCon = UIAlertController(title: selectedPackDetails["PackName"]! as? String, message: "Made By: \(selectedPackDetails["CreatorUsername"]!)\n\nLocation: \(selectedPackDetails["Location"]!)\n\nAbout: \(selectedPackDetails["Description"]!)!\n\nTime Cap: \(selectedPackDetails["TimeLimit"]!)mins\n\nVersion: \(selectedPackDetails["Version"]!)", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Download", style: .destructive, handler: {action in
                self.downloadPackFromDB(packID: self.selectedPackDetails["PackID"]! as! String)}))
            alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertCon, animated: true, completion: nil)
        }
    }

    @IBAction func backNavBarButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
