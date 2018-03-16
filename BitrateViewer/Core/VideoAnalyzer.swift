//
//  VideoAnalyzer.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import CoreMedia.CMTime

struct VideoFile: Decodable {
    var frames: [Sample]
    var streams: [Stream]
}

enum AnalyzeMode {
    case second(CMTime)
    case gop
    case frame
}

class VideoAnalyzer {
    private var videoFile = VideoFile(frames: [], streams: [])

    private var frames: [Sample] {
        return videoFile.frames
    }

    private var stream: Stream {
        return videoFile.streams.first!
    }

    var samples = [Sample]()

    var timeScale: CMTimeScale {
        return stream.timeScale
    }

    var frameRate: Double {
        return stream.frameRate
    }

    var duration: CMTime {
        if stream.duration.isValid {
            return stream.duration
        }

        return CMTime(value: frames.last!.timeStamp + frames.last!.duration, timescale: timeScale)
    }

    private var minSize: Int {
        return samples.min()!.size
    }

    private var maxSize: Int {
        return samples.max()!.size
    }

    var minBitrate: Int {
        return Int(Double(minSize) * frameRate / 125)
    }

    var maxBitrate: Int {
        return Int(Double(maxSize) * frameRate / 125)
    }

    var avgBitrate: Int {
        return stream.bitRate / 1000
    }

    var width: Int {
        return stream.width
    }

    var height: Int {
        return stream.height
    }

    var count: Int {
        return frames.count
    }

    func change(to mode: AnalyzeMode) {
        switch mode {
        case let .second(time):
            samples = groupBy(time: time)
        case .gop:
            samples = groupByGOP()
        case .frame:
            samples = frames
        }
    }

    private func groupBy(time: CMTime) -> [Sample] {
        let _time = time.convertScale(duration.timescale, method: .default)

        return frames.eachSlice(duration: _time) {
            if let firstSample = $0.first {
                return $0.reduce(Sample(timeStamp: firstSample.timeStamp, duration: 0, size: 0, type: .None)) {
                    $0 + $1
                }
            } else {
                fatalError()
            }
        }
    }

    private func groupByGOP() -> [Sample] {
        return frames.eachSlice {
            if let firstSample = $0.first {
                return $0.reduce(Sample(timeStamp: firstSample.timeStamp, duration: 0, size: 0, type: .None)) {
                    $0 + $1
                }
            } else {
                fatalError()
            }
        }
    }
}

extension VideoAnalyzer {
    convenience init(with file: URL) {
        self.init()

        analyze(for: file)

        guard let data = try? Data(contentsOf: file.appendingPathExtension(kjson)), let json = try? JSONDecoder().decode(VideoFile.self, from: data) else {
            return
        }

        videoFile = VideoFile(frames: json.frames, streams: json.streams)
    }
}
