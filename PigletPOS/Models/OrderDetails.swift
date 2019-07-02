//
//  OrderDetails.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 02/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit


class OrderDetails : Codable{
    var orderID: Int?
    var productID: Int?
    var inventoryID: Int?
    var statusID: Int?
    var quantity: Int?
    var price: Double?
    var discount: Double?
    var product: Product
}
