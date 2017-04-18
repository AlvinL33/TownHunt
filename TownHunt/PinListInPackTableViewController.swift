//
//  PinListInPackTableViewController.swift
//  TownHunt
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit

class PinListInPackTableViewController: UITableViewController {
    
    var listOfPins: [PinLocation]! = []
    var filePath = ""
    
    @IBAction func doneButtonNav(_ sender: AnyObject) {
        if let destNavCon = presentingViewController as? UINavigationController{
            if let targetController = destNavCon.topViewController as? PinPackEditorViewController{
                print(listOfPins)
                targetController.gamePins = listOfPins
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        displayAlertMessage(alertTitle: "Help", alertMessage: "Here is a list of all the pins in the pack. Swipe left on a pin and tap delete to remove the pin from the pack. Tap a pin to find out more information about the pin. There is an option to delete the pin here aswell.\n\nOnce you are finished, tap 'Done' to return to the map.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listOfPins = listOfPins.sorted{ ($0.title)! < ($1.title)! }

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
    
    private func deletePin(indexPath: IndexPath){
        listOfPins.remove(at: (indexPath as NSIndexPath).row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPin = listOfPins[indexPath.row]
        let alertCon = UIAlertController(title: selectedPin.title, message: "Hint: \(selectedPin.hint)\n\nAbout: \(selectedPin.codeword)\n\nPoints: \(String(selectedPin.pointVal))", preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
            self.deletePin(indexPath: indexPath)
        }))
        alertCon.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertCon, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deletePin(indexPath: indexPath)
        }
    }
}
