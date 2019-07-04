//
//  NewMovie.swift
//  movieFavs
//
//  Created by user152630 on 6/29/19.
//  Copyright © 2019 user152630. All rights reserved.
//

import UIKit
import CoreData

class SearchResultsViewController: UIViewController  {
    
    @IBOutlet weak var NewMovieCollection: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var alertMsg = ShowAlert()
    let tmdb = TMDB()
    let networkHelper = Network()
    
    var SearchString: String? = nil
    var dataController : DataController? = nil
    
    var passImage = Data()
    var passDescription = String()
    var passTitle = String()
    var passURL = String()
    var passGenra = String()
    
    
    var fetchedResultsController: NSFetchedResultsController<SearchResult>? = nil
    var fetchRequest:NSFetchRequest< SearchResult >? = SearchResult.fetchRequest()
    fileprivate func loadFetchResultsController() {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest!.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: dataController!.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController!.delegate = self
        do {
            try fetchedResultsController!.performFetch()
        }
        catch {
            print("No Data")
            alertMsg.showAlertMsg(presentView: self, title: "Error", message: "Error preforming Fetch")
        }
    }
    
    func searchMovies (){
        tmdb.downloadOMDBMovie(self,dataController!,SearchString!, {(movieArray) in
            if let movies = movieArray {
            for photo in movies.results{
                if let poster = photo.poster_path{
                    let singleImage = SearchResult(context: self.dataController!.viewContext)
                    singleImage.image = UIImage(named: "loading")?.pngData()
                    singleImage.id = Int64(photo.id!)
                    singleImage.desc = photo.overview ?? ""
                    singleImage.posterUrl = photo.poster_path ?? ""
                    singleImage.title = photo.original_title ?? ""
                    
                    try? self.dataController!.viewContext.save()
                    self.networkHelper.getURLImage(Constants.OMDB.PosterURL + (poster), {(result) in
                        DispatchQueue.main.async {
                            if let imageAvaiable = result{
                                singleImage.image = imageAvaiable
                            }
                        }
                    })
                }
            }
        }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SearchString != nil {
            loadFetchResultsController()
            searchMovies()
        }
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: (screenWidth / 2), height: ( screenWidth * 0.75 ) )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResultsToDetailSegue" {
            let controller = segue.destination as! DetailMovieViewController
            controller.passImage = passImage
            controller.passDescription = passDescription
            controller.passTitle = passTitle
            controller.passURL = passURL
            controller.passGenra = passGenra
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate{
    
    override func viewWillAppear(_ animated: Bool) {
        loadFetchResultsController()
        NewMovieCollection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let path = newIndexPath{
                NewMovieCollection.insertItems(at: [path])
            }
            break
        case .delete:
            NewMovieCollection.deleteItems(at: [indexPath!])
            break
        case .update:
            NewMovieCollection.reloadItems(at: [newIndexPath!])
            break
        case .move:
            // AlbumCollectionView.moveRow(at: indexPath!, to: newIndexPath!)
            break default:
            break
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let controller = fetchedResultsController else {
            return 0
        }
        let sectionInfo = controller.sections?[section]
        guard let num = sectionInfo?.numberOfObjects, num > 0 else {
            return 0
        }
        return sectionInfo?.numberOfObjects ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMovieList", for: indexPath) as! NewMovieCell
        let img = fetchedResultsController!.object(at: indexPath)
        if let imgData = img.image{
            cell.CollectionImage.image = UIImage(data:  imgData)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = fetchedResultsController!.object(at: indexPath)
        if controller.image != nil{
            passImage = controller.image!
        }
        passDescription = controller.desc ?? ""
        passTitle = controller.title ?? ""
        passURL = controller.posterUrl ?? ""
        passGenra = controller.genra ?? ""
        self.performSegue(withIdentifier: "ResultsToDetailSegue", sender: self)
    }
    
}
