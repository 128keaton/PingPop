//
//  ViewController.swift
//  PingPop
//
//  Created by Keaton Burleson on 6/21/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class ViewController: UITableViewController, MPMediaPickerControllerDelegate {
    let pingPopManager: PopNet? = PopNet()
    var connectedDevicesList: [String]? = []
    var audioPlayer = AVAudioPlayer()
    @IBOutlet weak var sendButton: UIButton?
    @IBOutlet weak var chooseButton: UIButton?
    @IBOutlet weak var stopButton: UIButton?
    var mediaPicker: MPMediaPickerController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        pingPopManager?.delegate = self
        sendButton?.layer.cornerRadius = 13
        stopButton?.layer.cornerRadius = 13
        chooseButton?.layer.cornerRadius = 13

    }

    @IBAction func killSwitch(){
        do{
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _{
            print("error")
        }
    }
    @IBAction func chooseMusic(){
        self.presentViewController(mediaPicker!, animated: true, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
        self.updateView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

    }
    
    @IBAction func sendMessage(){
        if NSUserDefaults.standardUserDefaults().objectForKey("music") != nil {
            pingPopManager?.sendMessage(NSUserDefaults.standardUserDefaults().URLForKey("music")!)
            print("custom")
        }else{
            pingPopManager?.sendMessage(NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-holdtone", ofType: "aif")!))
            print("not custom")
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (connectedDevicesList?.count)!
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = connectedDevicesList![indexPath.row]
        return cell
    }
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("music")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    func updateView(){
        if NSUserDefaults.standardUserDefaults().objectForKey("music") != nil {
    
            chooseButton?.setTitle(NSUserDefaults.standardUserDefaults().URLForKey("music")?.lastPathComponent, forState: UIControlState.Normal)
            
        }
        print("todo")
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "connections"
    }

}

extension ViewController: PopNetMessageDelegate{
    func connectedDevicesChanged(manager: PopNet, connectedDevices: [String]) {
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in

          self.connectedDevicesList = connectedDevices
            if connectedDevices.count != 0 {
                self.tableView.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
         self.updateView()
        print("changed")
    }
    func playURL(manager: PopNet, message: NSURL) {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        try! audioPlayer = AVAudioPlayer(data: NSData(contentsOfURL: message)!)
        if NSUserDefaults.standardUserDefaults().boolForKey("loop") == true {
            audioPlayer.numberOfLoops = -1
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        
        print("message Received")
    }
    
    func pingPop(manager: PopNet, message: NSData) {
  

        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        try! audioPlayer = AVAudioPlayer(data: message)
        if NSUserDefaults.standardUserDefaults().boolForKey("loop") == true {
            audioPlayer.numberOfLoops = -1
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    
        
        print("message Received")
    }
}

