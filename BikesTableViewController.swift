//
//  BikesTableViewController.swift
//  
//
//  Created by Gannon Barnett on 2/6/18.
//

import UIKit
import FacebookCore
import FirebaseDatabase

class BikesTableViewController: UITableViewController {

    var storeVC : StoreViewController {
        return self.parent!.parent! as! StoreViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BikeArray.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BikeCell", for: indexPath) as! BikeTableCell
        let bike = BikeArray[indexPath.row]
        cell.bike = bike
        if purchasedBikeNames.contains(bike.bikeName) {
            cell.setPurchased()
        }else {
            cell.BuyBikeButton.alpha = 1.0
            cell.BuyBikeButton.isEnabled = true
            cell.UseBikeButton.isHidden = true
        }
        
        cell.NameLabel.text = bike.bikeName
        cell.PriceLabel.text = String(bike.price)
        cell.LeftImage.image = UIImage(named: bike.imageName)!.imageResize(sizeChange: bike.bikeSize)
        cell.AccelerationValueLabel.text = String(bike.multiplier)
        cell.WeightValueLabel.text = String(bike.weight)
        cell.MaxSpeedValueLabel.text = String(Int(bike.maxVelocity! / 100.0))
        cell.NotesLabel.text = bike.notes
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(200)
    }
    
    @IBAction func BuyButtonTouched(_ sender: UIButton) {
        //button is within stackview and contentview and other views..
        let cell = sender.superview!.superview!.superview!.superview!.superview! as! BikeTableCell
        let price = cell.bike!.price
        if points >= price {
            purchasedBikeNames.append(cell.bike!.bikeName)
            points -= price
            UserDefaults.standard.set(points, forKey: "Points")
            AppEventsLogger.log(AppEvent.spentCredits())
            AppEventsLogger.log("Bike (\(cell.bike!.bikeName) purchased")
            UserDefaults.standard.set(purchasedBikeNames, forKey: "PurchasedBikeNames")
            cell.justPurchased()
            storeVC.PointsLabel.text = String(points)
        } else {
            cell.notEnoughPointsAnimation()
        }
    }
    
    @IBAction func UseButtonTouched(_ sender: UIButton) {
        let cell = sender.superview!.superview!.superview!.superview!.superview! as! BikeTableCell
        let bike = cell.bike!
        bikeInUse = bike
        UserDefaults.standard.set(bike.bikeName, forKey: "BikeInUse")
        self.tableView.reloadData()
    }
}
