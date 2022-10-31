//
//  LeaderboardCell.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/6/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {

    @IBOutlet var RankLabel: UILabel!
    @IBOutlet var NameLabel: UILabel!
    @IBOutlet var ScoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
