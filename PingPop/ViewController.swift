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
import MBProgressHUD
import FXBlurView


class ViewController: UITableViewController, MPMediaPickerControllerDelegate {
    let pingPopManager: PopNet? = PopNet()
    var connectedDevicesList: [String]? = []
    var audioPlayer = AVAudioPlayer()

    @IBOutlet weak var chooseButton: UIButton?
    @IBOutlet weak var stopButton: UIButton?
    var mediaPicker: MPMediaPickerController? = nil
    var isPlaying: Bool? = false
    var blurView: UIVisualEffectView?
    var imageView: UIImageView?
    
    let pauseColor: UIColor? = UIColor(hue: 0.0222, saturation: 1, brightness: 0.96, alpha: 1.0)
    var playColor: UIColor?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton?.enabled = false
        pingPopManager?.delegate = self
        playColor = stopButton?.backgroundColor
        stopButton?.layer.cornerRadius = 13
        chooseButton?.layer.cornerRadius = 13
        mediaPicker = MPMediaPickerController.init(mediaTypes: MPMediaType.AnyAudio)
        mediaPicker?.delegate = self
        stopButton?.backgroundColor = UIColor(hue: 0.1972, saturation: 1, brightness: 0.67, alpha: 1.0)
        mediaPicker?.allowsPickingMultipleItems = false
        stopButton?.alpha = 0
 
