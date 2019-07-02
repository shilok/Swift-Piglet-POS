//
//  Product.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 13/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class Product : Codable{
   var productID: Int
   var name:String
   var description:String
   var minPrice: Double
   var displayPrice: Double
   var quantity: Int
   var stockID: Int
}
