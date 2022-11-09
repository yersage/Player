//
//  TimeframeView.swift
//  Player
//
//  Created by user on 01.11.2022.
//

import UIKit

final class TimeframeView: UIView {
    
    // MARK: - Layout constants
    private var leftMargin = UIScreen.main.bounds.width / 2
    private var rightMargin = UIScreen.main.bounds.width / 2
    
    private let recordsRangeHeight: CGFloat = 5.0
    
    private let lengthOfBigScale: CGFloat = 25.0
    private let lengthOfSmallScale: CGFloat = 10.0
    
    private let timeStampWidth: CGFloat = 33.0
    private let timeStampHeight: CGFloat = 14.0
    
    private let dayWidth: CGFloat = 50.0
    private let dayHeight: CGFloat = 14.0
    
    // MARK: - Logic constants
    private let smallestStep = 1
    private let biggestStep = 480
    
    private let numberOfMinutes: Double = 1440
    
    private let distance: CGFloat = 60.0
    
    var recordRanges = [RecordRangeModel]()
    
    // MARK: - Variables
    var dateComponents: DateComponents? = nil
    var date: Date? = nil
    
    init() {
        self.dateComponents = nil
        super.init(frame: .zero)
    }
    
    init(dateComponents: DateComponents) {
        self.dateComponents = dateComponents
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isShowingDayOnTheLastScale: Bool = false
    
    private var day: String {
        if let day = dateComponents?.day,
           let month = dateComponents?.month,
           let year = dateComponents?.year {
            return String(format: "%d.%d.%d", day, month, year % 100)
        } else {
            return ""
        }
    }
    
    var distanceBetweenScales: CGFloat {
        return currentScaleLength / numberOfMinutes
    }
    
    private var step: Double {
        return (distance * numberOfMinutes) / currentScaleLength
    }
    
    private var rangeBetweenTimestamps: Int {
        if step > 288 {
            return 360
        } else if step > 196 {
            return 240
        } else if step > 144 {
            return 180
        } else if step > 96 {
            return 120
        } else if step > 48 {
            return 60
        } else if step > 24 {
            return 30
        } else if step > 15 {
            return 20
        } else if step > 5 {
            return 10
        } else if step > 4 {
            return 5
        } else if step > 2 {
            return 4
        } else if step > 1 {
            return 2
        } else {
            return 1
        }
    }
    
    private var numberOfScalesBetweenTimeStamps = 4
    
    var currentScaleLength: Double = 4 * 60.0
    
    var currentTime: Int {
        let currentDateTime = Date()
        let userCalendar = Calendar.current

        let requestedComponents: Set<Calendar.Component> = [
            .hour,
            .minute,
            .second
        ]

        let dateTimeComponents = userCalendar.dateComponents(requestedComponents,
                                                             from: currentDateTime)
        
        return (dateTimeComponents.hour! * 3600) + (dateTimeComponents.minute! * 60) + dateTimeComponents.second!
    }
}

extension TimeframeView {
    override func draw(_ rect: CGRect) {
        layer.sublayers = nil
        
        leftMargin = 0.0
//        leftMargin = 100.0
        rightMargin = 100.0
        var currentX: CGFloat = leftMargin
        
//        var currentX: CGFloat =  0
        
        drawDefaultTimeRange()
//        drawDay(day: day, x: currentX)
        drawTimeRanges(recordRanges: recordRanges,
                       color: UIColor.systemBlue.cgColor)
        
        for i in 0 ..< Int(numberOfMinutes) {
            var rangeBetweenScales = rangeBetweenTimestamps / 5
            rangeBetweenScales = rangeBetweenTimestamps < 5 ? rangeBetweenTimestamps : rangeBetweenScales
            
            if rangeBetweenTimestamps < 5 {
                drawScale(x: currentX, length: lengthOfBigScale)
                drawSmallScales(x: currentX, distanceBetweenSmallScales: distanceBetweenScales / 5, length: lengthOfBigScale / 2)
            } else if i % rangeBetweenTimestamps == 0 {
                drawScale(x: currentX, length: lengthOfBigScale)
            } else if (i % rangeBetweenTimestamps) % rangeBetweenScales == 0 {
                drawScale(x: currentX, length: lengthOfBigScale / 2)
            }
            
            if i % rangeBetweenTimestamps == 0 {
                drawTimeStamp(minutes: i, x: currentX)
            }
            
            currentX += distanceBetweenScales
        }
        
        drawScale(x: currentX,
                  length: lengthOfBigScale)
        drawTimeStamp(minutes: 1440, x: currentX)
        if isShowingDayOnTheLastScale {
            drawDay(day: day, x: currentX)
        }
    }
}

extension TimeframeView {
    private func drawTimeRanges(recordRanges: [RecordRangeModel], color: CGColor) {
        for recordRange in recordRanges {
            drawTimeRange(recordRange: recordRange, color: color)
        }
    }
    
