//
//  DragView.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import AppKit

protocol DragViewDelegate {
    func dragged(with file: URL)
}

// https://zhaoxin.pro/14760064829493.html
class DragView: NSView {
    var delegate: DragViewDelegate?

    convenience init() {
        self.init(frame: .zero)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        layer?.backgroundColor = NSColor.gray.cgColor

        let sourceOperationMask = sender.draggingSourceOperationMask()
        return sourceOperationMask.contains(.generic) ? .generic : []
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()

        if pasteboard.types!.contains(.fileURL) {
            let files = pasteboard.readObjects(forClasses: [NSURL.self]) as! [URL]
            //            let file = URL(string: pasteboard.propertyList(forType: .fileURL) as! String)

            if supportedFileTypes.contains(files.first!.pathExtension.lowercased()) {
                delegate?.dragged(with: files.first!)
                return true
            }
        }

        return false
    }
}
