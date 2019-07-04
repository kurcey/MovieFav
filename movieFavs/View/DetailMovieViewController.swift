//
//  DetailMovie.swift
//  movieFavs
//
//  Created by user152630 on 6/29/19.
//  Copyright © 2019 user152630. All rights reserved.
//

import UIKit

class DetailMovieViewController: UIViewController{
    
    var passImage = Data()
    var passDescription = String()
    var passTitle = String()
    var passURL = String()
    var passGenra = String()
    
    var dataController : DataController? = nil

    @IBOutlet weak var PosterImage: UIImageView!
    
    @IBOutlet weak var MovieTitleTextField: UITextField!
    
    @IBOutlet weak var MovieDiscriptionTextField: UITextView!
    
    @IBAction func addToFav(_ sender: Any) {
        
        let savedMovie = FavoriteMov(context: self.dataController!.viewContext)
        savedMovie.image = passImage
        savedMovie.id = UUID()
        savedMovie.desc = passDescription
        savedMovie.posterUrl = passURL
        savedMovie.title = passTitle
        
        try? self.dataController!.viewContext.save()
        self.performSegue(withIdentifier: "DetailToFavSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if dataController == nil{
            dataController = DataController( modelName: "FavMovie")
            dataController!.load(self)
        }
        PosterImage.image = UIImage(data: passImage)
        MovieTitleTextField.text = passTitle
        MovieDiscriptionTextField.text = passDescription
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dataController = nil
        
    }
    
}
