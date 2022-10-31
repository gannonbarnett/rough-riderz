//
//  StoreCollectionCell.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/4/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class StoreCollectionCell: UICollectionViewCell {
    
    var collectionView : UICollectionViewController!
    
    var bike : BikeFrame? = nil
    
    @IBOutlet var LeftImage: UIImageView!
    
    @IBOutlet var NameLabel: UILabel!
    @IBOutlet var PriceLabel: UILabel!

    @IBOutlet var AccelerationValueLabel: UILabel!
    @IBOutlet var WeightValueLabel: UILabel!
    
    @IBOutlet var NotesTextView: UITextView!
    
    @IBOutlet var BuyBikeButton: UIButton!
    
    @IBOutlet var UseBikeButton: UIButton!
    
    @IBAction func BuyBikeButtonPressed(_ sender: UIButton) {
        if points >= bike!.price {
            presentAlert_buyBike()
        } else {
            presentAlert_notEnoughPoints()
        }
    }
    
    @IBAction func UseBikeButtonPressed(_ sender: UIButton) {
        bikeInUse = bike!
    }
    
    func buyBike(alert : UIAlertAction) {
        points -= bike!.price
        purchasedBikeNames.append(bike!.bikeName)
    }
    
    func presentAlert_buyBike() {
        let alert = UIAlertController(title: "Buy \(bike!.bikeName)?", message: "Confirm you want to spend \(bike!.price) points to buy this bike.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Hell yeah", style: UIAlertActionStyle.default, handler: buyBike))
        alert.addAction(UIAlertAction(title: "Eh", style: UIAlertActionStyle.default, handler: nil))
        collectionView.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_notEnoughPoints() {
        let alert = UIAlertController(title: "Not enough funds", message: "You don't have enough points to buy this bike.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dang", style: UIAlertActionStyle.default, handler: nil))
        collectionView.present(alert, animated: true, completion: nil)
    }

}
