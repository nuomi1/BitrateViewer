//
//  Utilities.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import AppKit.NSAlert

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

let kInfo = "Info"
let kCursor = "Curosr"
let kLabel = "Label"
let kSecond = "Second"
let kGOP = "GOP"
let kFrame = "Frame"
