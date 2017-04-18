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
        
        setBackgroundImage(imageName: "createPackBackground")
        
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
        userPackDictName = "UserID-\(userID)-Packs"
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
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedPickerData = pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 330, height: 30));
        label.lineBreakMode = .byWordWrapping;
        label.numberOfLines = 0;
        label.text = pickerData[row]
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: CGFloat(20))
        label.sizeToFit()
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func modalViewDismissed(){
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.setUpPicker()
        self.packPicker.reloadAllComponents()
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
