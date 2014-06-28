//
//  AppDelegate.swift
//  HelloTwitter
//
//  Created by newpolaris on 6/25/14.
//  Copyright (c) 2014 newpolaris. All rights reserved.
//

import Cocoa
import Accounts
import SwifterMac

class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow
    @IBOutlet var btnTwitterAccount : NSPopUpButton
    @IBOutlet var osxAccountsController: NSArrayController
    @IBOutlet var lblLoginText : NSTextField

    var swifter : Swifter? = nil
    var osxAccounts: ACAccount[] = []
    
    func saveImage(tweet: Dictionary<String, AnyObject>)
    {
        var names : Array<String> = []
        var urls : Array<String> = []
        
        if let entity = tweet["extended_entities"] as? NSDictionary {
            if let mediatag = entity as? Dictionary<String, AnyObject> {
                if let medias = mediatag["media"] as? NSArray {
                    if let mediaSwift = medias as? Dictionary<String, AnyObject>[]
                    {
                        for i in 0..mediaSwift.count {
                            if let url = mediaSwift[i]["media_url"] as? NSString
                            {
                                urls.append(url + ":large")
                                let nsstring = url as NSString
                                let splits = nsstring.componentsSeparatedByString("/") as Array<String>
                                names.append(splits[splits.endIndex-1])
                            }
                        }
                    }
                }
            }
        }
        
        println(names)
        println(urls)
        
               for i in 0..names.count {
            let string: NSString = urls[i]
            let nsurl = NSURL(string: urls[i])
            let nsdata = NSData(contentsOfURL: nsurl)
            
            /*
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0]
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"filename.png"];
            */
            nsdata.writeToFile(names[i], atomically:true)
        }
    }
    
    func saveImages(tweets: Dictionary<String, AnyObject>[]?)
    {
        if let tweetList = tweets? {
            for i in 0..tweetList.count {
                saveImage(tweetList[i])
            }
        }
    }
    
    @IBAction func btnGetFavorite(btn : NSPopUpButton)
    {
        if swifter? == nil {
            return
        }
        let failureHandler: ((NSError) -> Void) = {
            error in
            
            println(error.localizedDescription)
        }
        if let twitter = swifter? {
            twitter.getFavoritesListWithCount(200, sinceID:nil, maxID:nil,
                success: saveImages,
                failure: failureHandler)
        }
    }
    
    @IBAction func btnTest(btn : NSPopUpButton)
    {
        let failureHandler: ((NSError) -> Void) = {
            error in
            
            println(error.localizedDescription)
        }
        
        swifter?.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: true, contributorDetails: false, includeEntities: true, success: {
            statuses in
            
            println(statuses)
            
            },
            failure: failureHandler)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType) {
            granted, error in
            if granted {
                let twitterAccounts = accountStore.accountsWithAccountType(accountType)
                if let downcastStrings = twitterAccounts as? ACAccount[] {
                    self.osxAccounts = downcastStrings
                }
                self.btnTwitterAccount.addItemWithTitle(self.osxAccounts[0].username)
                
                let twitterAccount = self.osxAccounts[self.btnTwitterAccount.indexOfSelectedItem]
                self.swifter = Swifter(account:twitterAccount)
            }
        }

    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: Selector("handleEvent:withReplyEvent:"), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        LSSetDefaultHandlerForURLScheme("swifter" as CFStringRef, NSBundle.mainBundle().bundleIdentifier.bridgeToObjectiveC() as CFStringRef)
        /*
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
        */
    }
    
    func handleEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        Swifter.handleOpenURL(NSURL(string: event.paramDescriptorForKeyword(AEKeyword(keyDirectObject)).stringValue))
    }


}

