//
//  ViewController.swift
//  TownHunt
//
//  Created by iD Student on 7/27/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit
import MapKit
import CoreData

var timer = Timer()

protocol MainGameModalDelegate {
    func packSelectedHandler(selectedPackKey: String, packCreatorID: String, gameType: String)
}

class MainGameScreenViewController: PinPackMapViewController, MKMapViewDelegate, MainGameModalDelegate {
    
    @IBOutlet weak var viewBelowNav: UIView!
    @IBOutlet weak var endGameButtonLabel: UIBarButtonItem!
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
    @IBOutlet weak var pointsButtonLabel: BorderedButton!
    @IBOutlet weak var startButtonLabel: UIButton!
    @IBOutlet weak var timerButton: BorderedButton!
    @IBOutlet weak var pointsButton: BorderedButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectMapPackButton: BorderedButton!
    @IBOutlet weak var packSelectedButton: UIButton!
    @IBOutlet weak var gameTypeButton: UIButton!
    
    public var selectedPackKey = ""
    public var userPackDictName = ""
    public var packCreatorID = ""
    private var playerUserID = UserDefaults.standard.string(forKey: "UserID")!
    public var gameType = "competitive"
    public var filename = ""
    private var packData: [String:Any] = [:]
    
    private var isPackLoaded = false
    private var countDownTime = 0
    private var points = 0
    private var isGameOn = false
    private var showEndScreen = false
    private var timeToNextNewPin = 0
    private var activePins: [PinLocation] = []
    private var gamePins: [PinLocation] = []
    
    override func viewDidLoad() {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Setting up the map view
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.hybrid
        mapView.delegate = self
        timeToNextNewPin = randomTimeGen(countDownTime/4)
        
        super.viewDidLoad()
        
        checkFirstLaunch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        if(!isUserLoggedIn){
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
    }
    
    // Checks if user has launched the app before, if not calls the initial file setup
    private func checkFirstLaunch(){
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
            print("App already launched")
            //FirstLoadSetup().setupFiles()
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            FirstLoadSetup().initialSetup()
        }
    }
    
    // [------------------MAP & PIN MECHANICS------------------------------------------------------]
    
    // Controls the Zoom button which zooms into the user
    @IBAction func zoomOnUser(_ sender: AnyObject) {
        let userLocation = mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 200, 200)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func changeMapButton(_ sender: AnyObject) {
        if mapView.mapType == MKMapType.hybrid{
            mapView.mapType = MKMapType.standard
            viewBelowNav.backgroundColor = UIColor.brown.withAlphaComponent(0.8)
        } else{
            mapView.mapType = MKMapType.hybrid
            viewBelowNav.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        }
    }
    
