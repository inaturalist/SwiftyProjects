//
//  IdentifierCountCell.swift
//  ProjectsViewPager
//
//  Created by Alex Shepard on 2/18/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit

class IdentifierCountCell: UITableViewCell {
    @IBOutlet var userImageView: UIImageView?
    @IBOutlet var userLoginLabel: UILabel?
    @IBOutlet var identificationsCountLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userLoginLabel?.text = ""
        self.identificationsCountLabel?.text = ""
        
        self.userImageView?.layer.cornerRadius = 44.0 / 2
        self.userImageView?.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.userImageView?.layer.borderWidth = 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.userImageView?.image = nil
        self.userImageView?.hnk_cancelSetImage()
        
        self.userLoginLabel?.text = ""
        self.identificationsCountLabel?.text = ""
    }

}
