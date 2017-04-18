 //
//  BackTableVC.swift
//  TownHunt
//
//  Created by iD Student on 7/29/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import Foundation

class BackTableVC: UITableViewController{
    
    var tableArray: [String] = ["Main Map", "Pin Pack Creator", "Pin Pack Store", "Account Page"]
    
    override func viewDidLoad() {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableArray[(indexPath as NSIndexPath).row], for: indexPath) as UITableViewCell
        cell.textLabel?.text = tableArray[(indexPath as NSIndexPath).row]
        return cell
    }
}
