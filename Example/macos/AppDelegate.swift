//
//  AppDelegate.swift
//  macos
//
//  Created by Ryan Fung on 12/27/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Cocoa
import Birch

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Birch.initialize("api_key")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

