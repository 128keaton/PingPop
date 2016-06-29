//
//  PopNet.swift
//  PingPop
//
//  Created by Keaton Burleson on 6/21/16.
//  Copyright © 2016 Keaton Burleson. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import MBProgressHUD
class PopNet : NSObject {
    
    
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ColorServiceType = "popnet"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    var delegate : PopNetMessageDelegate?
    private var serviceBrowser : MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    
 

    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    func cancel(){
        MBProgressHUD.hideAllHUDsForView((self.delegate as! ViewController).view, animated: true)
    }
    func streamMedia(data: NSData){
        print("Streaming Media")
        if session.connectedPeers.count > 0 {
            for peer in session.connectedPeers{
                
                
                try! session.sendData(data, toPeers: [peer], withMode: MCSessionSendDataMode.Reliable)
                
                NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(PopNet.cancel), userInfo: nil, repeats: false)
            }
        }
    }
    
}


extension PopNet : MCNearbyServiceAdvertiserDelegate {
    
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession?) -> Void) {
        print("yo")
        invitationHandler(true, self.session)
    }

    
}
extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "Not Connected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
    
}
protocol PopNetMessageDelegate {
    
    func connectedDevicesChanged(manager : PopNet, connectedDevices: [String])
    func playMedia(manager: PopNet, message: NSData)
    
}

extension PopNet : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("state changed")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("data recieved")
        self.delegate?.playMedia(self, message: data)
        
    }
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("there is a stream, with fish in it!")
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("we just got a resource, we just got a resource. I wonder who its from?")
    }
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
        print("oh, its from \(peerID)")
      
    }
    
}



extension PopNet: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("found peer: \(peerID)")
          browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer :( \(peerID)")
    }
    

    
}


