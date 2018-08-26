//
//  ChatController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import SwipeCellKit

class ChatController: UIViewController {
    
    var viewModel: ChatViewModeling?
    var filteredData = [String:String]()
    var isSearching = false
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ChatViewModel()
        self.viewModel!.controller = self
        
        if #available(iOS 11.0, *) {
            let searchController = UISearchController(searchResultsController: nil)
            navigationItem.searchController = searchController
        }
        navigationController!.view.backgroundColor = UIColor(red: 237/255, green: 236/255, blue: 242/255, alpha: 1.0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

// MARK: - UITableView Delegate
extension ChatController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell
            else {return UITableViewCell()}
        
//        if isSearching {
//            cell.configure(pinColor: filteredData[indexPath.row].pinColor.colors, title: filteredData[indexPath.row].title!, subtitle: filteredData[indexPath.row].placeDetail)
//        } else {
//            cell.configure(pinColor: (viewModel?.geoPlaces[indexPath.row].pinColor.colors)!, title: (viewModel?.geoPlaces[indexPath.row].title)!, subtitle: (viewModel?.geoPlaces[indexPath.row].placeDetail)!)
//        }
        
        cell.delegate = self as SwipeTableViewCellDelegate
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
    }
}

// MARK: - SwipeTableViewCell Delegate
extension ChatController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let silenceAction = SwipeAction(style: .default, title: "Hide Alerts") { action, indexPath in
            action.backgroundColor = UIColor(red: 89/255, green: 95/255, blue: 208/255, alpha: 1.0)
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            self.viewModel?.remove(geotification: (self.viewModel?.geoPlaces[indexPath.row])!)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
        return [silenceAction, deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}

// MARK: - ChatCell
class ChatCell: SwipeTableViewCell {
    
    @IBOutlet weak var cellPicture: RoundedImage!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var unreadMessageCount: UILabel!
    
    func configure(cellPicture: UIImage, title: String, subtitle: String, preview: String, unreadCount: String) {
        self.cellPicture.image = cellPicture
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.previewLabel.text = preview
        self.unreadMessageCount.text = unreadCount
    }
}
