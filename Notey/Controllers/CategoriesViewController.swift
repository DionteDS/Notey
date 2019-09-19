//
//  ViewController.swift
//  Notey
//
//  Created by Dionte Silmon on 9/19/19.
//  Copyright © 2019 Dionte Silmon. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesViewController: SwipeCellViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
    }
    
    // If the categories array is not nil return the count else return 1
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //Populate the cells data
        if let category = categories?[indexPath.row] {
            
            // Grab the color for the categories background color
            guard let categoryColor = UIColor(hexString: category.color) else {
                fatalError()
            }
            
            cell.textLabel?.text = category.name
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - Delete Category
    
    // Allows the user to delete a category from the tableView cell
    override func updateUI(at indexPath: IndexPath) {
        
        if let categoryForDeletion = categories?[indexPath.row] {
            super.updateUI(at: indexPath)
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
            
        }
        
    }
    
    //MARK: - Save Categories
    
    // This method saves the categories into the database.
    func saveCategories(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - Load Categories
    
    // This method loads the categories from the database.
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
    
    
    //MARK: - Add category button
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a category", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (alertText) in
            alertText.placeholder = "Enter a category"
            textField = alertText
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.saveCategories(category: newCategory)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

