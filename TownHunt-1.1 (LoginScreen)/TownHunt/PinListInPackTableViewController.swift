//
//  PinListInPackTableViewController.swift
//  TownHunt
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit

class PinListInPackTableViewController: UITableViewController {
    
    var listOfPins: [PinLocation]! = []
    var filePath = ""
    
    @IBAction func cancelButtonNav(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonNav(_ sender: AnyObject) {
        clearFile()
        for pin in listOfPins{
            let writeLine = "\(pin.title!),\(pin.hint),\(pin.codeword),\(pin.coordinate.latitude),\(pin.coordinate.longitude),\(pin.pointVal)"
            savePackToFile(writeLine)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listOfPins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> PinCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell", for: indexPath) as! PinCell
       
        let pin = listOfPins[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = pin.title
        cell.hintLabel.text = pin.hint
        cell.codewordLabel.text = "Answer: \(pin.codeword)"
        cell.pointValLabel.text = "(\(String(pin.pointVal)) Points)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            listOfPins.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func clearFile(){
        let text = ""
        do{
            try text.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        }catch{
            print("Unable to clear file")
        }
    }
    
    func savePackToFile(_ content: String) {
        let contentToAppend = content+"\n"
        //Check if file exists
        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            //Append to file
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentToAppend.data(using: String.Encoding.utf8)!)
        } else {
            //Create new file
            do {
                try contentToAppend.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
        }
    }
    
}
