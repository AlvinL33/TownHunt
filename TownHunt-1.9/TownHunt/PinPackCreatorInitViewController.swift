//
//  MapPackCreatorInitViewController.swift
//  TownHunt
//
//  Created by Alvin Lee on 23/02/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class PinPackCreatorInitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ModalTransitionListener {

    @IBOutlet weak var menuOpenNavBarButton: UIBarButtonItem!
    @IBOutlet weak var packPicker: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    
    private var pickerData: [String] = [String]()
    private var userPackDictName = ""
    private var selectedPickerData: String = ""
    private var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ModalTransitionMediator.instance.setListener(listener: self)

        menuOpenNavBarButton.target = self.revealViewController()
        menuOpenNavBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "createPackBackground")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
        self.packPicker.delegate = self
        self.packPicker.dataSource = self
        setUpPicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setUpPicker(){
        let defaults = UserDefaults.standard
        userID = defaults.string(forKey: "UserID")!
        userPackDictName = "UserID-\(userID)-LocalPacks"
        if let dictOfPacksOnPhone = defaults.dictionary(forKey: userPackDictName) {
            self.pickerData = Array(dictOfPacksOnPhone.keys).sorted(by: <)
            self.selectedPickerData = pickerData[0]
        } else {
            self.pickerData = ["No Packs Found"]
            self.selectButton.isHidden = true
        }
    }

    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Numbers of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    // The picker data to return for a certain row and column
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
    
    //
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let textString = self.pickerData[row]
        return NSAttributedString(string: textString, attributes: [NSFontAttributeName:UIFont(name: "Futura"
            , size: 17.0)!, NSForegroundColorAttributeName: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedPickerData = pickerData[row]
    }
    
    func modalViewDismissed(){
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.packPicker.reloadAllComponents()
        self.setUpPicker()
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
    }
    
    // Preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PackSelectorToPackEditor"{
            let navigationController = segue.destination as! UINavigationController
            let nextViewController = navigationController.topViewController as! PinPackEditorViewController
            print("Preparing to leave view, key is \(self.selectedPickerData)")
            nextViewController.selectedPackKey = self.selectedPickerData
            nextViewController.userPackDictName = self.userPackDictName
            nextViewController.userID = self.userID
        }
    }

}
