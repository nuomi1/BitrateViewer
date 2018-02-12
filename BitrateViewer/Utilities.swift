//
//  Utilities.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2017年 nuomi1. All rights reserved.
//

import AppKit.NSAlert
import CoreMedia.CMTime

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

extension Float64 {
    static func % (lhs: Float64, rhs: Float64) -> Float64 {
        return lhs.truncatingRemainder(dividingBy: rhs)
    }
}

//    private func getFFprobePath() -> String? {
//        let task = Process()
//        task.launchPath = "/usr/bin/env"
//
//        task.arguments = [
//            "which", "ffprobe",
//        ]
//
//        let stdout = Pipe()
//        task.standardOutput = stdout
//
//        task.launch()
//        task.waitUntilExit()
//
//        let pipeData = stdout.fileHandleForReading.readDataToEndOfFile()
//        return String(data: pipeData, encoding: .utf8)
//    }

func analyze(for file: URL) {
    let fileManager = FileManager.default

    guard !fileManager.fileExists(atPath: file.path + ".json") else {
        return
    }

    guard fileManager.fileExists(atPath: "/usr/local/bin/ffprobe") else {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Not found ffprobe in /usr/local/bin !"

        alert.runModal()

        exit(EXIT_FAILURE)
    }

    //        guard let ffprobePath = getFFprobePath() else {
    //            return
    //        }

    let task = Process()
    task.launchPath = "/usr/bin/env"

    task.arguments = [
        //            ffprobePath,
        "/usr/local/bin/ffprobe",
        "-loglevel", "quiet",
        "-print_format", "json",
        "-select_streams", "video:0",
        "-show_entries", "stream=width,height,avg_frame_rate,time_base,duration_ts,bit_rate,nb_frames"
            + ":frame=best_effort_timestamp,pkt_duration,pkt_size,pict_type",
        file.path,
    ]

    let stdout = Pipe()
    task.standardOutput = stdout

    task.launch()
    task.waitUntilExit()

    let pipeData = stdout.fileHandleForReading.readDataToEndOfFile()
    fileManager.createFile(atPath: file.path + ".json", contents: pipeData)
}

let supportedFileTypes = [
    "avi", "f4v", "flv", "m2ts", "m4v", "mkv", "mov", "mp4", "mpeg", "mpg",
    "qt", "rm", "rmvb", "ts", "vob", "webm", "wmv",
]
