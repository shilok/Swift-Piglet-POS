//
//  CustomerTableViewCell.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 09/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class CustomerTableViewCell: UITableViewCell {
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var street: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var zipCode: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        frame = CGRect(x: 0, y: 0, width: 400, height: 500)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
