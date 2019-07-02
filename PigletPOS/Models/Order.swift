//
//  Order.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 02/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit


class Order : Codable{
    var id: Int?
    var customerID: Int?
    var employeeID: Int?
    var statusID: Int?
    var paymentTypeID: Int?
    var shipperID: Int?
    var shipAddressID: Int?
    var taxRate: Double?
    var shippingPrice: Double?
    var notes: String?
    var trackingNumber: String?
}
