//
//  ColorViewController.swift
//  Impulse
//
//  Created by Lukas Romsicki on 2016-06-14.
//  Copyright © 2016 Lukas Romsicki. All rights reserved.
//


import UIKit

class ColorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var colorPicker: UIPickerView!
    
    let userDefaults = UserDefaults.standard
    let pickerData = ["Default Blue", "Warm Red", "Deep Purple", "Forest Green", "Solid Black"]
    var selectedIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.dataSource = self
        colorPicker.delegate = self
        
        if (userDefaults.object(forKey: "globalColorSchemeAsInt")) == nil {
            userDefaults.set(0, forKey:"globalColorSchemeAsInt")
        } else {
            
        }
        
        selectedIndex = userDefaults.object(forKey: "globalColorSchemeAsInt") as! Int
        colorPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        global.colorScheme = pickerData[row]
        selectedIndex = row
        
        userDefaults.set(global.colorScheme, forKey:"globalColorScheme")
        userDefaults.set(selectedIndex, forKey:"globalColorSchemeAsInt")
        userDefaults.synchronize()
        
        GameScene().setBackground()
    }
}
