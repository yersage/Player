//
//  RecordRangeModel.swift
//  Player
//
//  Created by user on 01.11.2022.
//

import Foundation

struct RecordRangeModel {
    var startTime: String
    var endTime: String
    
    var startTimeDateComponents: DateComponents? {
        if let firstArchiveRangeStartTimeInSeconds = Double(startTime.prefix(10)) {
            let date = Date(timeIntervalSince1970: firstArchiveRangeStartTimeInSeconds)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            return dateComponents
        } else {
            return nil
        }
    }
    
    var endTimeDateComponents: DateComponents? {
        if let firstArchiveRangeStartTimeInSeconds = Double(endTime.prefix(10)) {
            let date = Date(timeIntervalSince1970: firstArchiveRangeStartTimeInSeconds)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            return dateComponents
        } else {
            return nil
        }
    }
    
    var startTimeDate: Date? {
        if let firstArchiveRangeStartTimeInSeconds = Double(startTime.prefix(10)) {
            let date = Date(timeIntervalSince1970: firstArchiveRangeStartTimeInSeconds)
            return date
        } else {
            return nil
        }
    }
    
    var endTimeDate: Date? {
        if let firstArchiveRangeStartTimeInSeconds = Double(endTime.prefix(10)) {
            let date = Date(timeIntervalSince1970: firstArchiveRangeStartTimeInSeconds)
            return date
        } else {
            return nil
        }
    }
    
    var startTimeInSeconds: Int {
        return (startTimeDateComponents!.hour! * 3600) + (startTimeDateComponents!.minute! * 60) + (startTimeDateComponents!.second!)
    }
    
    var endTimeInSeconds: Int {
        return (endTimeDateComponents!.hour! * 3600) + (endTimeDateComponents!.minute! * 60) + (endTimeDateComponents!.second!)
    }
}
