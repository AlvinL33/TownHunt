//
//  firstLoadSetup.swift
//  TownHunt
//
//  Created by Alvin Lee on 26/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class FirstLoadSetup {
    func initialSetup(){
        
        // Initialises a dictionary (hash table) to store a list of hashable names of the packs and the path to the JSON file
        UserDefaults.standard.setValue([String](), forKey:"listOfLocalUserIDs")

        UserDefaults.standard.set(false, forKey: "isInitialSetupRequired")
        
//        let packHashTable = TownHuntHashTable<String, String>(capacity: 53)
//        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: packHashTable)
//        UserDefaults.standard.set(encodedData, forKey: "packHashTable")
        
        UserDefaults.standard.synchronize()

    }
}
