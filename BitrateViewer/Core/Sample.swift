//
//  Sample.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import CoreMedia

protocol DurationEquatable {
    var duration: CMTimeValue { get }
}

protocol TypeEquatable {
    var type: PictureType { get }
}

enum PictureType: String, Codable {
    case I
    case B
    case P
    case None
}

struct Sample: Codable, DurationEquatable, TypeEquatable {
    /**
     - SeeAlso:
     [int64_t AVFrame::best_effort_timestamp](https://ffmpeg.org/doxygen/trunk/structAVFrame.html#a0943e85eb624c2191490862ececd319d)
     */
    let timeStamp: CMTimeValue

    /**
     - SeeAlso:
     [int64_t AVFrame::pkt_duration](https://ffmpeg.org/doxygen/trunk/structAVFrame.html#a385c44d7cafe80cad82fe46e25cab221)
     */
    let duration: CMTimeValue

    /**
     - SeeAlso:
     [int AVFrame::pkt_size](https://ffmpeg.org/doxygen/trunk/structAVFrame.html#a3cc73a3345ec1ff8e473ab6049c607e7)
     */
    let size: Int

    /**
     - SeeAlso:
     [enum AVPictureType AVFrame::pict_type](https://ffmpeg.org/doxygen/trunk/structAVFrame.html#af9920fc3fbfa347b8943ae461b50d18b)
     */
    let type: PictureType

    private enum CodingKeys: String, CodingKey {
        case timeStamp = "best_effort_timestamp"
        case duration = "pkt_duration"
        case size = "pkt_size"
        case type = "pict_type"
    }

    static func + (lhs: Sample, rhs: Sample) -> Sample {
        return Sample(timeStamp: min(lhs.timeStamp, rhs.timeStamp),
                      duration: lhs.duration + rhs.duration,
                      size: lhs.size + rhs.size,
                      type: .None)
    }
}

extension Sample {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        timeStamp = try container.decode(CMTimeValue.self, forKey: .timeStamp)
        duration = try container.decodeIfPresent(CMTimeValue.self, forKey: .duration) ?? 0
        size = Int(try container.decode(String.self, forKey: .size))!
        type = try container.decode(PictureType.self, forKey: .type)
    }
}

extension Sample: Comparable {
    static func < (lhs: Sample, rhs: Sample) -> Bool {
        return lhs.size < rhs.size
    }

    static func == (lhs: Sample, rhs: Sample) -> Bool {
        return lhs.timeStamp == rhs.timeStamp
            && lhs.duration == rhs.duration
            && lhs.size == rhs.size
            && lhs.type == rhs.type
    }
}
