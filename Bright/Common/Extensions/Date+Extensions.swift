//
//  Date+Extensions.swift
//  Bright
//
//  Created by Martin Lukacs on 29/11/2021.
//

import Foundation

extension Date {
    func toString(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}
