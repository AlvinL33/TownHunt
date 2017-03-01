//
//  DatabaseInteraction.swift
//  TownHunt
//
//  Created by Alvin Lee on 15/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class DatabaseInteraction: NSObject {
    
    let mainSQLServerURLStem = "http://alvinlee.london/TownHunt/api"
    
    func postToDatabase(apiName :String, postData: String, completion: @escaping (NSDictionary)->Void){
        let apiURL = URL(string: mainSQLServerURLStem + "/" + apiName + "/")
        var request = URLRequest(url: apiURL!)
        request.httpMethod = "POST"
        print(postData)
        request.httpBody = postData.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            //Let's convert response sent from a server side script to a NSDictionary object:
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                completion(json!)
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }

}
