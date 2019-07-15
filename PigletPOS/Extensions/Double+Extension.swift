//
//  Double+Extension.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 02/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import Foundation

extension Double {
    func roundToDec(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
