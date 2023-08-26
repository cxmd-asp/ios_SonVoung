//
//  Date+Extension.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/25/23.
//

import Foundation

extension Date {
    func toString(_ format: DateFormat) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }

    func toUTC() -> Date {
        let value = -TimeInterval(TimeZone.current.secondsFromGMT(for: self))
        return Date(timeInterval: value, since: self)
    }

    func toLocal() -> Date {
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let value = (timeIntervalSince1970 + Double(secondsFromGMT))
        return Date(timeIntervalSince1970: value)
    }

    func toAge() -> Int? {
        let calendar = Calendar(identifier: .gregorian)
        let ageComponents = calendar.dateComponents([.year], from: self, to: Date())
        return ageComponents.year
    }

    func toElapsedTime() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let interval = calendar
            .dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        if let value = interval.year, value > 0 {
            return value <= 1 ? String(format: "%ld year ago", value) : String(format: "%ld years ago", value)
        } else if let value = interval.month, value > 0 {
            return value <= 1 ? String(format: "%ld month ago", value) : String(format: "%ld months ago", value)
        } else if let value = interval.day, value > 0 {
            return value <= 1 ? String(format: "%ld day ago", value) : String(format: "%ld days ago", value)
        } else if let value = interval.hour, value > 0 {
            return value <= 1 ? String(format: "%ld hour ago", value) : String(format: "%ld hours ago", value)
        } else if let value = interval.minute, value > 0 {
            return value <= 1 ? String(format: "%ld minute ago", value) : String(format: "%ld minutes ago", value)
        } else if let value = interval.second, value > 0 {
            return value <= 1 ? String(format: "%ld second ago", value) : String(format: "%ld seconds ago", value)
        } else {
            return "just now"
        }
    }
}
