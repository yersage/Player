//
//  DVRViewController.swift
//  Player
//
//  Created by user on 02.11.2022.
//

import UIKit

class DVRViewController: UIViewController {
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = UIFont.systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var currentDayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var center: UIView = {
        let centerView = UIView()
        centerView.backgroundColor = .red
        centerView.translatesAutoresizingMaskIntoConstraints = false
        return centerView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var dummyLeftMargin: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dummyRightMargin: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var timeframeView: TimeframeView = {
        let ruler = TimeframeView()
        ruler.backgroundColor = .white
        ruler.isUserInteractionEnabled = true
        ruler.translatesAutoresizingMaskIntoConstraints = false
        return ruler
    }()
    
    private var currentMinutes: CGFloat = 0.0
    
    var dvrMode: DVRMode = .TwoWeeks
    private var rulerWidthConstraints = [NSLayoutConstraint]()
    private var timeframeViews = [TimeframeView]()
    
    private var recordRanges = [
        RecordRangeModel(startTime: "1665266186", endTime: "1665273386"), // old records
        RecordRangeModel(startTime: "1666792586", endTime: "1666810586"),
        RecordRangeModel(startTime: "1666814186", endTime: "1666821386"),
        RecordRangeModel(startTime: "1666900586", endTime: "1666907786"),
        RecordRangeModel(startTime: "1666986986", endTime: "1666994186"),
        RecordRangeModel(startTime: "1667073386", endTime: "1667080586"),
        RecordRangeModel(startTime: "1667159786", endTime: "1667166986"),
        RecordRangeModel(startTime: "1667246186", endTime: "1667253386"),
        RecordRangeModel(startTime: "1667332586", endTime: "1667339786"),
        RecordRangeModel(startTime: "1667418986", endTime: "1667426186"),
        RecordRangeModel(startTime: "1667505386", endTime: "1667512586"),
        RecordRangeModel(startTime: "1667591786", endTime: "1667598986"),
        RecordRangeModel(startTime: "1667678186", endTime: "1667685386"),
        RecordRangeModel(startTime: "1667764586", endTime: "1667771786"),
        RecordRangeModel(startTime: "1667850986", endTime: "1667858186"),
        RecordRangeModel(startTime: "1667937386", endTime: "1667944586"),
    ]
    
    var currentDay = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        printRecordRanges()
        
        let userCalendar = Calendar.current
        let twoWeeksAgo = userCalendar.date(byAdding: .day, value: -dvrMode.rawValue, to: Date())
        
        recordRanges = recordRanges.filter { recordRangeModel in
            return ((recordRangeModel.startTimeDate)! >= twoWeeksAgo!) &&
                    ((recordRangeModel.endTimeDate)! >= twoWeeksAgo!)
        }
        
        currentDayLabel.text = "Day \(currentDay)"
        
        view.addSubview(currentTimeLabel)
        view.addSubview(currentDayLabel)
        view.addSubview(center)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        dummyLeftMargin.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2).isActive = true
        stackView.addArrangedSubview(dummyLeftMargin)
        
        for i in 0 ..< dvrMode.rawValue {
            let timeframeview = TimeframeView()
            
            let date = userCalendar.date(byAdding: .day, value: -dvrMode.rawValue + i, to: Date())
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)
            
            timeframeview.date = date
            timeframeview.dateComponents = dateComponents
            
            timeframeview.recordRanges = recordRanges.filter { recordRangeModel in
                return Calendar.current.isDate(recordRangeModel.startTimeDate!, equalTo: date!, toGranularity: .day) || Calendar.current.isDate(recordRangeModel.endTimeDate!, equalTo: date!, toGranularity: .day)
            }
            
            timeframeview.backgroundColor = .white
            rulerWidthConstraints.append(timeframeview.widthAnchor.constraint(equalToConstant: timeframeview.currentScaleLength))
            timeframeViews.append(timeframeview)
            
