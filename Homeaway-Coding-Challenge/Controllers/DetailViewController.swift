//
//  DetailViewController.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/12/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol EventViewer {
    var event: Event? { get set }
}

class DetailViewController: UIViewController, EventViewer {
    var event: Event? {
        didSet {
            setup()
        }
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: NVActivityIndicatorView!
    
    // MARK: view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: setup
    
    private func setup() {
        guard let source = event, isViewLoaded else { return }
        favouriteButton.isSelected = source.isFavourite
        titleLabel.text = source.title
        dateLabel.text = source.dateDescription
        placeLabel.text = source.placeDescription
        
        if let image = source.image {
            imageView.image = image
        } else {
            showSpinner()
            // load image if it's not loaded yet
            source.loadImage { [weak self] (image, _) in
                self?.hideSpinner()
                if image != nil {
                    self?.imageView.image = image
                } else {
                    self?.imageView.image = UIImage(named: "noImage")
                }
            }
        }
    }
    
    // MARK: private methods
    
    private func showSpinner() {
        spinner.startAnimating()
        spinner.isHidden = false
    }
    
    private func hideSpinner() {
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
    // MARK: IBActions
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func favouriteButtonAction(_ sender: Any) {
        guard var source = event,
              let storage: Storage = Services.shared.getService()
            else {
                return
        }
        
        favouriteButton.isSelected = !favouriteButton.isSelected
        source.isFavourite = favouriteButton.isSelected
        
        if source.isFavourite {
            storage.save(event: source)
        } else {
            storage.delete(event: source)
        }
    }
    
}
