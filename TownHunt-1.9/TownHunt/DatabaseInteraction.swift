//
//  DatabaseInteraction.swift
//  TownHunt
//
//  Created by Alvin Lee on 15/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit
import SystemConfiguration

class DatabaseInteraction: NSObject {
    
    let mainSQLServerURLStem = "http://alvinlee.london/TownHunt/api"
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
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
                let jsonDicationary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                completion(jsonDicationary!)
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }

}
