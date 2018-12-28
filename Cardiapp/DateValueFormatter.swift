//
//  DateValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
   
    
    override init() {
        super.init()
        //dateFormatter.dateFormat = "dd MMM HH:mm"
        dateFormatter.dateFormat = "h:mm a"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
       //new
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        //
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
