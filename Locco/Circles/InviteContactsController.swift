//
//  InviteContacts.swift
//  Locco
//
//  Created by macmini-stajyer-2 on 3.09.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Contacts

class InviteContactsController: UITableViewController {
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    var contacts = [ContactStruct]()
    var contactStore = CNContactStore()
    
    var contactsWithSections = [[ContactStruct]]()
    let collation = UILocalizedIndexedCollation.current()
    var sectionTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Search Controller
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search"
        self.searchController.searchBar.barStyle = .default
        self.searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        contactStore.requestAccess(for: .contacts) { (success, error) in
            if success {
                self.fetchContacts()
            }
        }
    }
    
    func fetchContacts() {
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataAvailableKey, CNContactImageDataKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        request.sortOrder = CNContactSortOrder.userDefault
        
        try! contactStore.enumerateContacts(with: request) { (contact, stoppingPointer) in
            let firstName = contact.givenName
            let lastName = contact.familyName
            var number = contact.phoneNumbers.first?.value.stringValue
            var image = UIImage(named: "contact")?.withRenderingMode(.alwaysTemplate)
            
            if contact.imageDataAvailable {
                image = UIImage(data: contact.imageData!)?.withRenderingMode(.alwaysOriginal)
            }
            
            if number == nil {
                number = ""
            }
            
            let contactToAppend = ContactStruct(firstName: firstName, lastName: lastName, number: number!, profileImage: image!)
            
            self.contacts.append(contactToAppend)
        }
        self.setUpCollation()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    
    @objc func setUpCollation(){
        let (arrayContacts, arrayTitles) = collation.partitionObjects(array: self.contacts as [AnyObject], collationStringSelector: #selector(getter: ContactStruct.firstName))
        self.contactsWithSections = arrayContacts as! [[ContactStruct]]
        self.sectionTitles = arrayTitles
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return contactsWithSections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactCell
        else {
            return UITableViewCell()
        }
        
        let contactToDisplay = contactsWithSections[indexPath.section][indexPath.row]
        cell.configure(contactImage: contactToDisplay.profileImage, contactName: contactToDisplay.firstName + " " + contactToDisplay.lastName, contactNumber: contactToDisplay.number)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as? ContactCell)?.selectionIndicator.image = UIImage(named: "Select")
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as? ContactCell)?.selectionIndicator.image = UIImage(named: "Reveal")
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
    }
}

extension InviteContactsController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Filter function
//        self.filterFunction(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        
        guard let term = searchBar.text , term.isEmpty == false else {
            
            //Notification "White spaces are not permitted"
            return
        }
        
        //Filter function
//        self.filterFunction(searchText: term)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        
        //Filter function
//        self.filterFunction(searchText: searchBar.text)
    }
}

extension UILocalizedIndexedCollation {
    //func for partition array in sections
    func partitionObjects(array:[AnyObject], collationStringSelector:Selector) -> ([AnyObject], [String]) {
        var unsortedSections = [[AnyObject]]()
        
        //1. Create a array to hold the data for each section
        for _ in self.sectionTitles {
            unsortedSections.append([]) //appending an empty array
        }
        //2. Put each objects into a section
        for item in array {
            let index:Int = self.section(for: item, collationStringSelector:collationStringSelector)
            unsortedSections[index].append(item)
        }
        //3. sorting the array of each sections
        var sectionTitles = [String]()
        var sections = [AnyObject]()
        for index in 0 ..< unsortedSections.count { if unsortedSections[index].count > 0 {
            sectionTitles.append(self.sectionTitles[index])
            sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
            }
        }
        return (sections, sectionTitles)
    }
}

class ContactCell: UITableViewCell {
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var selectionIndicator: UIImageView!
    
    func configure(contactImage: UIImage, contactName: String, contactNumber: String) {
        self.contactImage.image = contactImage
        self.contactImage.tintColor = UIColor(red: 152/255, green: 152/255, blue: 157/255, alpha: 1.0)
        self.contactName.text = contactName
        self.contactNumber.text = contactNumber
    }
    
    override func prepareForReuse() {
        selectionIndicator.image = UIImage(named: "Reveal")
    }
}

class SelectedContactCell: UICollectionViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var removeContact: UIButton!
    
    func configure(profileImage: UIImage, username: String) {
        self.profileImage.image = profileImage
        self.profileImage.tintColor = UIColor(red: 152/255, green: 152/255, blue: 157/255, alpha: 1.0)
        self.username.text = username
    }
}

@objc class ContactStruct: NSObject {
    @objc let firstName: String
    @objc let lastName: String
    @objc let number: String
    @objc let profileImage: UIImage
    
    init(firstName: String, lastName: String, number: String, profileImage: UIImage) {
        self.firstName = firstName
        self.lastName = lastName
        self.number = number
        self.profileImage = profileImage
    }
}
