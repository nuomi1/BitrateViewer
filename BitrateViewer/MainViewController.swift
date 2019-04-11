//
//  MainViewController.swift
//  BitrateViewer
//
//  Created by nuomi on 2017/11/3.
//  Copyright © 2018年 nuomi1. All rights reserved.
//

import Charts
import Cocoa
import CoreMedia
import RxCocoa
import RxSwift
import SnapKit

class MainViewController: NSViewController {
    private var infoDataSource: [String?] = [
        "Info", nil,
        "Duration:", "Duration Info",
        "Min Bitrate:", "Min Bitrate Info",
        "Max Bitrate:", "Max Bitrate Info",
        "Avg Bitrate:", "Avg Bitrate Info",
        "Width * Height:", "Width * Height Info",
        "Frames:", "Frames Info",
    ]
    private var cursorDataSource: [String?] = [
        "Curosr", nil,
        "Time:", "Time Info",
        "Bitrate:", "Bitrate Info",
        "Picture Type:", "Picture Type Info",
    ]

    private var barChartView = BarChartView()
    private var dragView = DragView()

    private var infoTableView = NSTableView.cBasic
    private var cursorTableView = NSTableView.cBasic
    private var modeButton = NSPopUpButton()

    private var loadingSpinner = NSProgressIndicator()

    private var videoAnalyzer = VideoAnalyzer()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()

        view.addSubview(barChartView)
        view.addSubview(dragView)
        view.addSubview(infoTableView)
        view.addSubview(cursorTableView)
        view.addSubview(modeButton)
        view.addSubview(loadingSpinner)

        dragView.snp.makeConstraints({
            $0.edges.equalTo(view)
        })

        barChartView.snp.makeConstraints({
            $0.top.equalTo(view).offset(20)
            $0.bottom.equalTo(view).offset(-20)
            $0.left.equalTo(view).offset(20)
        })

        infoTableView.snp.makeConstraints {
            $0.size.equalTo(infoTableView.bounds.size)
            $0.top.equalTo(barChartView)
            $0.left.equalTo(barChartView.snp.right).offset(20)
            $0.right.equalTo(view).offset(-20)
        }

        cursorTableView.snp.makeConstraints {
            $0.size.equalTo(cursorTableView.bounds.size)
            $0.top.equalTo(infoTableView.snp.bottom).offset(20)
            $0.left.equalTo(infoTableView)
        }

        modeButton.snp.makeConstraints {
            $0.bottom.equalTo(barChartView)
            $0.right.equalTo(cursorTableView)
        }

        loadingSpinner.snp.makeConstraints({
            $0.size.equalTo(NSSize(width: 32, height: 32))
            $0.center.equalTo(view)
        })
    }

    private func setUpViews() {
        barChartView.delegate = self
        barChartView.setScaleEnabled(false)
        barChartView.chartDescription = nil

        dragView.delegate = self

        infoTableView.dataSource = self
        infoTableView.delegate = self
        infoTableView.addTableColumn(NSTableColumn(identifier: (NSUserInterfaceItemIdentifier(kInfo + "." + kLabel))))
        infoTableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(kInfo + "." + kInfo)))

        cursorTableView.dataSource = self
        cursorTableView.delegate = self
        cursorTableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(kCursor + "." + kLabel)))
        cursorTableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(kCursor + "." + kInfo)))

        modeButton.addItems(withTitles: [kSecond, kGOP, kFrame])
        modeButton.item(withTitle: kSecond)?.keyEquivalent = "s"
        modeButton.item(withTitle: kGOP)?.keyEquivalent = "g"
        modeButton.item(withTitle: kFrame)?.keyEquivalent = "f"
        modeButton.selectItem(withTitle: kFrame)

        modeButton.rx.tap
            .bind {
                if let title = self.modeButton.selectedItem?.title {
                    switch title {
                    case kSecond:
                        self.videoAnalyzer.change(to: .second(CMTime(value: 1, timescale: 1)))
                    case kGOP:
                        self.videoAnalyzer.change(to: .gop)
                    default:
                        self.videoAnalyzer.change(to: .frame)
                    }

                    self.updateUI()
                }
            }
            .disposed(by: disposeBag)

        loadingSpinner.style = .spinning

        hideViews()
        loadingSpinner.isHidden = true
    }

    func open(with file: URL) {
        hideViews()

        loadingSpinner.isHidden = false
        loadingSpinner.startAnimation(self)

        videoAnalyzer = VideoAnalyzer(with: file)
        videoAnalyzer.change(to: .frame)

        loadingSpinner.stopAnimation(self)
        loadingSpinner.isHidden = true

        NSApp.mainWindow?.title = "\(Bundle.main.infoDictionary![kIOBundleNameKey]!) - \(file.path)"
        updateUI()

        showViews()
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

        infoDataSource[3] = "\(videoAnalyzer.duration)"
        infoDataSource[5] = "\(videoAnalyzer.maxBitrate) kbps"
        infoDataSource[7] = "\(videoAnalyzer.minBitrate) kbps"
        infoDataSource[9] = "\(videoAnalyzer.avgBitrate) kbps"
        infoDataSource[11] = "\(videoAnalyzer.width) * \(videoAnalyzer.height)"
        infoDataSource[13] = "\(videoAnalyzer.count)"

        infoTableView.reloadData()
    }

    private func showViews() {
        barChartView.isHidden = false
        infoTableView.isHidden = false
        cursorTableView.isHidden = false
        modeButton.isHidden = false
    }

    private func hideViews() {
        barChartView.isHidden = true
        infoTableView.isHidden = true
        cursorTableView.isHidden = true
        modeButton.isHidden = true
    }
}

extension MainViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(highlight.x)

        cursorDataSource[3] = "\(CMTime(value: videoAnalyzer.samples[index].timeStamp, timescale: videoAnalyzer.timeScale))"
        cursorDataSource[5] = "\(Int(highlight.y)) kbps"
        cursorDataSource[7] = "\(videoAnalyzer.samples[index].type)"

        cursorTableView.reloadData()
    }
}

extension MainViewController: DragViewDelegate {
    func dragged(with file: URL) {
        open(with: file)
    }
}

extension MainViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == infoTableView {
            return infoDataSource.count / 2
        }
        if tableView == cursorTableView {
            return cursorDataSource.count / 2
        }

        return 0
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let identifier = tableColumn?.identifier else {
            return nil
        }

        var value: Any?
        let isLabel = identifier.rawValue.split(separator: ".").contains(Substring(kLabel))

        if tableView == infoTableView {
            value = isLabel ? infoDataSource[2 * row] : infoDataSource[2 * row + 1]
        }
        if tableView == cursorTableView {
            value = isLabel ? cursorDataSource[2 * row] : cursorDataSource[2 * row + 1]
        }

        return value
    }
}

extension MainViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else {
            return nil
        }

        var view = tableView.makeView(withIdentifier: identifier, owner: self)
        let isLabel = identifier.rawValue.split(separator: ".").contains(Substring(kLabel))

        if row == 0 {
            view = isLabel ? NSTextField.cTiTle : nil
        } else {
            view = isLabel ? NSTextField.cLabel : NSTextField.cInfo
        }

        return view
    }
}
