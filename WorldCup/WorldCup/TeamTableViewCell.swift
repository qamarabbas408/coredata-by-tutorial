//
//  TeamTableViewCell.swift
//  WorldCup
//
//  Created by Siliconplex on 25/10/2024.
//

import UIKit

class TeamTableViewCell: UITableViewCell {

    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()

        teamLabel.text = nil
        scoreLabel.text = nil
        flagImageView.image = nil
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
