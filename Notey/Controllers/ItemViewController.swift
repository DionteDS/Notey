//
//  ItemViewController.swift
//  Notey
//
//  Created by Dionte Silmon on 9/20/19.
//  Copyright © 2019 Dionte Silmon. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemViewController: SwipeCellViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let realm = try! Realm()
    
    // Variable to hold the items in the database
    var itemArray : Results<Item>?
    
    // Variable to hold the current category that was segue in
    var selectCategory : Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectCategory?.name
        
        guard let colorHex = selectCategory?.color else {
            fatalError()
        }
        
        updateNavBar(withColorCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withColorCode: "F7FFAE")
    }
    
    
    //MARK: - Nav bar set up methods
    
    /*
     Set up the navgation bar
     Set up the navgation bar color
     Set the large title text color
     Set the colors for the nav barTintColor, tintColor, and search bar tint color
     */
    func updateNavBar(withColorCode colorHexCode: String) {
        
        // Create the nav bar
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {
            fatalError()
        }
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.tintColor = navBarColor
        
    }
    
    //MARK: - If itemArray is not nil return its count else return 1
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
         Set up the cell text.
         Set up the cell background color
         Check the done status to either add a checkmark or not
        */
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            
            // Set up the color for each cell and text
            if let color = UIColor(hexString: selectCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added."
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If user taps a cell it will change the status of the done property.
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error with done status, \(error)")
            }
            
            tableView.reloadData()
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    //MARK: - Delete Item
    
    // Allows the user to delete a item from the tableView cell
    
    override func updateUI(at indexPath: IndexPath) {
        
        if let itemForDeletion = itemArray?[indexPath.row] {
            super.updateUI(at: indexPath)
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
        
    }
    
    //MARK: - Load the item data from the database
    
    func loadItems() {
        
        itemArray = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        
    }
    
    
    
    //MARK: - Add button for items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a item", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (alertText) in
            alertText.placeholder = "Enter a item."
            textField = alertText
        }
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // what will happen once the user clicks the Add Item Button on our UIAlert
            
            // Create new item
            if let currentCategory = self.selectCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving item.")
                }
                
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


//MARK: - Search bar methods

extension ItemViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If the user taps on the x in the search bar then load the data
        // returning the original list
        if searchBar.text?.count == 0 {
            loadItems()
            
            // Have the keyboard dismiss in the background thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
}
