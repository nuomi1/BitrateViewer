//
//  NSTableView.swift
//  BitrateViewer
//
//  Created by nuomi on 2018/2/13.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import AppKit.NSTableView

extension NSTableView {
    class var cBasic: NSTableView {
        let tableView = NSTableView()
        tableView.backgroundColor = .clear
        tableView.rowSizeStyle = .small
        tableView.isEnabled = false
        return tableView
    }
}
