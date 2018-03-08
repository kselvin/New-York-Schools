//
//  SchoolsTableViewCell.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import UIKit

class SchoolsTableViewCell: UITableViewCell {

    @IBOutlet weak var schoolNameLabel: UILabel!
    
    var row: Int?
    var section: Int? 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