            stackView.addArrangedSubview(timeframeview)
        }
        
        for rulerWidthConstraint in rulerWidthConstraints {
            rulerWidthConstraint.isActive = true
        }
        
        dummyRightMargin.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2).isActive = true
        stackView.addArrangedSubview(dummyRightMargin)
        
        timeframeView.recordRanges = recordRanges
        
        scrollView.addGestureRecognizer(UIPinchGestureRecognizer(target: self,
                                                                 action: #selector(didPinch(_:))))
        
        view.bringSubviewToFront(center)
                
        setupConstraints()
        
        scrollToCurrentDate()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            currentTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            currentTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            currentDayLabel.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 20),
            currentDayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            center.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            center.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -20),
            center.heightAnchor.constraint(equalToConstant: 30),
            center.widthAnchor.constraint(equalToConstant: 1),
        ])
        
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: 100),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            timeframeView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCurrentDate()
    }
}

extension DVRViewController {
    func scrollToCurrentDate() {
        var currentContentOffset: CGFloat = 0
        
        for i in 0 ..< timeframeViews.count - 1 {
            currentContentOffset += timeframeViews[i].currentScaleLength
        }
        
        currentDay = rulerWidthConstraints.count - 1
        currentDayLabel.text = String(format: "Day %d", currentDay)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        
        let currentSeconds = (dateComponents.hour! * 3600) + (dateComponents.minute! * 60) + (dateComponents.second!)
        currentTimeLabel.text = String(format: "%02d:%02d:%02d", dateComponents.hour!, dateComponents.minute!, dateComponents.second!)
        
        currentContentOffset += (CGFloat(currentSeconds) / 60) * timeframeViews[currentDay].distanceBetweenScales
        
        scrollView.setContentOffset(CGPoint(x: currentContentOffset, y: 0), animated: false)
    }
}

extension DVRViewController {
    @objc func didPinch(_ gestureRecognizer : UIPinchGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .changed {
            timeframeViews[currentDay].currentScaleLength *= gestureRecognizer.scale
            rulerWidthConstraints[currentDay].constant = timeframeViews[currentDay].currentScaleLength
            gestureRecognizer.scale = 1.0
            
            var newOffset: CGFloat = 0.0
            
            for timeframeView in timeframeViews {
                timeframeView.setNeedsDisplay()
            }
            
            for i in 0 ..< currentDay {
                newOffset += timeframeViews[i].currentScaleLength
            }
            
            newOffset += currentMinutes * timeframeViews[currentDay].distanceBetweenScales
            
            let pointToScroll = CGPoint(x: (newOffset),
                                        y: 0)
            scrollView.setContentOffset(pointToScroll, animated: false)
        }
    }
}

extension DVRViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var currentContentOffset = scrollView.contentOffset.x
        var currentDayCounter = 0
        
        while currentDayCounter < rulerWidthConstraints.count {
            if currentContentOffset <= rulerWidthConstraints[currentDayCounter].constant {
                break
            } else {
                currentContentOffset -= rulerWidthConstraints[currentDayCounter].constant
                currentDayCounter += 1
            }
        }
        
        currentDay = currentDayCounter < rulerWidthConstraints.count ? currentDayCounter : currentDayCounter - 1
        
        let userCalendar = Calendar.current
        let currentDate = userCalendar.date(byAdding: .day, value: -dvrMode.rawValue + currentDay, to: Date())
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate!)
        
        currentDayLabel.text = String(format: "%02d.%02d.%02d", dateComponents.day!, dateComponents.month!, dateComponents.year! % 100)
        
        currentMinutes = currentContentOffset / timeframeViews[currentDay].distanceBetweenScales
        let currentMinutes = Int(Float(currentMinutes) * 60)
        currentTimeLabel.text = String(format: "%02d:%02d:%02d", currentMinutes / 3600, (currentMinutes / 60) % 60, currentMinutes % 60)
    }
}

extension DVRViewController {
    func printRecordRanges() {
        for recordRange in recordRanges {
            let date = Date(timeIntervalSince1970: Double(recordRange.startTime.prefix(10))!)
            let date2 = Date(timeIntervalSince1970: Double(recordRange.endTime.prefix(10))!)
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeZone = .current
            
            print(dateFormatter.string(from: date) + " " + dateFormatter.string(from: date2))
        }
    }
}


