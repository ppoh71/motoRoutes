//
//  NSDateExtension.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 18.08.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//


/* 
 
 http://stackoverflow.com/questions/28489227/swift-ios-dates-and-times-in-different-format
  Usage:

  let stringFromDate = NSDate().customFormatted   // "14/7/2016, 2:00"

  if let date = stringFromDate.asDate {  // "Jul 14, 2016, 2:00 AM"
    print(date)                        // "2016-07-14 05:00:00 +0000\n"
    date.customFormatted               // "14/7/2016, 2:00"
  }
 "14/7/2016".asDateFormatted(with: "dd/MM/yyyy")  // "Jul 14, 2016, 12:00 AM"

 */


import Foundation

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}

extension Date {
    
    struct Formatter {
        static let customDE = DateFormatter(dateFormat: "d MMM y | H:mm")
        static let customEN = DateFormatter(dateFormat: "MMM d y | H:mm")
    }
    
    var customFormatted: String {
        
        let pre = Locale.preferredLanguages[0]
        
        var returnDate: String
        
        if(pre != "de-DE"){
            returnDate =  Formatter.customEN.string(from: self)
        } else {
            returnDate =  Formatter.customDE.string(from: self)
        }
        return returnDate
    }
}

/*
extension String {
    var asDate: NSDate? {
        return NSDate.Formatter.customEN.dateFromString(self)
    }
    func asDateFormatted(with dateFormat: String) -> NSDate? {
        return NSDateFormatter(dateFormat: dateFormat).dateFromString(self)
    }
}*/
