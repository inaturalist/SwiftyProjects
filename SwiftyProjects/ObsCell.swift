//
//  ObsCell.swift
//  SwiftyProjects
//
//  Created by Alex Shepard on 1/29/16.
//  Copyright © 2016 Alex Shepard. All rights reserved.
//

import UIKit
import Haneke

class ObsCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var label: UILabel?
    @IBOutlet var scrim: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label?.textColor = UIColor.whiteColor()
        scrim?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.label?.text = ""
        if let pointSize = self.label?.font.pointSize {
            self.label?.font = UIFont.systemFontOfSize(pointSize)
        }

        self.imageView?.hnk_cancelSetImage()
        self.imageView?.image = nil
    }
}
