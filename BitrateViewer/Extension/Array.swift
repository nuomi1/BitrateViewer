//
//  Array.swift
//  BitrateViewer
//
//  Created by nuomi on 2018/2/13.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import CoreMedia.CMTime

extension Array where Element: DurationEquatable {
    func eachSlice<S>(duration: CMTime, transfrom: (ArraySlice<Element>) -> S) -> [S] {
        var result = [S]()

        var sliceDuration = CMTimeValue(0)
        var startIndex = 0

        for i in 0 ..< count {
            sliceDuration += self[i].duration

            if (sliceDuration > duration.value && i > 0) || i == (count - 1) {
                result.append(transfrom(self[startIndex ..< i]))
                sliceDuration = self[i].duration
                startIndex = i
            }
        }

        return result
    }
}

extension Array where Element: TypeEquatable & DurationEquatable {
    func eachSlice<S>(transfrom: (ArraySlice<Element>) -> S) -> [S] {
        var result = [S]()

        var sliceDuration = CMTimeValue(0)
        var startIndex = 0

        for i in 0 ..< count {
            sliceDuration += self[i].duration

            if (self[i].type == .I && i > 0) || i == (count - 1) {
                result.append(transfrom(self[startIndex ..< i]))
                sliceDuration = self[i].duration
                startIndex = i
            }
        }

        return result
    }
}
