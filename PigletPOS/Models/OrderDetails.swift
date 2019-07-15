//
//  OrderDetails.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 02/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit


class OrderDetails: Codable{
    var orderID: Int?
    var productID: Int?
    var inventoryID: Int?
    var statusID: Int?
    var quantity: Int?
    var price: Double?
    var discount: Double?
   
    
    init(orderID: Int?, productID: Int?, inventoryID: Int?, statusID: Int?,
         quantity: Int?, price: Double?, discount: Double?){

        self.orderID = orderID
        self.productID = productID
        self.inventoryID = inventoryID
        self.statusID = statusID
        self.quantity = quantity
        self.price = price
        self.discount = discount
    }


}




