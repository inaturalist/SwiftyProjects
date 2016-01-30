//
//  TaxonCountCell.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Haneke

class TaxonCountCell: UITableViewCell {
    @IBOutlet var taxonImageView: UIImageView?
    @IBOutlet var taxonMainNameLabel: UILabel?
    @IBOutlet var taxonSecondaryNameLabel: UILabel?
    @IBOutlet var countLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.taxonImageView?.layer.cornerRadius = 2.0
        self.taxonImageView?.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.taxonImageView?.layer.borderWidth = 0.5

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.taxonImageView?.image = nil
        self.taxonImageView?.hnk_cancelSetImage()
        
        self.taxonMainNameLabel?.text = ""
        if let pointSize = self.taxonMainNameLabel?.font.pointSize {
            self.taxonMainNameLabel?.font = UIFont.systemFontOfSize(pointSize)
        }
        
        self.taxonSecondaryNameLabel?.text = ""
        if let pointSize = self.taxonSecondaryNameLabel?.font.pointSize {
            self.taxonSecondaryNameLabel?.font = UIFont.systemFontOfSize(pointSize)
        }

        self.countLabel?.text = ""
    }

}