    //Controls the functionality of the pop up
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let pinLocation = view.annotation as! PinLocation
        let pinTitle = "\(pinLocation.title!) : (\(pinLocation.pointVal) Points)"
        let pinHint = pinLocation.hint
        let alertCon = UIAlertController(title: pinTitle, message: pinHint, preferredStyle: .alert)
        // Adds a text field and checks for points
        alertCon.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "Enter code:"})
        alertCon.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
            let textField = alertCon.textFields![0] as UITextField
            if (textField.text?.lowercased() == pinLocation.codeword.lowercased() && pinLocation.isFound == false && self.isGameOn == true){
                self.points += pinLocation.pointVal
                self.updatePoints()
                pinLocation.isFound = true
                let currentPinIndex = self.activePins.index(of: pinLocation)
                self.activePins.remove(at: currentPinIndex!)
                mapView.removeAnnotation(pinLocation)
                self.alertCorrectIncor(true, pointVal: pinLocation.pointVal)
            }
            else{
                self.alertCorrectIncor(false, pointVal: pinLocation.pointVal)
            }
        }))
        present(alertCon, animated: true, completion: nil)
        
    }
    
    // Funcation creates the callout button on the sides of annotation and reuses views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "PinLocation"
        if annotation is PinLocation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            //If no free views exist then a new view is created
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                let btn = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            }
            else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        return nil
    }
    // [------------------------------------ PACK SELECTOR MECHANICS----------------------------------------------------]
    
    @IBAction func selectMapPackButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"packSelector") as! MainGamePackSelectorViewController
        viewController.delegate = self
        self.present(viewController, animated: true)
    }
    
    func packSelectedHandler(selectedPackKey: String, packCreatorID: String, gameType: String){
        self.selectedPackKey = selectedPackKey
        self.packCreatorID = packCreatorID
        self.gameType = gameType
        if !(self.selectedPackKey.isEmpty || self.packCreatorID.isEmpty || self.gameType.isEmpty){
            userPackDictName = "UserID-\(packCreatorID)-LocalPacks"
            let defaults = UserDefaults.standard
            if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName){
                filename = dictOfPacksOnPhone[selectedPackKey] as! String
                packData = loadPackFromFile(filename: filename, userPackDictName: userPackDictName, selectedPackKey: selectedPackKey, userID: packCreatorID)
                gamePins =  getListOfPinLocations(packData: packData)
                isPackLoaded = true
                packSelectedButton.isHidden = false
                packSelectedButton.setTitle("Pack Selected: \(selectedPackKey)", for: UIControlState())
                gameTypeButton.isHidden = false
                gameTypeButton.setTitle("Game Type: \(gameType.uppercased())", for: UIControlState())
            } else{
                displayAlertMessage(alertTitle: "Error", alertMessage: "Data Couldn't be loaded")
            }
        } else{
            displayAlertMessage(alertTitle: "Error", alertMessage: "Selected pack data not passed")
        }
        
    }
    
    // [------------------------------- GAME MECHANICS ------------------------------------]
    
    // Resets the game to the default game settings
    func resetGame(){
        
        selectMapPackButton.isHidden = false
        menuOpenNavBarButton.accessibilityElementsHidden = false
        countDownTime = Int(packData["TimeLimit"] as! String)! * 60
        points = 0
        isGameOn = false
        timeToNextNewPin = 0
        showEndScreen = false
        activePins = []
        gamePins = getListOfPinLocations(packData: packData)
        pointsButtonLabel.setTitle("Points: 0", for: UIControlState())
        menuOpenNavBarButton.isEnabled = true
        packSelectedButton.isHidden = false
        gameTypeButton.isHidden = false
    }
    
    //When the button is pressed the timer is started the the game begins
    @IBAction func startButton(_ sender: AnyObject) {
        if isGameOn == false{
            if isPackLoaded == false {
                displayAlertMessage(alertTitle: "No Pin Pack Selected", alertMessage: "Tap 'Select Pin Pack' to chose a pack")
            }else if gamePins.count < 4{
                displayAlertMessage(alertTitle: "Too Few Pins", alertMessage: "The selected pack has too few pins please add more")
            }
            else{
                resetGame()
                packSelectedButton.isHidden = true
                gameTypeButton.isHidden = true
                selectMapPackButton.isHidden = true
                menuOpenNavBarButton.isEnabled = false
                endGameButtonLabel.isEnabled = true
                isGameOn = true
                
                if playerUserID == packCreatorID{
                    displayAlertMessage(alertTitle: "You Made This Pack!", alertMessage: "Since you created this pack, your score will not be uploaded to the leaderboard")
                }
                
                if gameType == "competitive"{
                    for _ in 0...3{
                        addRandomPinToActivePinList()
                    }
                    mapView.addAnnotations(activePins)
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainGameScreenViewController.updateTime), userInfo: nil, repeats: true)
                    updateTime(timer)
                } else{
                    activePins = gamePins
                    mapView.addAnnotations(activePins)
                    startButtonLabel.setTitle("Casual Mode", for: UIControlState())
                    displayAlertMessage(alertTitle: "Casual Mode Game", alertMessage: "There is no time limit so take your time to explore and hunt for the pins! Once you have finished tap 'End Game'")
                }
            }
        }
    }

    //Updates points the user has scored
    func updatePoints(){
        pointsButtonLabel.setTitle("Points: \(points)", for: UIControlState())
    }
    
    //This function updates the timer
    func updateTime(_ timer: Timer){
        print("GP: \(gamePins.count)")
        print("AP: \(activePins.count)")
        if(countDownTime > 0 && isGameOn == true){
            let minutes = String(countDownTime / 60)
            let seconds = countDownTime % 60
            var disSecs = ""
            if seconds < 10{
                disSecs = "0" + String(seconds)
            } else{
                disSecs = String(seconds)
            }
            startButtonLabel.setTitle(minutes + ":" + disSecs, for: UIControlState())
            countDownTime -= 1
            if timeToNextNewPin > 0{
                timeToNextNewPin -= 1
            } else if (timeToNextNewPin == 0 && gamePins.isEmpty == false){
                addRandomPinToActivePinList()
                timeToNextNewPin = randomTimeGen(countDownTime/2)
            }
        }
        else{
            endGame()
        }
    }
    
    //Creates the alert telling the user if the codework entered is correct or incorrect
    func alertCorrectIncor(_ isCorrect: Bool, pointVal: Int){
        var alertTitle: String = ""
        var alertMessage: String = ""
        if isCorrect == true{
            alertTitle = "Well Done!"
            alertMessage = "\(pointVal) Points Added"
            Sound().playSound("CorrectSound")
        }else{
            alertTitle = "Incorrect!"
            alertMessage = "Try Again!"
            Sound().playSound("Wrong-answer-sound-effect")
        }
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Generates a random number between 0 and maxNum
    func randomTimeGen(_ maxNum: Int) -> Int{
        return Int(arc4random_uniform(UInt32(maxNum)))
    }
    
    // Adds a pin from the gamePin array to the map screen
    func addRandomPinToActivePinList(){
        Sound().playSound("Message-alert-tone")
        let newPinIndex = randomTimeGen(gamePins.count)
        self.mapView.addAnnotation(gamePins[newPinIndex])
        activePins.append(gamePins[newPinIndex])
        gamePins.remove(at: newPinIndex)
    }
    
    @IBAction func endGameButton(_ sender: AnyObject) {
        let alert = UIAlertController(title: "End the Game", message: "Do you really want to end the game ", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {(action) -> Void in
            self.endGame()
        })
        alert.addAction(yesAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func endScreen(){
        if showEndScreen == false{
            let alert = UIAlertController(title: "GAME OVER!", message: "You Scored \(points).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            showEndScreen = true
        }
    }
    
    func endGame(){
        Sound().playSound("Game-over-yeah")
        timer.invalidate()
        startButtonLabel.setTitle("Start", for: UIControlState())
        isGameOn = false
        if playerUserID != packCreatorID{
            addRecordToDB(score: String(points))
        }
        self.mapView.removeAnnotations(activePins)
        endScreen()
        resetGame()
        pointsButtonLabel.setTitle("Pack Details", for: UIControlState())
        endGameButtonLabel.isEnabled = false
    }
    
    func addRecordToDB(score: String){
        
        let packID = packData["PackID"] as! String
        
        let postData = "PackID=\(packID)&PlayerUserID=\(playerUserID)&Score=\(score)&GameType=\(gameType)"
        
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            let responseJSON = dbInteraction.postToDatabase(apiName: "addPlayedPackRecord.php", postData: postData){ (dbResponse: NSDictionary) in
                
                let isError = dbResponse["error"]! as! Bool
                let dbMessage = dbResponse["message"]! as! String
                print(dbResponse)
                
                // Displays a message to the user indicating the sucessfull/unsucessfull creation of a new pack
                DispatchQueue.main.async(execute: {
                    if isError{
                        self.displayAlertMessage(alertTitle: "Error", alertMessage: dbMessage)
                    } else{
                        print("Score Record added to database")
                    }
                    
                })
            }
        } else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the function until internet connectivity is restored
                self.addRecordToDB(score: score)
            }))
            self.present(alertCon, animated: true, completion: nil)
        }
    }
    
    // [----------------------------System Mechanics-----------------------------------------]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let segueIdentifier = identifier {
            if segueIdentifier == "MainGameScreenToPackDetail" {
                if isPackLoaded == false {
                    displayAlertMessage(alertTitle: "No Pack is Loaded", alertMessage: "Tap 'Select Pin Pack' to chose a pack")
                    return false
                } else if isGameOn {
                    return false
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainGameScreenToPackDetail" {
            if let nextVC = segue.destination as? PackDetailsViewController{
                var packDetails = packData
                packDetails.removeValue(forKey: "Pins")
                nextVC.packDetails = packDetails as! [String : String]
                nextVC.isPackDetailsEditable = false
            }
        }
    }
}
