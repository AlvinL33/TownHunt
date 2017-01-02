//
//  PinLocation.swift
//  TownHunt
//
//  Created by iD Student on 7/27/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class PinLocation: NSObject, MKAnnotation{
    let title: String?
    let hint: String
    let codeword: String
    let coordinate: CLLocationCoordinate2D
    let pointVal: Int
    var isFound = false
    init(title: String, hint:String, codeword: String, coordinate: CLLocationCoordinate2D, pointVal: Int){
        self.title = title
        self.hint = hint
        self.codeword = codeword
        self.coordinate = coordinate
        self.pointVal = pointVal
        super.init()
    }
    var subtitle: String? {
        return String("\(pointVal) Points")
    }
/*
    func getStringArray() {
        let defaults = NSUserDefaults()
        let recreatedMyStupidAssArrayOfStrings = defaults.stringArrayForKey("my stupid ass dumb strings")
    } */
}