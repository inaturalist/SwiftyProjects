//
//  UserCountCell.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/30/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Haneke

class UserCountCell: UITableViewCell {
    @IBOutlet var userImageView: UIImageView?
    @IBOutlet var userLoginLabel: UILabel?
    @IBOutlet var observationCountLabel: UILabel?
    @IBOutlet var speciesCountLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userLoginLabel?.text = ""
        self.observationCountLabel?.text = ""
        self.speciesCountLabel?.text = ""
        
        self.userImageView?.layer.cornerRadius = 44.0 / 2
        self.userImageView?.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.userImageView?.layer.borderWidth = 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.userImageView?.image = nil
        self.userImageView?.hnk_cancelSetImage()
        
        self.userLoginLabel?.text = ""
        self.observationCountLabel?.text = ""
        self.speciesCountLabel?.text = ""
    }

}
