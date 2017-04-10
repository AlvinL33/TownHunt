//
//  AddNewMapPacksViewController.swift
//  TownHunt
//
//  Created by iD Student on 7/29/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class PinPackEditorViewController: PinPackMapViewController, MKMapViewDelegate{
    @IBOutlet weak var viewBelowNav: UIView!
    @IBOutlet weak var addPinDetailView: UIView!
    @IBOutlet weak var pinPointValTextField: UITextField!
    @IBOutlet weak var pinCodewordTextField: UITextField!
    @IBOutlet weak var pinHintTextField: UITextField!
    @IBOutlet weak var pinTitleTextField: UITextField!
    
    @IBOutlet weak var packUnplayableWarningButton: UIButton!
    @IBOutlet weak var totalPinsButtonLabel: BorderedButton!
    @IBOutlet weak var maxPointsButtonLabel: BorderedButton!
    @IBOutlet weak var mapView: MKMapView!

    var selectedPackKey = ""
    var userPackDictName = ""
    var userID = ""
    var filename = ""
    
    public var packData = [:] as [String: Any]
    public var gamePins: [PinLocation] = []
    private var newPLat = 0.0
    private var newPLong = 0.0
    private var isNewPinOnMap = false
    private var newPinCoords = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    private let newPin = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInitialPackData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PinPackEditorViewController.refreshAnnotations(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        
        let longPressRecog = UILongPressGestureRecognizer(target: self, action: #selector(MKMapView.addAnnotation(_:)))
        longPressRecog.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecog)
        
        updatePackLabels()
        
        // Setting up the map view
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.hybrid
        mapView.addAnnotations(gamePins)

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

    }
    
    @IBAction func zoomButton(_ sender: AnyObject) {
        let userLocation = mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 200, 200)
        mapView.setRegion(region, animated: true)
        print(packData)
    }

    @IBAction func packDetailButtonTapped(_ sender: Any) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatePackLabels(){
        totalPinsButtonLabel.setTitle("Total Pins: \(gamePins.count)", for: UIControlState())
        if gamePins.count >= 5{
            packUnplayableWarningButton.isHidden = true
        } else{
            packUnplayableWarningButton.isHidden = false
        }
        var maxPoints = 0
        for pin in gamePins{
            maxPoints += pin.pointVal
        }
        maxPointsButtonLabel.setTitle("Max Points: \(maxPoints)", for: UIControlState())
    }
    
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        if isNewPinOnMap == false{
            let touchLocation = gestureRecognizer.location(in: mapView)
            newPinCoords = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            newPin.coordinate = newPinCoords
            mapView.addAnnotation(newPin)
            isNewPinOnMap = true
        }
    }
    
    func loadInitialPackData(){
        let defaults = UserDefaults.standard
        if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName){
            filename = dictOfPacksOnPhone[selectedPackKey] as! String
        } else{
            displayAlertMessage(alertTitle: "Error", alertMessage: "File Couldn't be loaded")
        }
        packData = loadPackFromFile(filename: filename, userPackDictName: userPackDictName, selectedPackKey: selectedPackKey, userID: userID)
        gamePins =  getListOfPinLocations(packData: packData)
    }
    
    func refreshAnnotations(_ notification: Notification){
        print(gamePins)
        mapView.addAnnotations(gamePins)
        updatePackLabels()
    }
    
    @IBAction func addPinDetailsButton(_ sender: AnyObject) {
        if isNewPinOnMap == true{
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude:  newPinCoords.latitude + 0.0003, longitude:  newPinCoords.longitude), 100, 100)
            mapView.setRegion(region, animated: true)
            addPinDetailView.isHidden = false
        } else{
            let alert = UIAlertController(title: "No New Pin On The Map", message: "A new pin hasn't been added to the map yet. Long hold on the location you want to place the pin", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelAddPinDetButton(_ sender: AnyObject) {
        addPinDetailView.isHidden = true
        mapView.removeAnnotation(newPin)
        resetTextFieldLabels()
        view.endEditing(true)
        resetTextFieldLabels()
    }
    

    @IBAction func saveAddPinDetButton(_ sender: AnyObject) {
        if let pointNum = Int(pinPointValTextField.text!){
            let pin = PinLocation(title: pinTitleTextField.text!, hint: pinHintTextField.text!, codeword: pinCodewordTextField.text!, coordinate: newPinCoords, pointVal: pointNum)
            mapView.addAnnotation(pin)
            mapView.removeAnnotation(newPin)
            addPinDetailView.isHidden = true
            resetTextFieldLabels()
            gamePins.append(pin)
            updatePackLabels()
            view.endEditing(true)
        } else {
            displayAlertMessage(alertTitle: "Invalid Point Value", alertMessage: "Please enter a number into the point value")
        }
    }

    func resetTextFieldLabels(){
        isNewPinOnMap = false
        pinTitleTextField.text = "Title"
        pinHintTextField.text = "Hint"
        pinCodewordTextField.text = "Codeword"
        pinPointValTextField.text = "Point Value"
    }
    
    // Method which saves the current pack to both local storage and the database
    func savePack(){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            // Prepares the pack data to save
            var jsonToWrite = packData
            var pinsToSave = [[String: String]]()
            // Retrieves a dictionary about the info of each PinLocation Object and appends it to a 'pinToSave' list
            for pin in gamePins{
                pinsToSave.append(pin.getDictOfPinInfo())
            }
            jsonToWrite["Pins"] = pinsToSave
            
            // Stores the pack details (JSON file) to local storage via the LocalStorageHandler class
            let storageHandler = LocalStorageHandler(fileName: filename, subDirectory: "User-\(packData["CreatorID"]!)-Packs", directory: .documentDirectory)
            let localStorageResponse = storageHandler.saveEditedPack(packData: jsonToWrite as [String : Any])
            
            // If there is an error with saving the json file, the user is presented with an alert with details of the error
            if (localStorageResponse["error"] as! Bool){
                displayAlertMessage(alertTitle: "Error", alertMessage: localStorageResponse["message"] as! String)
            } else{
                
                var isAlertDisplayed = false
                
                // The data to send to the database is received and set up for POSTing to the API
                let dataToPost = localStorageResponse["data"] as! [String: Any]
                
                // Converts dictionary into a JSON string
                let convertedDataToPost = "data=\(storageHandler.jsonToString(jsonData: dataToPost))"
                print(convertedDataToPost)
                
                // Intantialises a DatabaseIntereaction and posts the altered pin pack info to the API/Database
                let responseJSON = DatabaseInteraction().postToDatabase(apiName: "updatePinPack.php", postData: convertedDataToPost){ (dbResponse: NSDictionary) in
                    print("This printed")
                    
                    isAlertDisplayed = true
                    print(isAlertDisplayed)
                    
                    var alertTitle = ""
                    var alertMessage = ""
                    
                    // If a database error exists, the  database response is printed otherwise isDBInteractionSucess is set to true
                    if dbResponse["error"]! as! Bool{
                        alertTitle = "Error"
                        alertMessage = dbResponse["message"]! as! String
                        isAlertDisplayed = true
                        print(isAlertDisplayed)
                    }
                    else if !(dbResponse["error"]! as! Bool){
                        alertTitle = "Success"
                        alertMessage = dbResponse["message"]! as! String
                        
                    }
                    // Displays a message to the user indicating the sucessfull/unsucessfull creation of a new pack
                    DispatchQueue.main.async(execute: {
                        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                self.dismiss(animated: true, completion: nil)
                            }))
                        self.present(alertCon, animated: true, completion: nil)
                    })
                }
            }
        }else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the getDBAccountStats function until internet connectivity is restored
                self.savePack()
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let alertCon = UIAlertController(title: "Do you want to save your pack?", message: "Select 'Cancel' to return to the editor", preferredStyle: .actionSheet)
        alertCon.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            self.savePack()
        }))
        alertCon.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PackEditorToListOfPins" {
            let destNavCon = segue.destination as! UINavigationController
            if let targetController = destNavCon.topViewController as? PinListInPackTableViewController{
                targetController.listOfPins = gamePins
                mapView.removeAnnotations(gamePins)
                gamePins = []
            }
        } else if segue.identifier == "PackEditorToPackDetail" {
            if let nextVC = segue.destination as? PackDetailsViewController{
                var packDetails = packData
                packDetails.removeValue(forKey: "Pins")
                nextVC.packDetails = packDetails as! [String : String]
            }
        }
    }
    
}