        self.navigationItem.title = "Nothing Playing"
        self.navigationItem.prompt = nil

    }
    func makeBlurView(image: UIImage){
        self.view.backgroundColor = UIColor.clearColor()

        if imageView == nil{
            imageView = UIImageView.init(frame: self.view.frame)
           self.view.insertSubview(imageView!, atIndex: 0)
            imageView?.contentMode = .ScaleAspectFill
        }
        if blurView == nil{
            let blurEffect = UIBlurEffect(style: .Dark)
            blurView = UIVisualEffectView.init(effect: blurEffect)
            blurView?.frame = self.view.frame
            self.view.insertSubview(blurView!, aboveSubview: imageView!)
                  }
        
        imageView!.image = image
    }

    @IBAction func killSwitch(){
        
        if isPlaying == false{
            let objectDict : [String:AnyObject] = ["command" : Command.Play.rawValue]
            print("raw value: \(Command.Pause.rawValue)")
            self.pingPopManager?.streamMedia(NSKeyedArchiver.archivedDataWithRootObject(objectDict))
        }else{
            let objectDict : [String:AnyObject] = ["command" : Command.Pause.rawValue]
             print("raw value: \(Command.Pause.rawValue)")
            self.pingPopManager?.streamMedia(NSKeyedArchiver.archivedDataWithRootObject(objectDict))
        }
    

    }
    
    @IBAction func chooseMusic(){
        
        self.presentViewController(mediaPicker!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        
        hud.addGestureRecognizer(UITapGestureRecognizer.init(target: nil, action: #selector(stopHUD)))

        
        let item = mediaItemCollection.items[0]
        let url = item.valueForProperty(MPMediaItemPropertyAssetURL)
        if url != nil{
             if (item.title != nil && item.artist != nil && item.artwork != nil){
            mediaPicker.dismissViewControllerAnimated(true, completion: nil)
            dispatch_async(dispatch_get_main_queue()) {
                self.makeBlurView((item.artwork?.imageWithSize(CGSizeMake(100, 100)))!)
            }
            self.tableView.reloadData()
            self.navigationItem.title = "Playing: " + item.title!
            self.navigationItem.prompt = "Artist: " + item.artist! + " Album: " + item.albumTitle!
            
            sendSong(item)
                
            }else{
                let alert = UIAlertController.init(title: "Error", message: "Missing Song Values", preferredStyle: .Alert)
                let okButton = UIAlertAction.init(title: "Ok", style: .Default, handler: { (action) in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(okButton)
                mediaPicker.presentViewController(alert, animated: true, completion: nil)
            }
            
        }else{
            let alert = UIAlertController.init(title: "Error", message: "Song has DRM", preferredStyle: .Alert)
            let okButton = UIAlertAction.init(title: "Ok", style: .Default, handler: { (action) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(okButton)
            mediaPicker.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func stopHUD(){
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    func sendSong(media: MPMediaItem){
        
        let asset = AVURLAsset.init(URL: media.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL)
        
        let exporter = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        exporter?.outputFileType = AVFileTypeAppleM4A
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!

        let titleMedia = randomStringWithLength(25)
        let exportPathString = String(documentsDir) + (titleMedia as String) + ".m4a"
        UIView.transitionWithView(self.view, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { (action) in
            self.chooseButton?.setBackgroundImage(media.artwork?.imageWithSize(CGSizeMake(100, 100)), forState: .Normal)
            
            self.chooseButton?.setTitle("", forState: .Normal)
            }, completion: nil)
        
      
        print("String path: \(exportPathString)")
        print("Documents path: \(documentsDir)")
        print("Media path: \(titleMedia)")
        let exportPath = NSURL(string: exportPathString)
        print("Export path: \(exportPath!)")
        exporter?.outputURL = exportPath!
        exporter?.exportAsynchronouslyWithCompletionHandler({ (action) in
            if exporter?.status == AVAssetExportSessionStatus.Completed{
                print("Success!")
                 dispatch_async(dispatch_get_main_queue()) {
                    let objectDict : [String:AnyObject] = ["media" : NSData.init(contentsOfURL: exportPath!)!, "artwork" : (media.artwork?.imageWithSize(CGSizeMake(100, 100)))!]
                    
                        self.pingPopManager?.streamMedia(NSKeyedArchiver.archivedDataWithRootObject(objectDict))
                    try! NSFileManager.defaultManager().removeItemAtURL(exportPath!)
                }
            }else{
                try! NSFileManager.defaultManager().removeItemAtURL(exportPath!)
                print("Error: \(exporter!.error)")
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        })

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
}


extension ViewController: PopNetMessageDelegate{
    func connectedDevicesChanged(manager: PopNet, connectedDevices: [String]) {
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in

          self.connectedDevicesList = connectedDevices
            if connectedDevices.count != 0 {
                self.tableView.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
       
        print("changed")
    }
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0..<len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    func playMedia(manager: PopNet, message: NSData) {

        let objectDict:NSDictionary? = NSKeyedUnarchiver.unarchiveObjectWithData(message)! as? NSDictionary
        if objectDict?.objectForKey("media") != nil{
        let mediaData = objectDict?.objectForKey("media") as! NSData
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        try! audioPlayer = AVAudioPlayer(data: mediaData)
        dispatch_async(dispatch_get_main_queue()) {
                   UIView.transitionWithView(self.view, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { (action) in
                      self.chooseButton?.setBackgroundImage(objectDict?.objectForKey("artwork") as? UIImage, forState: .Normal)
                                self.makeBlurView((objectDict!.objectForKey("artwork") as? UIImage)!)
                   }, completion: nil)
    

            self.chooseButton?.setTitle("", forState: .Normal)
            let objectDict : [String:AnyObject] = ["playing" : true]
            self.pingPopManager?.streamMedia(NSKeyedArchiver.archivedDataWithRootObject(objectDict))
          
        }
        if NSUserDefaults.standardUserDefaults().boolForKey("loop") == true {
            audioPlayer.numberOfLoops = -1
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
            
           
            
        }else if objectDict?.objectForKey("command") != nil{
            
            print("command: \(objectDict?.objectForKey("command")!)")
            let command = Command(rawValue: objectDict?.objectForKey("command")! as! Int)!
            switch command{
                case .Pause:
                    
                    
                    audioPlayer.pause()
                    let pauseHud = MBProgressHUD.init(forView: self.view)
                    pauseHud.labelText = "Paused"
                    pauseHud.mode = .Text
                    pauseHud.show(true)
                    let objectDict : [String:AnyObject] = ["playing" : false]
                    self.pingPopManager?.streamMedia(NSKeyedArchiver.archivedDataWithRootObject(objectDict))
                    
                break
                
                case .Play:
                    audioPlayer.play()
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    let objectDict : [String:AnyObject] = ["playing" : true]
                    self.pingPopManager?.streamMedia(NSKeyedArchiver.archivedDataWithRootObject(objectDict))
                break
            }
            
        }else{
             dispatch_async(dispatch_get_main_queue()) {
                self.isPlaying = objectDict?.objectForKey("playing") as? Bool
                        UIView.transitionWithView(self.view, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { (action) in
                            self.stopButton?.alpha = 1.0
                        }, completion: nil)
                self.stopButton?.enabled = true
                if self.isPlaying == true{
                    self.stopButton?.backgroundColor = self.pauseColor
                    self.stopButton?.setTitle("Pause", forState: .Normal)
                }else{
                    self.stopButton?.backgroundColor = self.playColor
                    self.stopButton?.setTitle("Play", forState: .Normal)
                }
            }
        }
        
        print("message Received")
    }
}

enum Command: Int {
    case Pause = 0
    case Play
}
