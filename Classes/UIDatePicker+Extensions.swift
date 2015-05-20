//
//  UIDatePicker+Helpers.swift
//  AVBForm
//
//  Created by Avner on 5/10/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

struct DateOptions {
    var datePickerMode: UIDatePickerMode // default is UIDatePickerModeDateAndTime
    var locale: NSLocale? // default is [NSLocale currentLocale]. setting nil returns to default
    var calendar: NSCalendar!
    var timeZone: NSTimeZone? // default is nil. use current time zone or time zone from calendar
    var date: NSDate? // default is current date when picker created. Ignored in countdown timer mode. for that mode, picker starts at 0:00
    var minimumDate: NSDate? // specify min/max date range. default is nil. When min > max, the values are ignored. Ignored in countdown timer mode
    var maximumDate: NSDate? // default is nil
    static func new() -> DateOptions {
        return DateOptions(datePickerMode : UIDatePickerMode.DateAndTime,locale : nil,calendar : nil, timeZone : nil, date : nil,minimumDate : nil,maximumDate : nil)
    }
}

extension UIDatePicker {
    var dateOptions : DateOptions {
        set(newValue) {
            self.datePickerMode = newValue.datePickerMode
            self.locale = newValue.locale
            self.calendar = newValue.calendar
            self.timeZone = newValue.timeZone
            self.date = newValue.date ?? NSDate.new()
            self.minimumDate = newValue.minimumDate
            self.maximumDate = newValue.maximumDate
        }
        get {
            return DateOptions(datePickerMode: self.datePickerMode, locale: self.locale, calendar: self.calendar, timeZone: self.timeZone, date: self.date, minimumDate: self.minimumDate, maximumDate: self.maximumDate)
        }
    }
}