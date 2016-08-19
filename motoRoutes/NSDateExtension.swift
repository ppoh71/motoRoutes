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

extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}

extension NSDate {
    
    struct Formatter {
        static let customDE = NSDateFormatter(dateFormat: "d.m.yyyy, H:mm")
        static let customEN = NSDateFormatter(dateFormat: "m/d/yyyy, H:mm")
    }
    
    var customFormatted: String {
        
        let pre = NSLocale.preferredLanguages()[0]
        
        var returnDate: String
        
        if(pre != "de-DE"){
            returnDate =  Formatter.customEN.stringFromDate(self)
        } else {
            returnDate =  Formatter.customDE.stringFromDate(self)
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