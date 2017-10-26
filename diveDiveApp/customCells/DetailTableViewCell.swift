//
//  CustomTableViewCell.swift
//  diveDiveApp
//
//  Created by Michiel Everts on 24-10-17.
//  Copyright © 2017 Michiel Everts. All rights reserved.
//

import UIKit

class DetailViewCell: UITableViewCell {

    @IBOutlet weak var diveImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UITextField!
    
    @IBOutlet weak var oceanLabel: UITextField!
    
    @IBOutlet weak var experienceReqLabel: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
