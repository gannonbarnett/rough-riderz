//
//  BikesCollectionViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/4/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class BikesCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(StoreCollectionCell.self, forCellWithReuseIdentifier: "BikeCell")

        // Do any additional setup after loading the view.
    }

    @IBAction func BuyButtonPressed(_ sender: Any) {
        parent?.view.setNeedsDisplay()
        self.view.setNeedsDisplay()
    }
    
    @IBAction func UseButtonPressed(_ sender: Any) {
        parent?.view.setNeedsDisplay()
        self.view.setNeedsDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BikeArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BikeCell", for: indexPath) as! StoreCollectionCell
        let bike = BikeArray[indexPath.row]
        cell.bike = bike
        if purchasedBikeNames.contains(bike.bikeName) {
            cell.BuyBikeButton.alpha = 0.4
            cell.BuyBikeButton.isEnabled = false
            cell.UseBikeButton.isHidden = false
            
            if bikeInUse.bikeName == bike.bikeName {
                cell.UseBikeButton.alpha = 0.4
                cell.UseBikeButton.isEnabled = false
            }else {
                cell.UseBikeButton.alpha = 1.0
                cell.UseBikeButton.isEnabled = true
            }
        }else {
            cell.BuyBikeButton.alpha = 1.0
            cell.BuyBikeButton.isEnabled = true
            cell.UseBikeButton.isHidden = true
        }
        
        cell.collectionView = self
        cell.NameLabel.text = bike.bikeName
        cell.PriceLabel.text = String(bike.price)
        cell.LeftImage.image = UIImage(named: bike.imageName)
        cell.AccelerationValueLabel.text = String(bike.acceleration)
        cell.WeightValueLabel.text = String(bike.weight)
        cell.NotesTextView.text = bike.notes
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
