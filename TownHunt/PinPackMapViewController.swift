//
//  PinPackMapViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 07/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//
import MapKit
import CoreData
import Foundation

class PinPackMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Returns an array of Pin Location objects
    func getListOfPinLocations(packData: [String: Any]) -> [PinLocation] {
        let packDetailPinList = packData["Pins"] as! [[String:String]]
        var gamePins: [PinLocation] = []
        if packDetailPinList.isEmpty {
            print(packDetailPinList)
            print("No Pins in pack")
        } else{
            print("There are pins in the loaded pack")
            for pin in packDetailPinList{
                let pinToAdd = PinLocation(title: pin["Title"]!, hint: pin["Hint"]!, codeword: pin["Codeword"]!, coordinate: CLLocationCoordinate2D(latitude: Double(pin["CoordLatitude"]!)!, longitude: Double(pin["CoordLongitude"]!)!), pointVal: Int(pin["PointValue"]!)!)
                gamePins.append(pinToAdd)
            }
        }
        return gamePins
    }
    
    // Returns all of the pack data loaded from local storage
    func loadPackFromFile(filename: String, userPackDictName: String, selectedPackKey: String, userID: String) -> [String : AnyObject]{
        var packData: [String : AnyObject] = [:]
        let defaults = UserDefaults.standard
        let localStorageHandler = LocalStorageHandler(fileName: filename, subDirectory: "UserID-\(userID)-Packs", directory: .documentDirectory)
        let retrievedJSON = localStorageHandler.retrieveJSONData()
        packData = retrievedJSON as! [String : AnyObject]
        return packData
    }
}
