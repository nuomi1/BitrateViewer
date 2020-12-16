//
//  Array.swift
//  BitrateViewer
//
//  Created by nuomi on 2018/2/13.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import CoreMedia

extension Array where Element: DurationEquatable {
    func eachSlice<S>(duration: CMTime, transfrom: (ArraySlice<Element>) -> S) -> [S] {
        assert(!indices.isEmpty)

        var result = [S]()

        var sliceDuration = CMTimeValue(0)
        var startIndex = 0

        for i in indices {
            sliceDuration += self[i].duration

            if (sliceDuration > duration.value && i > indices.first!) || i == indices.last! {
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
        assert(!indices.isEmpty)

        var result = [S]()

        var sliceDuration = CMTimeValue(0)
        var startIndex = 0

        for i in indices {
            sliceDuration += self[i].duration

            if (self[i].type == .I && i > indices.first!) || i == indices.last! {
                result.append(transfrom(self[startIndex ..< i]))
                sliceDuration = self[i].duration
                startIndex = i
            }
        }

        return result
    }
}
