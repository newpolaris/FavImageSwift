//
//  AppDelegate.swift
//  HelloTwitter
//
//  Created by newpolaris on 6/25/14.
//  Copyright (c) 2014 newpolaris. All rights reserved.
//

import Cocoa
import SwifterMac

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow


    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: Selector("handleEvent:withReplyEvent:"), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        LSSetDefaultHandlerForURLScheme("swifter" as CFStringRef, NSBundle.mainBundle().bundleIdentifier.bridgeToObjectiveC() as CFStringRef)
        
        let swifter = Swifter(consumerKey: "RErEmzj7ijDkJr60ayE2gjSHT", consumerSecret: "SbS0CHk11oJdALARa7NDik0nty4pXvAxdt7aj0R5y1gNzWaNEx")
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            
            println(error.localizedDescription)
        }
        
        swifter.authorizeWithCallbackURL(NSURL(string: "swifter://success"), success: {
            accessToken, response in
            
            println("Successfully authorized")
            
            swifter.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: true, contributorDetails: false, includeEntities: true, success: {
                statuses in
                
                println(statuses)
                
                },
                failure: failureHandler)
            
            }, failure: failureHandler)

    }
    
    func handleEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        Swifter.handleOpenURL(NSURL(string: event.paramDescriptorForKeyword(AEKeyword(keyDirectObject)).stringValue))
    }


}

