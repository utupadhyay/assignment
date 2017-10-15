//
//  ViewController.swift
//  assignment
//
//  Created by Utkarsh Upadhyay on 13/10/17.
//  Copyright © 2017 Utkarsh Upadhyay. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ASBeerViewController: UIViewController ,UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    var beerArray = [ASBeer]() //Array of dictionary
    let link = "https://api.brewerydb.com/v2/brewery/avMkil/beers?withBreweries=Y&key=1285c2fdce8414cb69666c0306103775&format=json" // link to fetch the data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadImages()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beerArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "beerData", for: indexPath) as! BeerCell
        
        let beer: ASBeer = beerArray[indexPath.item]
        cell.beerName!.text = beer.name
        if (beer.imageUrl == nil)
        {
            print("error")
        }else{
            let url = URL(string: beer.imageUrl!)
            

            //use almofier to get the image from url
            Alamofire.request(url!).responseData { (response) in
                if response.error == nil {
                    print(response.result)
                    
                    
                    //load the image on
                    if let data = response.data {
                        cell.beerImage.image = UIImage(data: data)
                    }
                }
            }
        }
        return cell
    }
    
    // Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: screenWidth/2 - 20 , height: 150)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    
    
    //fuction to fetch the data from link
    func loadImages() {
        
        Alamofire.request(link)
            .validate()
            .responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    print("Error with response: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dict = response.result.value as? Dictionary <String,AnyObject> else {
                    print("Error with dictionary: \(String(describing: response.result.error))")
                    return
                }
                
                guard let dictData = dict["data"] as? [Dictionary <String,AnyObject>] else {
                    print("Error with dictionary data: \(String(describing: response.result.error))")
                    return
                }
                
                for data in dictData {
                    
                    guard let id: String = data["id"] as? String else {
                        continue
                        
                    }
                    let beer = ASBeer(id: id)
                    if let imageDictUrl = data["labels"] {
                        if let image = imageDictUrl["medium"] as? String {
                            beer.imageUrl = image
                        }
                    }
                    if let name = data["name"] as? String {
                        beer.name = name
                    }
                    if let date = data["createDate"] as? String{
                        beer.date_created = date
                    }
                    self.beerArray.append(beer)
                }
                DispatchQueue.main.async() {
                    self.myCollectionView.reloadData()
                }
        }
        
    }
}





