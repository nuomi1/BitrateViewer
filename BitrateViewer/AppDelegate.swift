//
//  AppDelegate.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        openDocument(nil)
    }

    @IBAction func openDocument(_: Any?) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = supportedFileTypes
        openPanel.treatsFilePackagesAsDirectories = true // 不处理会把含有后缀名的文件夹当做文件

        openPanel.begin {
            switch $0 {
            case .OK:
                guard let file = openPanel.url, let main = NSApp.mainWindow?.contentViewController as! MainViewController? else {
                    return
                }

                main.open(with: file)
            default:
                exit(EXIT_FAILURE)
            }
        }
    }
}
