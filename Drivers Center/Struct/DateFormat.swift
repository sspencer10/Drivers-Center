//
//  DateFormat.swift
//  Weather
//
//  Created by Steven Spencer on 7/23/24.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
    
    func toMMDDFormat() -> String {
        guard let date = self.toDate() else { return self }
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        let modDay = deleteLeadingZeros(inputStr: day)
        return daySuffix(date: modDay)
    }
    
    func toDayOfWeek() -> String {
        guard let date = self.toDate() else { return self }
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEE"
        let day = dateFormatter.string(from: date)
        //let modDay = deleteLeadingZeros(inputStr: day)
        return "\(day)"
    }
    
    func deleteLeadingZeros(inputStr: String) -> String {
      var resultStr = inputStr
        
      while resultStr.hasPrefix("0") && resultStr.count > 1 {
       resultStr.removeFirst()
      }
      return resultStr
    }
    
    func daySuffix(date: String) -> String {
        switch date {
        case "01", "1", "21", "31":
            return "\(date)st"
        case "02", "2", "22":
            return "\(date)nd"
        case "03", "3", "23":
            return "\(date)rd"
        default:
            return "\(date)th"
        }
    }
}
