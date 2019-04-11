//
//  CMTime.swift
//  BitrateViewer
//
//  Created by nuomi on 2018/2/13.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import CoreMedia

extension CMTime: CustomStringConvertible {
    public var description: String {
        let seconds = CMTimeGetSeconds(self)

        let hour = Int(seconds / 3600)
        let minute = Int(seconds % 3600 / 60)
        let second = Int(seconds % 60)
        let millisecond = Int(seconds * 1000 % 1000)

        if hour > 0 {
            return String(format: "%i:%02i:%02i:%03i", hour, minute, second, millisecond)
        } else {
            return String(format: "%02i:%02i:%03i", minute, second, millisecond)
        }
    }
}
