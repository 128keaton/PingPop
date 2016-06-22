//
//  ChooseFile.swift
//  PingPop
//
//  Created by Keaton Burleson on 6/22/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import UIKit
class ChooseFile: UITableViewController {
    var fileList: [NSURL]? = []
    override func viewDidLoad() {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        do {
            fileList = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
           self.tableView.reloadData()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    @IBAction func exit(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if fileList?.count == 0{
            let message = UILabel.init(frame: self.view.frame)
            message.text = "No audio, use iTunes to add some"
            message.textAlignment = .Center
            self.tableView.backgroundView = message
            self.tableView.separatorStyle = .None
            return 0
        }
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        cell?.textLabel?.text = fileList![indexPath.row].lastPathComponent
        return cell!
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setURL(fileList![indexPath.row], forKey: "music")
        print("saving: \(fileList![indexPath.row])")
        defaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fileList?.count)!
    }
    override func viewDidAppear(animated: Bool) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        do {
            fileList = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            self.tableView.reloadData()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }

    }
}
