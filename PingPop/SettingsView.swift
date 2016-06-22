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
    @IBAction func killSwitch(){
     try!   AVAudioSession.sharedInstance().setActive(false)
    }
}