//
//  AddNewMapPacksViewController.swift
//  TownHunt
//
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class AddNewMapPacksViewController: UIViewController {
    @IBOutlet weak var viewBelowNav: UIView!
    @IBOutlet weak var addPinDetailView: UIView!
    @IBOutlet weak var pinPointValTextField: UITextField!
    @IBOutlet weak var pinCodewordTextField: UITextField!
    @IBOutlet weak var pinHintTextField: UITextField!
    @IBOutlet weak var pinTitleTextField: UITextField!
    
    @IBOutlet weak var totalPinsButtonLabel: BorderedButton!
    @IBOutlet weak var maxPointsButtonLabel: BorderedButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!

    var gamePins: [PinLocation] = []
    var newPLat = 0.0
    var newPLong = 0.0
    var isNewPinOnMap = false
    var newPinCoords = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    let newPin = MKPointAnnotation()
    let filePath = NSHomeDirectory() + "/Documents/" + "MITPack.txt"

    
    override func viewDidLoad() {
        
        loadPackFromFile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewMapPacksViewController.refreshAnnotations(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        
        let longPressRecog = UILongPressGestureRecognizer(target: self, action: #selector(MKMapView.addAnnotation(_:)))
        longPressRecog.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecog)
        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        updatePackLabels()
        
        // Setting up the map view
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.hybrid
        mapView.addAnnotations(gamePins)
        print("This view has loaded")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

    }
    
    @IBAction func zoomButton(_ sender: AnyObject) {
        let userLocation = mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 200, 200)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func totalPinsButton(_ sender: AnyObject) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatePackLabels(){
        totalPinsButtonLabel.setTitle("Total Pins: \(gamePins.count)", for: UIControlState())
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
    
    func refreshAnnotations(_ notification: Notification){
        loadPackFromFile()
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
        //let newPinDetails = PinLocation(title: pinTitleTextField.text!, hint: pinHintTextField.text!, codeword: pinCodewordTextField.text!, coordinate: newPinCoords, pointVal: Int(pinPointValTextField.text!)!)
        let writeLine = "\(pinTitleTextField.text!),\(pinHintTextField.text!),\(pinCodewordTextField.text!),\(newPinCoords.latitude),\(newPinCoords.longitude),\(pinPointValTextField.text!)"
        let pin = PinLocation(title: pinTitleTextField.text!, hint: pinHintTextField.text!, codeword: pinCodewordTextField.text!, coordinate: newPinCoords, pointVal: Int(pinPointValTextField.text!)!)
        mapView.addAnnotation(pin)
        mapView.removeAnnotation(newPin)
        writeToFile(writeLine)
        addPinDetailView.isHidden = true
        resetTextFieldLabels()
        gamePins.append(pin)
        updatePackLabels()
        view.endEditing(true)
    }

    func resetTextFieldLabels(){
        isNewPinOnMap = false
        pinTitleTextField.text = "Title"
        pinHintTextField.text = "Hint"
        pinCodewordTextField.text = "Codeword"
        pinPointValTextField.text = "Point Value"
    }
    
    func writeToFile(_ content: String) {
        let contentToAppend = content+"\n"
        //Check if file exists
        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            //Append to file
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentToAppend.data(using: String.Encoding.utf8)!)
        } else {
            //Create new file
            do {
                try contentToAppend.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
        }
    }
    
    //Loads all of the pins from a pack into the map
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PinInPackListSegue" {
            let destNavCon = segue.destination as! UINavigationController
            if let targetController = destNavCon.topViewController as? PinListInPackTableViewController{
                targetController.listOfPins = gamePins
                targetController.filePath = filePath
                mapView.removeAnnotations(gamePins)
                gamePins = []
            } else {
                print("Data NOT Passed! destination vc is not set to correct view")
            }
        } else { print("Id doesnt match with Storyboard segue Id") }
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
}
/*    @IBAction func write(sender: AnyObject) {
 let writeString = "Hello, world!"
 let filePath = NSHomeDirectory() + "/Documents/test.txt"
 do { _ = try writeString.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
 } catch let error as NSError {
 print(error.description)
 }
 }
 
 @IBAction func read(sender: AnyObject) {
 var readString: String
 let filePath = NSHomeDirectory() + "/Documents/test.txt"
 do {
 readString = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
 print(readString)
 } catch let error as NSError {
 print(error.description)
 }
 }
 */
