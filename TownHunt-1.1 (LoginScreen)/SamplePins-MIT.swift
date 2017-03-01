//
//  SamplePins-MIT.swift
//  TownHunt
//
//  Created by iD Student on 7/28/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import Foundation
import MapKit

let chapel = PinLocation(title: "MIT Chapel", hint: "What was the first year I could go into this church?", codeword: "1955", coordinate: CLLocationCoordinate2D(latitude: 42.358295, longitude: -71.093996), pointVal: 50)
let farMasHall = PinLocation(title: "Fariborz Maseeh Hall", hint: "How many ornamental lights are there in front of the hall?", codeword: "16", coordinate: CLLocationCoordinate2D(latitude: 42.357860, longitude: -71.093513), pointVal: 50)
let kresAuditorium = PinLocation(title: "Kresege Auditorium", hint: "Who donated the lovely organ to the auditorium?", codeword: "Alvan T Fuller", coordinate: CLLocationCoordinate2D(latitude: 42.358153, longitude: -71.094811), pointVal: 75)
let zCenter1 = PinLocation(title: "Zeisiger Sports & Fitness Center", hint: "If you wanted to find out more about a painting what number should you press?", codeword: "642", coordinate: CLLocationCoordinate2D(latitude:  42.358465, longitude: -71.095961), pointVal: 75)
let zCenter2 = PinLocation(title: "Zeisiger Sports & Fitness Center", hint: "Who won the lifetime fitness award in 2009?", codeword: "Wesley Harris", coordinate: CLLocationCoordinate2D(latitude: 42.358586, longitude: -71.095632), pointVal: 75)
let nextHouse = PinLocation(title: "Next House", hint: "What is the house number?", codeword: "500", coordinate: CLLocationCoordinate2D(latitude: 42.354706, longitude: -71.101834), pointVal: 50)
let latCultCen = PinLocation(title: "Latino Cultural Center", hint: "Whose quote is on the Latino Cultural Centre?", codeword: "José Santos Chocano", coordinate: CLLocationCoordinate2D(latitude: 42.358812, longitude: -71.094802), pointVal: 50)
let weisArtGal = PinLocation(title: "Wiesner Art Gallery", hint: "What is the code on the WiFi router?", codeword: "w20-200cd-ap-1", coordinate: CLLocationCoordinate2D(latitude: 42.358878, longitude: -71.095031), pointVal: 100)

var packPins: [PinLocation] = [chapel, weisArtGal, kresAuditorium, zCenter1, farMasHall, zCenter2, nextHouse, latCultCen]