//
//  String+Extension.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/25/23.
//

import Foundation

extension String {
    func toDate(_ format: DateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale.current
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            let iso8601DateFormatter = ISO8601DateFormatter()
            switch format {
            case .iso8601:
                iso8601DateFormatter.formatOptions = [
                    .withInternetDateTime,
                    .withFractionalSeconds,
                ]
            case .standard:
                iso8601DateFormatter.formatOptions = [
                    .withInternetDateTime,
                ]
            default:
                break
            }
            return iso8601DateFormatter.date(from: self)
        }
    }
}
