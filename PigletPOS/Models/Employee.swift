//
//  Employee.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 13/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class Employee : Codable{
    var id: Int
    var firstName:String
    var lastName:String
    var email:String
    var birthday:String
    var hireDate:String
    var salaryTypeID:Int
    var commissionTypeID:Int
    var country:String
    var state:String
    var city:String
    var street:String
    var line1:String
    var line2:String?
    var image:String
    var notes:String?
    var hash:String?
}
