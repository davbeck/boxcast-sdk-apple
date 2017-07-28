//
//  Formatters.swift
//  BoxCast
//
//  Created by Camden Fullmer on 7/28/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation

public class BoxCastDateFormatter : DateFormatter {
    // Sample date string from server: 2013-04-28T23:00:00Z
    let format = "YYYY-MM-dd'T'HH:mm:ss'Z'"
    
    public override init() {
        super.init()
        self.timeZone = TimeZone(identifier: "UTC")
        self.dateFormat = format
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}

let _BoxCastDateFormatter = BoxCastDateFormatter()
