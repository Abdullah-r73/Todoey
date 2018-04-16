//
//  ViewController.swift
//  Todoey
//
//  Created by floyd Grant on 2018-03-28.
//  Copyright © 2018 floyd Grant. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = ["Floyd", "Malachi", "Fedora"]
    
    //Create default object to save items in array after app is terminated. (user defaults #1)
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //To retrive the data to the tableView (user defaults #3)
        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
            
            itemArray = items
            
        }
        
    }
    //Mark - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        
        
        return cell
        
    }
    
    //Mark - TableView Delagate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print(itemArray[indexPath.row])
        
        //When you click row the highlighted area flashes
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Selecting and deselecting checkmark for each row
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
    
    //Mark - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What happen onc theuseclic the add  Item buuton on ou UIAlert
            
            self.itemArray.append(textField.text!)
            
            //Set the input item into a localStorage (user defaults #2)
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
        }
        
        //Add textfield to alert alert message
        alert.addTextField(configurationHandler: { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        })
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}

