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

class ASBeerViewController: UIViewController ,UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 350, height: 20))

    var ogBeerArray = [ASBeer]() //Array of dictionary
    var beerArray = [ASBeer]() //Array of dictionary
    var pageNum = 0
    var link = "https://api.brewerydb.com/v2/brewery/avMkil/beers?withBreweries=Y&key=1285c2fdce8414cb69666c0306103775&format=json" // link to fetch the data
    var isLoading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadImages(pageNum)
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        searchBar.placeholder = "Search For Beer"
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton

    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beerArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "beerData", for: indexPath) as! BeerCell
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 4.0
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.0
        
        let beer: ASBeer = beerArray[indexPath.item]
        cell.beerName!.text = beer.name
        if (beer.imageUrl == nil)
        {
            cell.beerImage.image = UIImage(named: "beerImage")

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
        return CGSize(width: screenWidth/2 - 20 , height: screenWidth/2 + 25)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    
    
    //fuction to fetch the data from link
    func loadImages(_ pageNum: Int) {
        let newLink = link + "&p=" + String(pageNum)
        
        Alamofire.request(newLink)
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
                self.isLoading  = false
                for data in dictData {
                    
                    guard let id: String = data["id"] as? String else {
                        continue
                        
                    }
                    let beer = ASBeer(id: id)
                    if let imageDictUrl = data["labels"] {
                        if let image = imageDictUrl["large"] as? String {
                            beer.imageUrl = image
                        }
                    }
                    if let name = data["name"] as? String {
                        beer.name = name
                    }
                    if let date = data["createDate"] as? String{
                        beer.date_created = date
                    }
                    self.ogBeerArray.append(beer)
                }
                self.beerArray.append(contentsOf: self.ogBeerArray)
                DispatchQueue.main.async() {
                    self.myCollectionView.reloadData()
                }
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isLoading || searchBar.text != "" {
            return
        }
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            isLoading = true
            pageNum = pageNum + 1
            loadImages(pageNum)
        }
    }

}


extension ASBeerViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {

        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchingText = searchBar.text
        beerArray = ogBeerArray.filter( { return $0.name == searchingText } )
        self.myCollectionView.reloadData()
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        beerArray = ogBeerArray
        self.myCollectionView.reloadData()
        self.searchBar.resignFirstResponder()
    }
}


