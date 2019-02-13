//
//  ListViewController.swift
//  HomeAway Coding Challenge
//
//  Created by Oleksii Maidanyk on 2/11/19.
//  Copyright © 2019 SoftServe. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
   
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var activityTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityHeightConstraint: NSLayoutConstraint!
    
    var events = [Event]()
    
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupActivityIndicatorView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        displayStoredEventsIfNeeded()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard var destination = segue.destination as? EventViewer,
              let indexPath = tableView.indexPathForSelectedRow
        else { return }
        
        destination.event = events[indexPath.row]
    }
    
    // MARK: setup
    
    func displayStoredEventsIfNeeded() {
        guard let storage: Storage = Services.shared.getService() else { return }
        if let searchText = searchBar.text, searchText.isEmpty {
            events = storage.savedEvents
            reloadData()
        }
    }
    
    func setupSearchBar() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.mainThemeLight

        //disable black border line on the top of bar
        searchBar.backgroundImage = UIImage()
    }
    
    func setupActivityIndicatorView() {
        activityIndicator.type = NVActivityIndicatorType.ballBeat
        hideActivityIndicator()
    }
    
    func updateEmptyView() {
        if let searchText = searchBar.text, searchText.isEmpty {
            emptyLabel.text = "Start typing to search events".localized
        } else {
            emptyLabel.text = "No matching events".localized
        }
        emptyView.isHidden = !events.isEmpty
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: private methods
    private func handleSearchResult(_ result: RequestResult<[Event]>) {
        hideActivityIndicator()
        switch result {
        case .success(let events):
            self.events = events
            reloadData()
        case .failure(let error):
            UIAlertController.show(error: error)
            events = []
        }
        reloadData()
    }

    private func reloadData() {
        tableView.reloadData()
        updateEmptyView()
    }
    
    private func showActivityIndicator() {
        activityIndicator.startAnimating()
        activityTopConstraint.constant = 0
        UIView.animate(withDuration: Constants.animationInterval.rawValue) { [weak self] in
            self?.view.layoutSubviews()
        }
    }
    
    private func hideActivityIndicator() {
        activityTopConstraint.constant = -activityHeightConstraint.constant
        UIView.animate(withDuration: Constants.animationInterval.rawValue, animations: { [weak self] in
            self?.view.layoutSubviews()
        }, completion: { [weak self] (_) in
            self?.activityIndicator.stopAnimating()
        })
    }
    
    private func displaySearchInProgress() {
        showActivityIndicator()
        emptyLabel.text = "Searching...".localized
    }
}

// MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let searchEngine: SearchEngine = Services.shared.getService() else { return }
        searchEngine.cancelSearch()
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchEngine: SearchEngine = Services.shared.getService() else { return }
        if searchText.isEmpty {
            hideActivityIndicator()
            searchEngine.cancelSearch()
            displayStoredEventsIfNeeded()
        } else {
            displaySearchInProgress()
            searchEngine.search(for: searchText) { [weak self] (searchResult) in
                self?.handleSearchResult(searchResult)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as? ResultCell else {
            return UITableViewCell()
        }
        
        let event = events[indexPath.row]
        
        cell.contentTitleLabel.text = event.shortTitle
        cell.contentDescriptionLabel.text = event.placeDescription
        cell.contentDateLabel.text = event.dateDescription
        cell.favouriteIcon.isHidden = !event.isFavourite
        cell.hideSpinner()
        
        if let image = event.image {
            cell.contentImageView.image = image
        } else {
            cell.showSpinner()
            // load image if it's not loaded yet
            event.loadImage { [weak self] (image, _) in
                // reload exact cell if it's visible
                let isVisible = self?.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false
                if image != nil && isVisible {
                    self?.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueID.showDetailFromList.rawValue, sender: self)
    }
}
