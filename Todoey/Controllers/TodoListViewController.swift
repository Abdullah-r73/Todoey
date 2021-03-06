//
//  ViewController.swift
//  Todoey
//
//  Created by floyd Grant on 2018-03-28.
//  Copyright © 2018 floyd Grant. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
             loadItems()
        }
    }
    
    
    //This creats reads update and destroys. It also commuicates with the persistent container
    let context = (UIApplication.shared.delegate as! AppDelegate) .persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //file path ware all new entries are saved in the DataCore
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist"))

    }
    //Mark - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Allows reusable cell with identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //Cut down on the the code repeating
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Equivlent to the Ternary expression
        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        
    }
    
    //Mark - TableView Delagate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        //Toggling done aatribute from true to false (check mark off & on)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveItems()
       
        
        //When you click row the highlighted area flashes
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    //Mark - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Global verible for this block
        var textField = UITextField()
        
        //What user will see when add button is pressed
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        //Action for adding item to list
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What happen when the user clicks the add  Item buuton on ou UIAlert
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        //Add textfield to alert alert message
        alert.addTextField(configurationHandler: { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        })
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manuplation Method
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems() {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil
        
        //Used to quere the the database and filter the results.
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
    
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    //This tells the delegate the search button was taped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Declare request it returns array of Items
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //Specifys how we want to query the database (exmple we are using 'title')
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //Add query to the request
        request.predicate = predicate
        
        //Sorts the query request in alphebet order using the key(titlt)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        loadItems()
        
        //Add sortDiscriptor to the request
        request.sortDescriptors = [sortDescriptor]
       
        //Run the request and fetch the results
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    //After the x-button is pressed all of the list item are returned to the list
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            tableView.reloadData()
            
            //Tells keyboard to disapear and curser to disapear as well.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

