//
//  LeaderboardViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 09/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var selectedPackKey = ""
    public var packCreatorID = ""
    private var packID = ""
    private var userID = ""
    private var leaderboardData = [String: Any]()
    private var leaderboardRecords = [[String:String]]()
    
    @IBOutlet var leaderboardTable: UITableView!
    @IBOutlet weak var packLeaderboardHeaderLabel: UIButton!
    @IBOutlet weak var userPositionLabel: UILabel!
    @IBOutlet weak var userPointsScoreLabel: UILabel!
    @IBOutlet weak var averagePointsScoredLabel: UILabel!
    @IBOutlet weak var numberOfPlayersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaderboardTable.delegate = self
        leaderboardTable.dataSource = self
        //self.leaderboardTable.register(LeaderboardRecordTableViewCell.self, forCellReuseIdentifier: "leaderboardRecordCell")
        
        getUserID()
        getPackID()
        getLeaderboardData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getUserID(){
        userID = UserDefaults.standard.string(forKey: "UserID")!
    }
    
    // Retrieves the pack id of the selected pack
    private func getPackID(){
        // Checks that the selectedPackKey and packCreatorID is not empty otherwise an error message is displayed
        if !(self.selectedPackKey.isEmpty || self.packCreatorID.isEmpty){
            let userPackDictName = "UserID-\(packCreatorID)-LocalPacks"
            let defaults = UserDefaults.standard
            if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName){
                // Opens file and retrieves the pack data and hence the pack id
                let filename = dictOfPacksOnPhone[selectedPackKey] as! String
                let packData = PinPackMapViewController().loadPackFromFile(filename: filename, userPackDictName: userPackDictName, selectedPackKey: selectedPackKey, userID: packCreatorID)
                packID =  packData["PackID"] as! String
            } else{
                displayAlertMessage(alertTitle: "Error", alertMessage: "Data Couldn't be loaded")
            }
        } else{
            displayAlertMessage(alertTitle: "Error", alertMessage: "Selected pack data not passed")
        }
    }
    
    func setLeaderboardData(data: [String:Any]){
        leaderboardData = data
        leaderboardRecords = leaderboardData["topScoreRecords"] as! [[String : String]]
        
        leaderboardTable.reloadData()
        
        let userRank = data["userRank"]! as! String
        let userScore = data["userScore"]! as! String
        let averageScore = String(describing: data["averageScore"]!)
        let numOfPackPlayers = data["numOfPlayersOfPack"]! as! String
        setNonTableLabels(userRank: userRank, userScore: userScore, averageScore: averageScore, numPlayers: numOfPackPlayers)
    }
    
    private func setNonTableLabels(userRank: String, userScore: String, averageScore: String, numPlayers: String){
        packLeaderboardHeaderLabel.setTitle("\(selectedPackKey): Top 10", for: UIControlState())
        userPositionLabel.text = userRank
        userPointsScoreLabel.text = "\(userScore)pts"
        averagePointsScoredLabel.text = "\(averageScore)pts"
        numberOfPlayersLabel.text = numPlayers
    }
    
    private func getLeaderboardData(){
        // Initialises database interaction object
        let dbInteraction = DatabaseInteraction()
        // Tests for internet connectivity
        if dbInteraction.connectedToNetwork(){
            
            let postData = "packID=\(packID)&userID=\(userID)"
            
            let responseJSON = dbInteraction.postToDatabase(apiName: "getPackLeaderboardInfo.php", postData: postData){ (dbResponse: NSDictionary) in
                
                let isError = dbResponse["error"]! as! Bool
                var errorMessage = ""
                //let lbData = dbResponse as! Dictionary<String, Any>
                
                print(dbResponse)
                
                if !isError{
                    //let userRank = dbResponse["userRank"]! as! String
                    //let userScore = dbResponse["userScore"]! as! String
                    //let averageScore = dbResponse["averageScore"]! as! String
                    //let numOfPackPlayers = dbResponse["numOfPlayersOfPack"]! as! String
                    //self.setNonTableLabels(userRank: userRank, userScore: userScore, averageScore: averageScore, numPlayers: numOfPackPlayers)
                } else{
                    for message in dbResponse["message"] as! [String]{
                        errorMessage = errorMessage + "\n" + message
                    }
                }
                
                // Displays a message to the user indicating the sucessfull/unsucessfull creation of a new pack
                DispatchQueue.main.async(execute: {
                    if isError{
                        self.displayAlertMessage(alertTitle: "Error", alertMessage: errorMessage)
                    } else{
                        self.setLeaderboardData(data: dbResponse as! Dictionary<String, Any>)
                        print("Leaderboard data loaded")
                    }
                    
                })
            }
        } else{ // If no internet connectivity, an error message is diplayed asking the user to connect to the internet
            let alertCon = UIAlertController(title: "Error: Couldn't Connect to Database", message: "No internet connectivity found. Please check your internet connection", preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                // Recursion is used to recall the function until internet connectivity is restored
                self.getLeaderboardData()
            }))
            self.present(alertCon, animated: true, completion: nil)
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardRecordCell", for: indexPath) as! LeaderboardRecordTableViewCell
        
        let record = leaderboardRecords[indexPath.row]
        cell.positionLabel?.text = String(indexPath.row + 1)
        cell.pointsScoreLabel?.text = "\(record["Score"]!)pts"
        cell.playerNameLabel?.text = record["Username"]!
        
        return cell
    }
    
    
    @IBAction func backNavButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayAlertMessage(alertTitle: String, alertMessage: String){
        let alertCon = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    
}

