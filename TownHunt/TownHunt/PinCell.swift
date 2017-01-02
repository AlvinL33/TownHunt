//
//  PinCell.swift
//  TownHunt
//
//  Created by iD Student on 8/3/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import UIKit

class PinCell: UITableViewCell {
    @IBOutlet weak var codewordLabel: UILabel!
    @IBOutlet weak var pointValLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
