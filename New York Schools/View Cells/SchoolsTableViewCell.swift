//
//  SchoolsTableViewCell.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import UIKit

//Table view cell used to show school names on AllSchoolsViewController
//NOTE: Could use a basic table view cell and not need a custom class for this, but was planning on adding more to the cell than just the name label originally 

class SchoolsTableViewCell: UITableViewCell {

    @IBOutlet weak var schoolNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
