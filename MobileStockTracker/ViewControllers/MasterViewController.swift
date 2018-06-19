//
//  MasterViewController.swift
//  MobileStockTracker
//
//  Created by Mohamed Sobhi  Fouda on 6/13/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import CoreData
import FrostedSidebar

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, NewItemDelegate {
  
    func newItemViewDidCancel(_ controller: NewItemViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func newItemView(_ controller: NewItemViewController, didFinishAdding item: Item) {
        save()
        dismiss(animated: true, completion: nil)
    }
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let rowHeight: CGFloat = 55
    
    var frostedSidebar: FrostedSidebar = FrostedSidebar(itemImages:  [
        UIImage(named: "star")!,
        UIImage(named: "profile")!,
        UIImage(named: "globe")!,
        UIImage(named: "gear")!], colors: nil , selectionStyle: .single)

    
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.rowHeight = rowHeight
        
        let burgerbutton = UIBarButtonItem(image: UIImage(named: "burger"), style: .plain, target: self, action: #selector(onBurger(_:)))
        navigationItem.leftBarButtonItems = [burgerbutton,editButtonItem]
        
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // burger sidebar
        handleBurger()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Buttons
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "AddItem")
//
//        viewController.modalPresentationStyle = .popover
//        let popover: UIPopoverPresentationController = viewController.popoverPresentationController!
//        popover.barButtonItem = sender as? UIBarButtonItem
//        popover.delegate = self as? UIPopoverPresentationControllerDelegate
//        present(viewController, animated: true, completion:nil)
//
        let context = self.fetchedResultsController.managedObjectContext
        let newItem = Item(context: context)

        // Alert
        var nameInput = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            newItem.name = nameInput.text!
            newItem.checked = false
            newItem.timestamp = Date()
            self.save()
        }

        alert.addAction(action)
        alert.addTextField { (field) in
            nameInput = field
            nameInput.placeholder = "Add name for new item"
        }

        present(alert, animated: true)
        // END ALert

        
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newItem = Item(context: context)
        
        // Alert
        var nameInput = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            newItem.name = nameInput.text!
            newItem.checked = false
            newItem.timestamp = Date()
            self.save()
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            nameInput = field
            nameInput.placeholder = "Add name for new item"
        }
        
        present(alert, animated: true)
        // END ALert

    }

    // When BugerSideBar button Tapped
    @objc
    func onBurger(_ sender: Any){
        
        frostedSidebar.showInViewController(self, animated: true)
        
    }
    
    // HandleBurger Actions
    func handleBurger(){
        
        frostedSidebar.adjustForNavigationBar = true
        
        frostedSidebar.actionForIndex = [
            0: {self.frostedSidebar.dismissAnimated(true, completion: { finished in self.insertNewObject((Any).self)}) },
            1: {self.frostedSidebar.dismissAnimated(true, completion: { finished in self.insertNewObject((Any).self)}) },
            2: {self.frostedSidebar.dismissAnimated(true, completion: { finished in self.insertNewObject((Any).self)}) },
            3: {self.frostedSidebar.dismissAnimated(true, completion: { finished in self.insertNewObject((Any).self)}) }]
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        
        } else if segue.identifier == "AddItem" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! NewItemViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            
        } 
    }

    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withitem: item)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withitem item: Item) {
        let HeadLabel = cell.viewWithTag(1000) as! UILabel
        let DateLabel = cell.viewWithTag(2000) as! UILabel
        HeadLabel.text = item.name
        DateLabel.text = item.timestamp?.description
        cell.accessoryType = .disclosureIndicator
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Item> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Item>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withitem: anObject as! Item)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withitem: anObject as! Item)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */
    
    // Save the context.
    func save(){
        do {
            try managedObjectContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }


}

