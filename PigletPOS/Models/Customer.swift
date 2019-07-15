//
//  Customer.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 02/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class Customer : Codable{
    var id: Int?
    var firstName: String?
    var lastName: String?
    var defaultAddressID: Int?
    var emails: [String]?
    var phones:[String]?
    var addresses:[Address]?
    
    
    
}

struct CustomerSource: Codable {
    var customers: [Customer]
}

class Phone: Codable {
    var number: String
}
