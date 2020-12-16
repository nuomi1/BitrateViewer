//
//  Float64.swift
//  BitrateViewer
//
//  Created by nuomi on 2018/2/13.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

extension Float64 {
    static func % (lhs: Float64, rhs: Float64) -> Float64 {
        return lhs.truncatingRemainder(dividingBy: rhs)
    }
}
