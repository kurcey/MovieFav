//
//  FavMovie.swift
//  movieFavs
//
//  Created by user152630 on 6/29/19.
//  Copyright © 2019 user152630. All rights reserved.
//

import UIKit
import CoreData

class FavMovieViewController: UITableViewController{
    
    var alertMsg = ShowAlert()
    var dataController : DataController? = nil
    
    var passImage = Data()
    var passDescription = String()
    var passTitle = String()
    var passURL = String()
    var passGenra = String()
    
    var fetchedResultsController: NSFetchedResultsController<FavoriteMov>!
    let fetchRequest:NSFetchRequest< FavoriteMov > = FavoriteMov.fetchRequest()
    
    @IBOutlet weak var FavMovieTableView: UITableView!
    
    @IBOutlet var TableListMovie: UITableView!
    
    fileprivate func loadFetchResultsController() {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController!.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            print("No Data")
            alertMsg.showAlertMsg(presentView: self, title: "Error", message: "Error preforming Fetch")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if dataController == nil{
            dataController = DataController(modelName: "FavMovie")
            dataController!.load(self)
        }
        loadFetchResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataController = nil
        fetchedResultsController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavToDetailSegue" {
            let controller = segue.destination as! DetailMovieViewController
            controller.passImage = passImage
            controller.passDescription = passDescription
            controller.passTitle = passTitle
            controller.passURL = passURL
            controller.passGenra = passGenra
        }
    }
    
}

extension FavMovieViewController : NSFetchedResultsControllerDelegate{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "tableCell") as! UITableViewCell
        let result = fetchedResultsController.object(at: indexPath)
        if let imgData = result.image{
            cell.imageView?.image = UIImage(data:  imgData)
            cell.textLabel?.text  = result.title ?? " "
            cell.detailTextLabel?.text = result.genra ?? ""
        }
        return cell
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            
            break
        case .delete:
            self.tableView.reloadData()
            break
        case .update:
            break
        case .move:
            break default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = fetchedResultsController!.object(at: indexPath)
        if controller.image != nil{
            passImage = controller.image!
        }
        passDescription = controller.desc ?? ""
        passTitle = controller.title ?? ""
        passURL = controller.posterUrl ?? ""
        passGenra = controller.genra ?? ""
        
        self.performSegue(withIdentifier: "FavToDetailSegue", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let objectToDelete = fetchedResultsController?.object(at: indexPath) {
            dataController!.viewContext.delete(objectToDelete)
            try? self.dataController!.viewContext.save()
            }
        }
    }
    
}
