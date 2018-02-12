//
//  AppDelegate.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2017年 nuomi1. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        open(nil)
    }

    @IBAction func open(_: Any?) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = supportedFileTypes

        let modal = openPanel.runModal()
        if modal == .OK {
            guard let file = openPanel.url, let main = NSApp.mainWindow?.contentViewController as! HomeViewController? else {
                return
            }

            main.open(with: file)
        } else {
            exit(EXIT_FAILURE)
        }
    }
}
