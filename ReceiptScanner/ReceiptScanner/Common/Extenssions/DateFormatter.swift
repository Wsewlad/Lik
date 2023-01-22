//
//  DateFormatter.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import Foundation

extension DateFormatter {
    static var mediumStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    static var shortStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    /// Jan 15
    static var monthDayStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    /// Jan 15, 21
    static var monthDayYearStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    /// Jan 15, 2021, 22:00
    static var monthDayYearTimeStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy, HH:mm ss"
        return formatter
    }()
    
    /// 6  August 2021
    static var dayMonthYearStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    /// Jan 15, 2021  22:00
    static var monthDayYearTimeStyleNoComa: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy   HH:mm"
        return formatter
    }()

    /// Tue, 6 Apr - 15:47 - GMT
    static var notificationStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM — HH:mm — ZZZZ"
        return formatter
    }()

    /// January 15, 2021
    static var fullMonthWithYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    /// 8:27 am
    static var noteTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
}

