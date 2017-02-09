//
//  OptionsViewController.swift
//  Impulse
//
//  Created by Lukas Romsicki on 2016-05-28.
//  Copyright © 2016 Lukas Romsicki. All rights reserved.
//

import UIKit
import SpriteKit

class OptionsViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func returnToOptions(_ segue:UIStoryboardSegue) {}
    
    @IBOutlet weak var directionPicker: UISegmentedControl!
    @IBOutlet weak var difficultyPicker: UISegmentedControl!
    @IBOutlet weak var popSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popSwitch.setOn(global.popEnabled, animated: false)
        directionPicker.selectedSegmentIndex = global.pipeDirection
        difficultyPicker.selectedSegmentIndex = global.difficulty
    }
    
    @IBAction func directionSegmentToggled(_ sender: AnyObject) {
        if directionPicker.selectedSegmentIndex == 0 {
            global.pipeDirection = 0
            userDefaults.set(global.pipeDirection, forKey:"pipeDirection")
        } else {
            global.pipeDirection = 1
            userDefaults.set(global.pipeDirection, forKey:"pipeDirection")
        }
        userDefaults.synchronize()
    }
    
    @IBAction func difficultySegmentToggled(_ sender: AnyObject) {
        if difficultyPicker.selectedSegmentIndex == 0 {
            global.difficulty = 0
            userDefaults.set(global.difficulty, forKey:"difficulty")
        } else if difficultyPicker.selectedSegmentIndex == 1 {
            global.difficulty = 1
            userDefaults.set(global.difficulty, forKey:"difficulty")
        } else {
            global.difficulty = 2
            userDefaults.set(global.difficulty, forKey:"difficulty")
        }
        userDefaults.synchronize()
    }
    
    @IBAction func popSwitchToggled(_ sender: UISwitch) {
        if popSwitch.isOn {
            global.popEnabled = true
            userDefaults.set(global.popEnabled, forKey:"isPopEnabled")
        } else {
            global.popEnabled = false
            userDefaults.set(global.popEnabled, forKey:"isPopEnabled")
        }
        userDefaults.synchronize()
    }
}
