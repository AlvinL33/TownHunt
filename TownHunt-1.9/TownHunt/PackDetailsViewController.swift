//
//  PackDetailsViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 25/03/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class PackDetailsViewController: FormTemplateExtensionOfViewController {

    var packDetails = [:] as [String: String]
    
    @IBOutlet weak var packNameTextField: UITextField!
    @IBOutlet weak var briefDescriptionTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var timeControlStepper: UIStepper!
    @IBOutlet weak var gameTimeTextLabel: UILabel!
    @IBOutlet weak var gameTimeStaticLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editDetailButton: UIButton!
    
    public var isPackDetailsEditable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeStepperAction(Any.self)
        setUpForm()
        
        if isPackDetailsEditable == false{
            editDetailButton.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setUpForm(){
        changeFormEnabledStatus()
        packNameTextField.text = packDetails["PackName"]!
        briefDescriptionTextField.text = packDetails["Description"]!
        locationTextField.text = packDetails["Location"]!
        let timeLimit = packDetails["TimeLimit"]!
        gameTimeTextLabel.text = "Game Time: \(timeLimit) mins"
        gameTimeStaticLabel.text = "Game Time: \(timeLimit) mins"
        timeControlStepper.value = Double(Int(timeLimit)!)
        backButton.isHidden = false
    }
    
    
    // Changes the fields from being disabled (user-uneditable) to enabled (user-editable) and vice versa
    private func changeFormEnabledStatus(){
        briefDescriptionTextField.isUserInteractionEnabled = !briefDescriptionTextField.isUserInteractionEnabled
        locationTextField.isUserInteractionEnabled = !locationTextField.isUserInteractionEnabled
        timeControlStepper.isHidden = !timeControlStepper.isHidden
        gameTimeTextLabel.isHidden = !gameTimeTextLabel.isHidden
        backButton.isHidden = !backButton.isHidden
    }
    
    private func updatePackDetailDict(){
        // Initialises pack data variables
        
        let packDescrip = briefDescriptionTextField.text!
        let packLocation = locationTextField.text!
        let gameTime = String(Int(timeControlStepper.value))
        
        
        packDetails["Description"] = packDescrip
        packDetails["Location"] = packLocation
        packDetails["TimeLimit"] = gameTime
    }
    
    // Updates the game time label with the current value of the stepper
    @IBAction func timeStepperAction(_ sender: Any) {
        gameTimeTextLabel.text = "Game Time: \(Int(timeControlStepper.value)) mins"
    }

    // Allows the pack details to be edited
    @IBAction func editDetailButtonTapped(_ sender: Any) {
        changeFormEnabledStatus()
        if editDetailButton.title(for: UIControlState()) == "Edit Details"{
            gameTimeStaticLabel.text = ""
            editDetailButton.setTitle("Done", for: UIControlState())
        } else{
            gameTimeStaticLabel.text = gameTimeTextLabel.text
            editDetailButton.setTitle("Edit Details", for: UIControlState())
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        updatePackDetailDict()
        if let destNavCon = presentingViewController as? UINavigationController{
            if let targetController = destNavCon.topViewController as? PinPackEditorViewController{
                for key in Array(packDetails.keys){
                    targetController.packData[key] = packDetails[key]! as AnyObject?
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
