//
//  Stream.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import CoreMedia.CMTime

struct Stream: Decodable {
    /**
     - SeeAlso:
     [int AVCodecParameters::width](https://ffmpeg.org/doxygen/trunk/structAVCodecParameters.html#a51639f88aef9f4f283f538a0c033fbb8)
     */
    let width: Int

    /**
     - SeeAlso:
     [int AVCodecParameters::height](https://ffmpeg.org/doxygen/trunk/structAVCodecParameters.html#a1ec57ee84f19cf65d00eaa4d2a2253ce)
     */
    let height: Int

    /**
     - SeeAlso:
     [AVRational AVStream::avg_frame_rate](https://ffmpeg.org/doxygen/trunk/structAVStream.html#a946e1e9b89eeeae4cab8a833b482c1ad)
     */
    let frameRate: Double

    /**
     - SeeAlso:
     [AVRational AVStream::time_base](https://ffmpeg.org/doxygen/trunk/structAVStream.html#a9db755451f14e2bf590d4b85d82b32e6)
     */
    let timeScale: CMTimeScale

    /**
     - SeeAlso:
     [int64_t AVStream::duration](https://ffmpeg.org/doxygen/trunk/structAVStream.html#a4e04af7a5a4d8298649850df798dd0bc)
     */
    let duration: CMTime

    /**
     - SeeAlso:
     [int64_t AVCodecParameters::bit_rate](https://ffmpeg.org/doxygen/trunk/structAVCodecParameters.html#a5268fcf4ae8ed27edef54f836b926d93)
     */
    let bitRate: Int

    /**
     - SeeAlso:
     [int64_t AVStream::nb_frames](https://ffmpeg.org/doxygen/trunk/structAVStream.html#a4382c3064df1c9eb232ac198dec067f9)
     */
    let frames: Int

    private enum CodingKeys: String, CodingKey {
        case width
        case height
        case frameRate = "avg_frame_rate"
        case timeScale = "time_base"
        case duration = "duration_ts"
        case bitRate = "bit_rate"
        case frames = "nb_frames"
    }
}

extension Stream {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        bitRate = Int(try container.decode(String.self, forKey: .bitRate))!
        frames = Int(try container.decode(String.self, forKey: .frames))!

        let _frameRate = try container.decode(String.self, forKey: .frameRate).split(separator: "/").map { Int($0) }
        frameRate = Double(_frameRate[0]! / _frameRate[1]!)

        let _timeScale = try container.decode(String.self, forKey: .timeScale).split(separator: "/").map { Int($0) }
        timeScale = CMTimeScale(_timeScale[1]!)

        let _duration = try container.decode(CMTimeValue.self, forKey: .duration)
        duration = CMTime(value: _duration, timescale: timeScale)
    }
}
