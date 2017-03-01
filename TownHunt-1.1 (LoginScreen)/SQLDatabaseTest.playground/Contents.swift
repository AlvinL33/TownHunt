//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
/*
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

let username = "Test2"
let userEmail = "Test@gmail.com"
let userPassword = "1234"

let reponseJSON = postToDatabase(apiName: "registerUser.php", postData: "username=\(username)&userEmail=\(userEmail)&userPassword=\(userPassword)"){ (dbResponse: NSDictionary) in

    if dbResponse["error"]! as! Bool{
        print("Trye")
        print(dbResponse["message"]!)
    }
}

//If there is an error, the error is presented to the user
//if reponseJSON["error"] == "1"{
//    print("error: \(reponseJSON["error"])")
//}

let userEmail = "Test@gmail.com"
let userPassword = "1234"

let responseJSON = postToDatabase(apiName: "loginUser.php", postData: "userEmail=\(userEmail)&userPassword=\(userPassword)"){ (dbResponse: NSDictionary) in
    
    //If there is an error, the error is presented to the user
    
    var alertTitle = "ERROR"
    var alertMessage = "JSON File Invalid"
    var isAccountFound = false
    
    print(dbResponse)
    
    if dbResponse["error"]! as! Bool{
        print("error: \(dbResponse["error"]!)")
        alertTitle = "ERROR"
        alertMessage = dbResponse["message"]! as! String
    }
    else if !(dbResponse["error"]! as! Bool){
        alertTitle = "Thank You"
        alertMessage = "Successfully Logged In"
        isAccountFound = true
        
        let accountDetails = dbResponse["accountInfo"]! as! NSDictionary
        print(accountDetails["Email"] as! String)
    }
    else{
        alertTitle = "ERROR"
        alertMessage = "JSON File Invalid"
    }}
/**/*/

var x = [String]()
x.append("ded")
if x.isEmpty{
    print("x is empty")
} else{
    print("x is not empyy")
}