    private func drawTimeRange(recordRange: RecordRangeModel, color: CGColor) {
        let coordinates = getCoordinatesBySeconds(recordRange: recordRange)
        
        let linePath = UIBezierPath()
        
        linePath.move(to: CGPoint(x: coordinates.start + leftMargin, y: 0))
        linePath.addLine(to: CGPoint(x: coordinates.end + leftMargin, y: 0))
        linePath.lineWidth = recordsRangeHeight
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = recordsRangeHeight
        
        layer.addSublayer(shapeLayer)
    }
    
    private func getCoordinatesBySeconds(recordRange: RecordRangeModel) -> (start: CGFloat, end: CGFloat) {
        
//        let isStartTimeEarlier = recordRange.startTimeDate! < date!
        let isStartTimeEqual = Calendar.current.isDate(recordRange.startTimeDate!, equalTo: date!, toGranularity: .day)
//        let isEndTimeSooner = recordRange.endTimeDate! > date!
        let isEndTimeEqual = Calendar.current.isDate(recordRange.endTimeDate!, equalTo: date!, toGranularity: .day)
        
        let startTimeInMinutes: Double = isStartTimeEqual ? Double(recordRange.startTimeInSeconds) / 60.0 : CGFloat.zero
        let endTimeInMinutes: Double = isEndTimeEqual ? Double(recordRange.endTimeInSeconds) / 60.0 : 60.0 * 24.0
        
        let startPoint: CGFloat = (currentScaleLength * startTimeInMinutes) / numberOfMinutes
        let endPoint: CGFloat = (currentScaleLength * endTimeInMinutes) / numberOfMinutes
        
        return (start: startPoint, end: endPoint)
    }
    
    private func drawDefaultTimeRange() {
        let linePath = UIBezierPath()
        
        linePath.move(to: CGPoint(x: 0 + leftMargin, y: 0))
        linePath.addLine(to: CGPoint(x: currentScaleLength + leftMargin, y: 0))
        linePath.lineWidth = recordsRangeHeight
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = recordsRangeHeight
        
        layer.addSublayer(shapeLayer)
    }
}

extension TimeframeView {
    private func drawScale(x: CGFloat, y: CGFloat = 5.0, length: CGFloat, lineWidth: CGFloat = 1.0) {
        let linePath = UIBezierPath()
        
        linePath.move(to: CGPoint(x: x, y: y))
        linePath.addLine(to: CGPoint(x: x, y: y + length))
        linePath.lineWidth = lineWidth
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = lineWidth
        
        layer.addSublayer(shapeLayer)
    }
    
    private func drawTimeStamp(minutes: Int, x: CGFloat, y: CGFloat = 5.0) {
        let hourString = (minutes / 60) < 10 ? String(format: "%02d", (minutes / 60)) : "\(minutes / 60)"
        let minuteString = (minutes % 60) < 10 ? String(format: "%02d", minutes % 60) : "\(minutes % 60)"
        let scaleDigit = "\(hourString):\(minuteString)"
        scaleDigit.draw(with: CGRect(x: x - (timeStampWidth/CGFloat(2)),
                                     y: y + lengthOfBigScale + 5,
                                     width: timeStampWidth,
                                     height: timeStampHeight),
                        options: .usesLineFragmentOrigin,
                        attributes: nil,
                        context: nil)
    }
    
    private func drawDay(day: String, x: CGFloat, y: CGFloat = 5.0 + 25.0 + 5.0 + 10.0) {
        let currentDay = day
        currentDay.draw(with: CGRect(x: x - (dayWidth/2.0), y: y + 5, width: dayWidth, height: dayHeight),
                        options: .usesLineFragmentOrigin,
                        attributes: nil,
                        context: nil)
    }
    
    private func drawSmallScales(x: CGFloat, y: CGFloat = 5.0, distanceBetweenSmallScales: CGFloat, length: CGFloat, lineWidth: CGFloat = 1.0) {
        var currentX = x
        
        for _ in 0 ..< 4 {
            currentX += distanceBetweenSmallScales
            drawScale(x: currentX, y: y, length: length, lineWidth: lineWidth)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: currentScaleLength, height: 100)
    }
}
