//
//  ProductTableViewCell.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 09/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addBtn.layer.cornerRadius = addBtn.frame.height/2
        minusBtn.layer.cornerRadius = minusBtn.frame.height/2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
