//
//  SearchMovie.swift
//  movieFavs
//
//  Created by user152630 on 6/29/19.
//  Copyright © 2019 user152630. All rights reserved.
//

import UIKit
import CoreData

class SearchMovieViewController: UIViewController , NSFetchedResultsControllerDelegate{
   
    var alertMsg = ShowAlert()
    let dataController = DataController(modelName: "SavedMovie")
    
    @IBOutlet weak var SearchTextField: UITextField!
    
    @IBAction func SearchButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowSearchResult", sender: self)
    }
    var fetchedResultsController: NSFetchedResultsController<SearchResult>!
    let fetchRequest:NSFetchRequest< SearchResult > = SearchResult.fetchRequest()
    
    fileprivate func loadFetchResultsController() {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)

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
        dataController.load(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFetchResultsController()
        deleteSearchResult()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSearchResult" {
            let controller = segue.destination as! SearchResults
            controller.SearchString = SearchTextField.text
            controller.dataController = dataController
            controller.fetchedResultsController = fetchedResultsController
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func deleteSearchResult(){       
        let numberObject =  try? fetchedResultsController!.managedObjectContext.count(for: fetchRequest) - 1
        for i in stride(from: numberObject!, to: -1, by: -1)
        {
            let indexPath = IndexPath(item: i, section: 0)
            dataController.viewContext.delete(fetchedResultsController.object(at: indexPath))
            try? self.dataController.viewContext.save()
        }
    }
    
}
