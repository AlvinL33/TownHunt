//
//  LocalStorageHandler.swift
//  TownHunt
//
//  Created by Alvin Lee on 26/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class LocalStorageHandler {
    
    // Private attributes storing information about the file
    private let directory: FileManager.SearchPathDirectory
    private let directoryPath: String
    private let fileManager = FileManager.default
    private let fileName: String
    private let filePath: String
    private let fullyQualifiedPath: String
    private let subDirectory: String
    private let doesFileExist: Bool
    private var doesDirectoryExist: ObjCBool = false
    private var response = [String:String]()
    
    //Initialise Class attributes
    init(fileName: String, subDirectory: String, directory: FileManager.SearchPathDirectory){
        self.fileName = fileName
        self.subDirectory = "/\(subDirectory)"
        self.directory = directory
        self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0]
        self.filePath = directoryPath + self.subDirectory
        self.fullyQualifiedPath = "\(self.filePath)/\(self.fileName).json"
        self.doesFileExist = self.fileManager.fileExists(atPath: fullyQualifiedPath)
        self.fileManager.fileExists(atPath: filePath, isDirectory: &doesDirectoryExist)
        
        print(fullyQualifiedPath)
        createDirectory()

    }
    
    // Method which creates a directory if directory doesn't exist
    private func createDirectory(){
        if !(doesDirectoryExist.boolValue){
            do{
                try self.fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Method which writes TXT files to a given path
    func saveTextFile(dataToWrite: String) -> Bool {
        if !doesFileExist{
            do{
                try dataToWrite.write(toFile: fullyQualifiedPath, atomically: true, encoding: String.Encoding.utf8)
                print("File Saved")
                return true
            } catch {
                print("File could not be saved")
                return false
            }
        } else {
            print("File already exists")
            return false
        }
    }
    
    // Method which converts JSON objects into JSON strings
    func jsonToString(jsonData: Any) -> String{
        // Checks if jsonData passed is a valid JSON object
        if JSONSerialization.isValidJSONObject(jsonData) {
            do{
                // Serialises JSON object and then converts it to a string
                let data = try JSONSerialization.data(withJSONObject: jsonData)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch {
                print("Couldn't Convert JSON object into string")
            }
        }
        // If the JSON object is not coverted, a null string is returned
        return ""
    }
    
    // Method which saves JSON files to a given path
    func saveJSONFile(dataToWrite: Any) -> Bool {
        var convertedJSONToSave: Data?
        
        // Attempts to convert given dictionary into JSON file
        do{
            convertedJSONToSave = try JSONSerialization.data(withJSONObject: dataToWrite, options: .prettyPrinted)
        } catch{
            print("Couldn't serialise JSON file")
            return false
        }
        
        // Attempts to write JSON File to storage
        if fileManager.createFile(atPath: fullyQualifiedPath, contents: convertedJSONToSave, attributes: nil){
            print("File Saved")
            return true
        }
        else {
            print("File could not be saved")
            return false
        }
    }
    
    // Reading JSON Files
    func retrieveJSONData() -> NSDictionary{
        if doesFileExist{
            do{
                let fileData = try NSData(contentsOfFile: fullyQualifiedPath, options: NSData.ReadingOptions.mappedIfSafe)
                let jsonDicationary = try JSONSerialization.jsonObject(with: fileData as Data, options: .allowFragments) as! NSDictionary
                return jsonDicationary
            } catch{
                self.response["Error"] = "true"
                self.response["Message"] = "Couldn't retreive JSON file contents"
                return self.response as NSDictionary
            }
        }
        else{
            self.response["Error"] = "true"
            self.response["Message"] = "File doesn't exist"
            return self.response as NSDictionary
        }
    }
    
    func addNewPackToPhone(packData: NSDictionary) -> Bool {
        // Saves data as a JSON file in the location specified by 'self.fullyQualifiedPath'
        if saveJSONFile(dataToWrite: packData as NSDictionary){
            let packName = packData["PackName"]! as! String
            let creatorID = packData["CreatorID"]! as! String
            let packLocation = packData["Location"]! as! String
            
            let defaults = UserDefaults.standard
            
            // Checks if listOfLocalUserIDs exists
            if var listOfUserIDs = defaults.array(forKey: "listOfLocalUserIDs") {
                listOfUserIDs = listOfUserIDs as! [String]
                
                // Checks if user ID of the pack is part of the listOfLocalUserIDs array
                if !(listOfUserIDs.contains(where: {$0 as! String == creatorID})) {
                    // If new user ID not found, the new ID is appended to the list
                    listOfUserIDs.append(creatorID)
                    defaults.set(listOfUserIDs, forKey: "listOfLocalUserIDs")
                }
                
                let creatorDictKey = "UserID-\(creatorID)-LocalPacks"
                var creatorLocalPackDict = [String:String]()
                
                // // Checks if specific user ID dictrionary exists. If exists, the dictionary is loaded into the program
                if let dictionary = defaults.dictionary(forKey: creatorDictKey){
                    creatorLocalPackDict = dictionary as! [String : String]
                }
                
                // Pack identifier/display name is appended to the dictionary along with the corresponding filename
                let packKey = "\(packName) - \(packLocation)"
                creatorLocalPackDict[packKey] = self.fileName
                
                defaults.set(creatorLocalPackDict, forKey: creatorDictKey)
                defaults.synchronize()
                return true
            }
            else{
                print("Error loading array of local creator IDs")
                return false
            }
        }
        else{
            print("Error saving JSON file")
            return false
        }
    }
    
    func deleteFile() -> Bool{
        do {
            try fileManager.removeItem(atPath: self.fullyQualifiedPath)
            return true
        } catch {
            print("Could delete file")
            return false
        }
    }

    // Method for saving the edited version of a pack
    func saveEditedPack(packData: [String: Any]) -> [String:AnyObject] {
        var dataToWrite = packData
        let originalPackData = retrieveJSONData()
        
        // Compares the original pack to the one that is passed
        if !(originalPackData.isEqual(to: packData)){
            
            print("Packs Are not the same")
            // If a change has been detected the version number is incremented by one
            let currentVersionNum = Int(packData["Version"]! as! String)!
            dataToWrite["Version"] = String(currentVersionNum + 1)
            
            // The original file is deleted and the new json data is saved
            if deleteFile(){
                if saveJSONFile(dataToWrite: dataToWrite){
                    return ["error": false as AnyObject, "data": dataToWrite as AnyObject]
                } else{ // If the new file fails to save, the old pack data is saved
                    saveJSONFile(dataToWrite: originalPackData)
                }
            }
            print("Couldn't save edited pack")
            return ["error": true as AnyObject, "message": "Couldn't save edited pack" as AnyObject]
        }
        print("Packs are the same")
        return ["error": true as AnyObject, "message": "No changes to the pack were made" as AnyObject]
        
    }
}

