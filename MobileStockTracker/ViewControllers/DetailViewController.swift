//
//  DetailViewController.swift
//  MobileStockTracker
//
//  Created by Mohamed Sobhi  Fouda on 6/13/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, EditItemDelegate  {
   
    var managedObjectContext: NSManagedObjectContext? = nil

    func newItemViewDidCancel(_ controller: NewItemViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func newItemView(_ controller: NewItemViewController, didFinishEditing item: Item) {
        print("from detailVIEW\(String(describing: item.name))")
        dismiss(animated: true, completion: nil)
        viewDidLoad()
    }
    
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    

    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.timestamp!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Item? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
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
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditItem" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! NewItemViewController
            controller.delegateEdit = self
            controller.ItemToEdit = detailItem
            controller.managedObjectContext = detailItem?.managedObjectContext
            
        }
    }
    
}

