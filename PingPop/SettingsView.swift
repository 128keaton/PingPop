//
//  SettingsView.swift
//  PingPop
//
//  Created by Keaton Burleson on 6/22/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
class SettingsView: UITableViewController {
    @IBOutlet var loopSwitch: UISwitch?
    
    override func viewWillAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().objectForKey("loop") != nil{
            loopSwitch?.setOn(NSUserDefaults.standardUserDefaults().boolForKey("loop"), animated: true)
                
            
        }
    }
    @IBAction func killSwitch(){
        do{
          try AVAudioSession.sharedInstance().setActive(false)
        } catch _{
            print("error")
        }
    }
    @IBAction func save(){
        if loopSwitch!.on == true {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "loop")
        }else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "loop")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        
        try!   AVAudioSession.sharedInstance().setActive(false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
