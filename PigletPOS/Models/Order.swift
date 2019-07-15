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
    var employeeID: Int
    var statusID: Int?
    var paymentTypeID: Int?
    var shipperID: Int?
    var shipAddressID: Int?
    var taxRate: Double?
    var shippingPrice: Double?
    var notes: String?
    var trackingNumber: String?
    var createdDate: Date?
    var modifiedDate: Date?
    
    init(id: Int?, customerID: Int?, employeeID: Int, statusID: Int?,
         paymentTypeID: Int?, shipperID: Int?, shipAddressID: Int?,
         taxRate: Double?, shippingPrice: Double?, notes: String?,
         trackingNumber: String?, modifiedDate: Date?) {
        self.id = id
        self.customerID = customerID
        self.employeeID = employeeID
        self.statusID = statusID
        self.paymentTypeID = paymentTypeID
        self.shipperID = shipperID
        self.shipAddressID = shipAddressID
        self.shippingPrice = shippingPrice
        self.notes = notes
        self.trackingNumber = trackingNumber
        self.modifiedDate = modifiedDate
    }
    
    
}

enum OrderStatus: Int{
    case open = 1, close, aborted, layaway
}


