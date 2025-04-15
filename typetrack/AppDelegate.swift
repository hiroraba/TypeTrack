//
//  AppDelegate.swift
//  typetrack
//
//  Created by 松尾宏規 on 2025/04/14.
//

import Cocoa
import FirebaseCore

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        FirebaseApp.configure()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
