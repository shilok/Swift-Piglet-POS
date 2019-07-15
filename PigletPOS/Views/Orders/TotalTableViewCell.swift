//
//  TotalTableViewCell.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 09/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class TotalTableViewCell: UITableViewCell {

    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var allTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
