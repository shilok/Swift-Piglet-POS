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
    var description:String?
    var minPrice: Double
    var displayPrice: Double
    var quantity: Int
    var stockID: Int
    var imagesURL: [String]?
    var tags: [String]?
    

    
    
    
    
    init(productID: Int,
         name:String, description:String, minPrice: Double, displayPrice: Double,
         quantity: Int, stockID: Int, imagesURL: [String]?, tags: [String]?) {
        
        self.productID = productID
        self.name = name
        self.description = description
        self.minPrice = minPrice
        self.displayPrice = displayPrice
        self.quantity = quantity
        self.stockID = stockID
        self.imagesURL = imagesURL
        self.tags = tags
        
    }
    
     public var descriptions:String{
        return "Product - ID: \(productID) Name: \(name), Description: \(description) \nImages: \(imagesURL)\nTags: \(tags)"
    }
    
    
    
}



