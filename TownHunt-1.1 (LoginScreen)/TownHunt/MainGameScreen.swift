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

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var viewBelowNav: UIView!
    @IBOutlet weak var endGameButtonLabel: UIBarButtonItem!
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
    @IBOutlet weak var pointsButtonLabel: BorderedButton!
    @IBOutlet weak var startButtonLabel: UIButton!
    @IBOutlet weak var timerButton: BorderedButton!
    @IBOutlet weak var pointsButton: BorderedButton!
    @IBOutlet weak var mapView: MKMapView!
    
    private var countDownTime = 0
    private var points = 0
    private var isGameOn = false
    private var showEndScreen = false
    private var timeToNextNewPin = 0
    private var activePins: [PinLocation] = []
    private var gamePins: [PinLocation] = []
    private let filePath = NSHomeDirectory() + "/Documents/" + "MITPack.txt"
    
    override func viewDidLoad() {
        
        resetGame()
        
        UIApplication.shared.isIdleTimerDisabled = true

        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Setting up the map view
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.hybrid
        mapView.delegate = self
        timeToNextNewPin = randomTimeGen(countDownTime/4)
        
        super.viewDidLoad()
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
    
    // Controls the Zoom button which zooms into the user
    @IBAction func zoomOnUser(_ sender: AnyObject) {
        let userLocation = mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 200, 200)
        mapView.setRegion(region, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Resets the game to the default game settings
    func resetGame(){
        menuOpenNavBarButton.accessibilityElementsHidden = false
        countDownTime = 600
        points = 0
        isGameOn = false
        timeToNextNewPin = 0
        showEndScreen = false
        activePins = []
        gamePins = []
        pointsButtonLabel.setTitle("Points: 0", for: UIControlState())
        menuOpenNavBarButton.isEnabled = true
        loadPackFromFile()
    }

    //Updates points the user has scored
    func updatePoints(){
        pointsButtonLabel.setTitle("Points: \(points)", for: UIControlState())
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
    
    //When the button is pressed the timer is started the the game begins
    @IBAction func startButton(_ sender: AnyObject) {
        menuOpenNavBarButton.isEnabled = false
        endGameButtonLabel.isEnabled = true
        if gamePins.count < 4{
            let alert = UIAlertController(title: "Too Few Pins", message: "The selected pack has too few pins please add more", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        else if isGameOn == false{
            isGameOn = true
            for _ in 0...3{
                addRandomPinToActivePinList()
            }
            mapView.addAnnotations(activePins)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
            updateTime(timer)
        }
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
        self.mapView.removeAnnotations(activePins)
        endScreen()
        resetGame()
        endGameButtonLabel.isEnabled = false
    }
    
    func loadPackFromFile(){
        var stringFromFile: String
        do{
            stringFromFile = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            let packPinLocArrays = stringFromFile.characters.split(separator: "\n").map(String.init)
            if packPinLocArrays.isEmpty == false{
                for pinArray in packPinLocArrays{
                    let pinDetails = pinArray.characters.split(separator: ",").map(String.init)
                    let pin = PinLocation(title: pinDetails[0], hint: pinDetails[1], codeword: pinDetails[2], coordinate: CLLocationCoordinate2D(latitude: Double(pinDetails[3])!, longitude: Double(pinDetails[4])!),pointVal: Int(pinDetails[5])!)
                    gamePins.append(pin)
                }
            }
        } catch let error as NSError{
            print(error.description)
        }
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
    
    
}/*
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
*/

