//
//  myCollectionViewcellCollectionViewCell.swift
//  assignment
//
//  Created by Utkarsh Upadhyay on 15/10/17.
//  Copyright © 2017 Utkarsh Upadhyay. All rights reserved.
//

import UIKit

class BeerCell: UICollectionViewCell {
    @IBOutlet weak var beerImage: UIImageView!
    @IBOutlet weak var beerName: UILabel!
    
   
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.beerImage.image = nil
        self.beerName.text = ""
        
    }
}


