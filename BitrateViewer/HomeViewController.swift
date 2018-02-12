//
//  HomeViewController.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2017年 nuomi1. All rights reserved.
//

import Charts
import CoreMedia.CMTime

class HomeViewController: NSViewController {
    @IBOutlet var barChartView: BarChartView!
    @IBOutlet var dragView: DragView!

    @IBOutlet var durationLabel: NSTextField!
    @IBOutlet var minBitRateLabel: NSTextField!
    @IBOutlet var maxBitRateLabel: NSTextField!
    @IBOutlet var avgBitRateLabel: NSTextField!
    @IBOutlet var widthHeightLabel: NSTextField!
    @IBOutlet var framesLabel: NSTextField!

    @IBOutlet var timeLabel: NSTextField!
    @IBOutlet var bitRateLabel: NSTextField!
    @IBOutlet var pictureTypeLabel: NSTextField!

    @IBOutlet var loadingSpinner: NSProgressIndicator!

    private var videoAnalyzer: VideoAnalyzer!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingSpinner.isHidden = true

        barChartView.delegate = self
        barChartView.setScaleEnabled(false)
        barChartView.chartDescription = nil

        dragView.delegate = self
    }

    @IBAction func handleMode(_ sender: NSPopUpButton) {
        if let tag = sender.selectedItem?.tag {
            switch tag {
            case 0:
                videoAnalyzer.change(to: .second(CMTime(value: 1, timescale: 1)))
            case 1:
                videoAnalyzer.change(to: .gop)
            default:
                videoAnalyzer.change(to: .frame)
            }

            updateUI()
        }
    }

    func open(with file: URL) {
        loadingSpinner.isHidden = false
        loadingSpinner.startAnimation(self)

        videoAnalyzer = VideoAnalyzer(with: file)
        videoAnalyzer.change(to: .frame)

        loadingSpinner.stopAnimation(self)
        loadingSpinner.isHidden = true

        NSApp.mainWindow?.title = "\(Bundle.main.infoDictionary![kIOBundleNameKey]!) - \(file.path)"
        updateUI()
    }

    private func updateUI() {
        let dataEntries = videoAnalyzer.samples.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: Double($0.element.size) * videoAnalyzer.frameRate / 125) }

        let dataSet = BarChartDataSet(values: dataEntries, label: nil)
        dataSet.colors = [.red]

        let data = BarChartData()
        data.addDataSet(dataSet)

        barChartView.data = data

        let firstDataEntry = dataEntries.first!
        barChartView.highlightValue(x: firstDataEntry.x, y: firstDataEntry.y, dataSetIndex: 0)

        durationLabel.stringValue = "\(videoAnalyzer.duration)"
        maxBitRateLabel.stringValue = "\(videoAnalyzer.maxBitrate) kbps"
        minBitRateLabel.stringValue = "\(videoAnalyzer.minBitrate) kbps"
        avgBitRateLabel.stringValue = "\(videoAnalyzer.avgBitrate) kbps"
        widthHeightLabel.stringValue = "\(videoAnalyzer.width) * \(videoAnalyzer.height)"
        framesLabel.stringValue = "\(videoAnalyzer.count)"
    }
}

extension HomeViewController: ChartViewDelegate {
    func chartValueSelected(_: ChartViewBase, entry _: ChartDataEntry, highlight: Highlight) {
        let index = Int(highlight.x)

        timeLabel.stringValue = "\(CMTime(value: videoAnalyzer.samples[index].timeStamp, timescale: videoAnalyzer.timeScale))"
        bitRateLabel.stringValue = "\(Int(highlight.y)) kbps"
        pictureTypeLabel.stringValue = "\(videoAnalyzer.samples[index].type)"
    }
}

extension HomeViewController: DragViewDelegate {
    func dragged(with file: URL) {
        open(with: file)
    }
}
