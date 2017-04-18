//
//  MainGamePackSelectorViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 07/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class MainGamePackSelectorViewController: FormTemplateExtensionOfViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var delegate: MainGameModalDelegate?
    
    @IBOutlet weak var packPicker: UIPickerView!
    @IBOutlet weak var gameTypeSegCon: UISegmentedControl!
    @IBOutlet weak var selectMapButton: UIButton!
    @IBOutlet weak var viewLeaderboardButton: UIButton!
    
    private var allPacksDict = [String: String]()
    private var pickerData = [String]()
    private var selectedPickerData: String = ""
    private var gameType = "competitive"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackgroundImage(imageName: "packSelectorBackground")
        
        self.packPicker.delegate = self
        self.packPicker.dataSource = self
        setUpPicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Populates the picker with the names of local packs
    private func setUpPicker(){
        let defaults = UserDefaults.standard
        // Retrieves the list of user ids whose packs are found in local storage
        let listOfUsersOnPhone = defaults.array(forKey: "listOfLocalUserIDs")
        if !(listOfUsersOnPhone!.isEmpty){
            // Iterates over every id and retrieves all packs on the phone
            for userID in listOfUsersOnPhone as! [String]{
                let userPackDictName = "UserID-\(userID)-Packs"
                if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName) {
                    // Appends all pack names and their creator user id to the allPacksDict
                    for pack in Array(dictOfPacksOnPhone.keys){
                        self.allPacksDict[pack] = userID
                    }
                }
                // Sorts the picker data in ascending order
                self.pickerData = Array(allPacksDict.keys).sorted(by: <)
                self.selectedPickerData = pickerData[0]
            }
        // If there are no local packs, pack interaction buttons are hidden and a message is shown to the user
        } else if pickerData.isEmpty {
            self.pickerData = ["No Packs Found"]
            self.selectMapButton.isHidden = true
            self.viewLeaderboardButton.isHidden = true
        }
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Numbers of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    // The picker data to return for a certain row and column
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
    
    // Retrieves which item is currently selected by the user
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedPickerData = pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 330, height: 30));
        label.lineBreakMode = .byWordWrapping;
        label.numberOfLines = 0;
        label.text = pickerData[row]
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: CGFloat(20))
        label.sizeToFit()
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch gameTypeSegCon.selectedSegmentIndex
        {
        case 0:
            gameType = "competitive"
        case 1:
            gameType = "casual"
        default:
            break
        }
    }
    
    @IBAction func tapForInfoButtonTapped(_ sender: Any) {
        let displayMessage = "Competitive mode: 5 Pins will be initially appear with more and more pins being added as the game progresses. You will have to hunt for the pins under a time limit. \n\nCasual mode: All of the pins in the pack will appear. Hunt them all in your own time with no time limit. \n\nYour first competitive playthrough score will be added to the leaderboard. If your first playthrough was casual, no future scores for that pack will count in the leaderboard"
        displayAlertMessage(alertTitle: "Competitive or Casual?", alertMessage: displayMessage)
        
    }
    
    @IBAction func selectPackButtonTapped(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.packSelectedHandler(selectedPackKey: self.selectedPickerData, packCreatorID: self.allPacksDict[self.selectedPickerData]!, gameType: gameType)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PackSelectorToLeaderboard" {
            let destNavCon = segue.destination as! UINavigationController
            if let targetController = destNavCon.topViewController as? LeaderboardViewController{
                targetController.selectedPackKey = self.selectedPickerData
                targetController.packCreatorID = self.allPacksDict[self.selectedPickerData]!
            }
        }
    }
}
