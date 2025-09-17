//
//  Date+Formatting.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import UIKit

extension Date {
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfNow = calendar.startOfDay(for: now)
        let dayDifference = calendar.dateComponents([.day], from: startOfSelf, to: startOfNow).day ?? 0
        
        // Special case for "Yesterday"
        if dayDifference == 1 {
            return "Yesterday"
        }
        
        // For other cases, use RelativeDateTimeFormatter
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let result = formatter.localizedString(for: self, relativeTo: now)
        
        return result
    }
}
