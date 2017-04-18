//
//  PackListTableViewCell.swift
//  TownHunt
//
//  Created by Alvin Lee on 10/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class PackStoreListTableViewCell: UITableViewCell {

    @IBOutlet weak var packNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
