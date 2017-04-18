//
//  LeaderboardRecordTableViewCell.swift
//  TownHunt
//
//  Created by Alvin Lee on 09/04/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import UIKit

class LeaderboardRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var pointsScoreLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
