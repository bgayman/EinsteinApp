//
//  EinsteinTableViewCell.swift
//  FaceDetect
//
//  Created by B Gay on 8/9/17.
//  Copyright © 2017 Simon Gladman. All rights reserved.
//

import UIKit

class EinsteinTableViewCell: UITableViewCell
{
    @IBOutlet weak var einsteinImageView: UIImageView!
    
    var einstein: Einstein?
    {
        didSet
        {
            einsteinImageView.image = einstein?.image
        }
    }

}
