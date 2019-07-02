//
//  String+Extension.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 02/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

extension String{
    func containCharsTwice(char: Character) -> Bool{
        var arr:[Character] = []
        for s in self { if s == char {arr.append(s)} }
        if arr.count > 1 {return true}
            return false
    }
}
