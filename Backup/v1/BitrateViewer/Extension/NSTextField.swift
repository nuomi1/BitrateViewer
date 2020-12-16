//
//  NSTextField.swift
//  BitrateViewer
//
//  Created by nuomi on 2018/2/13.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import AppKit

extension NSTextField {
    private class var cBasic: NSTextField {
        let textField = NSTextField()
        textField.isEditable = false
        textField.drawsBackground = false
        textField.isBordered = false
        textField.font = .systemFont(ofSize: NSFont.systemFontSize)
        return textField
    }

    class var cTiTle: NSTextField {
        let textField = cBasic
        textField.font = .boldSystemFont(ofSize: NSFont.systemFontSize + 2)
        return textField
    }

    class var cLabel: NSTextField {
        let textField = cBasic
        textField.alignment = .right
        return textField
    }

    class var cInfo: NSTextField {
        let textField = cBasic
        textField.alignment = .left
        return textField
    }
}
