//
//  ChatController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

class ChatController: UIViewController {
    
    var viewModel: ChatViewModeling?
    var filteredData = [String:String]()
    var items = [UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll)),
                 UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                 UIBarButtonItem(title: "Delete", style: .plain, target: self, action: nil)]
    var isSearching = false
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ChatViewModel()
        self.viewModel!.controller = self
       
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.prefersLargeTitles = true
            let searchController = UISearchController(searchResultsController: nil)
            navigationItem.searchController = searchController
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        self.navigationController?.toolbar.items = items
    }
    
    func setup() {
        viewModel?.loadChatPreviews()
        tableView.loadTableData()
        viewModel!.getChatPreview(completion: { (result) in
            if result {
                self.tabBarItem.badgeValue = self.viewModel?.hasNewMessages()
                self.tableView.loadTableData()
            }
        })
    }
    
    @objc func readAll(_ sender: Any) {
        for chatPreview in (viewModel?.chatPreviews)! {
            chatPreview.hasNewMessages = false
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        edit(self)
    }
    
    // MARK: - Button Actions
    @IBAction func edit(_ sender: Any) {
        if tableView.isEditing {
            tableView.allowsSelection = true
            tableView.setEditing(false, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: true)
            self.navigationItem.leftBarButtonItem?.style = .plain
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        } else {
            tableView.allowsSelection = false
            tableView.setEditing(true, animated: true)
        
            self.navigationItem.leftBarButtonItem?.title = "Cancel"
            self.navigationItem.leftBarButtonItem?.style = .done
            self.navigationController?.setToolbarHidden(false, animated: true)
            self.navigationController?.toolbar.items = items
            items[2].isEnabled = false
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChatDetail" {
            let conversationController = segue.destination as! ConversationController
            conversationController.viewModel = viewModel
        }
    }
}

// MARK: - UITableView Delegate
extension ChatController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        }
        
        return (viewModel?.chatPreviews.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell
            else {return UITableViewCell()}
        
//        if isSearching {
//            cell.configure(pinColor: filteredData[indexPath.row].pinColor.colors, title: filteredData[indexPath.row].title!, subtitle: filteredData[indexPath.row].placeDetail)
//        } else {
//            cell.configure(pinColor: (viewModel?.geoPlaces[indexPath.row].pinColor.colors)!, title: (viewModel?.geoPlaces[indexPath.row].title)!, subtitle: (viewModel?.geoPlaces[indexPath.row].placeDetail)!)
//        }
        
        cell.configure(cellPicture: UIImage(named: "addPhoto")!, iconGradient: (viewModel?.chatPreviews[indexPath.row].circleIcon)!, title: (viewModel?.chatPreviews[indexPath.row].circleName)!, subtitle: (viewModel?.chatPreviews[indexPath.row].senderName)!, preview: (viewModel?.chatPreviews[indexPath.row].message)!, time: (viewModel?.chatPreviews[indexPath.row].timestamp)!, hasNewMessages: (viewModel?.chatPreviews[indexPath.row].hasNewMessages)!, hideAlerts: (viewModel?.chatPreviews[indexPath.row].hideAlerts)!)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            self.tabBarItem.badgeValue = nil
            tableView.deselectRow(at: indexPath, animated: true)
            viewModel?.chatPreviews[indexPath.row].hasNewMessages = false
            viewModel?.activeChatIndex = indexPath.row
            (tableView.cellForRow(at: indexPath) as! ChatCell).unreadIndicator.alpha = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.viewModel?.chatPreviews.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let hideAlerts = UITableViewRowAction(style: .normal, title: "Hide\nAlerts") { action, index in
            if (tableView.cellForRow(at: indexPath) as! ChatCell).muteImageView.isHidden {
                (tableView.cellForRow(at: indexPath) as! ChatCell).muteImageView.isHidden = false
                
                if (self.viewModel?.chatPreviews[indexPath.row].hasNewMessages)! {
                    self.tabBarItem.badgeValue = nil
                    (tableView.cellForRow(at: indexPath) as! ChatCell).unreadIndicator.alpha = 0.0
                }

                action.title = "Show\nAlerts"
            } else {
                (tableView.cellForRow(at: indexPath) as! ChatCell).muteImageView.isHidden = true
                action.title = "Hide\nAlerts"
                
                if (self.viewModel?.chatPreviews[indexPath.row].hasNewMessages)! {
                    self.tabBarItem.badgeValue = self.viewModel?.hasNewMessages()
                    (tableView.cellForRow(at: indexPath) as! ChatCell).unreadIndicator.alpha = 1.0
                }
            }
        }
        hideAlerts.backgroundColor =  UIColor(red: 90/255, green: 94/255, blue: 208/255, alpha: 1.0)
        
        return [delete, hideAlerts]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - ChatCell
class ChatCell: UITableViewCell {
    
    @IBOutlet weak var cellPicture: UIImageView!
    @IBOutlet weak var iconGradient: GradientView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unreadIndicator: RoundedView!
    @IBOutlet weak var disclosureIndicator: UIImageView!
    @IBOutlet weak var muteImageView: UIImageView!
    
    func configure(cellPicture: UIImage, iconGradient: PinColors, title: String, subtitle: String, preview: String, time: String, hasNewMessages: Bool, hideAlerts: Bool) {
        self.cellPicture.image = cellPicture
        self.iconGradient.topColor = UIColor(cgColor: iconGradient.colors.first!)
        self.iconGradient.bottomColor = UIColor(cgColor: iconGradient.colors.last!)
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.previewLabel.text = preview
        self.timeLabel.text = time
        if hasNewMessages {
            unreadIndicator.alpha = 1.0
        }
        
        if hideAlerts {
            unreadIndicator.isHidden = true
            muteImageView.isHidden = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = unreadIndicator.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if selected && !unreadIndicator.isHidden {
            unreadIndicator.backgroundColor = color
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            unreadIndicator.isHidden = true
            disclosureIndicator.isHidden = true
        } else {
            unreadIndicator.isHidden = false
            disclosureIndicator.isHidden = false
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = unreadIndicator.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted && !unreadIndicator.isHidden {
            unreadIndicator.backgroundColor = color
        }
    }
}
