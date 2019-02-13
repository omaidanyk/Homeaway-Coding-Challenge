//
//  ResultCell.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/11/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ResultCell: UITableViewCell {
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var contentDescriptionLabel: UILabel!
    @IBOutlet weak var contentDateLabel: UILabel!
    @IBOutlet weak var spinner: NVActivityIndicatorView!
    @IBOutlet weak var favouriteIcon: UIImageView!
    
    func showSpinner() {
        spinner.startAnimating()
        spinner.isHidden = false
    }
    
    func hideSpinner() {
        spinner.isHidden = true
        spinner.stopAnimating()
    }
    
    override func prepareForReuse() {
        hideSpinner()
        contentImageView.image = nil
        contentTitleLabel.text = nil
        contentDescriptionLabel.text = nil
        contentDateLabel.text = nil
        favouriteIcon.isHidden = true
    }
}
