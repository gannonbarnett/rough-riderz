//
//  BikeTableCell.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/6/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class BikeTableCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        NotEnoughPointsLabel.alpha = 0
    }

    var bike : BikeFrame? = nil
    
    @IBOutlet var BuyBikeButton: UIButton!
    @IBOutlet var UseBikeButton: UIButton!
    
    @IBOutlet var NameLabel: UILabel!
    @IBOutlet var PriceLabel: UILabel!
    
    @IBOutlet var WeightValueLabel: UILabel!
    @IBOutlet var AccelerationValueLabel: UILabel!
    @IBOutlet var MaxSpeedValueLabel: UILabel!
    
    @IBOutlet var NotesLabel: UILabel!
    
    @IBOutlet var LeftImage: UIImageView!
    
    @IBOutlet var NotEnoughPointsLabel: UILabel!
    
    func notEnoughPointsAnimation() {
        
        let animationDuration = 1.0
        
        // Fade in the view
        UILabel.animate(withDuration: animationDuration, animations: { () -> Void in
            self.NotEnoughPointsLabel.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UILabel.animate(withDuration: animationDuration, delay: 2.0, options: [.curveEaseIn], animations: { () -> Void in
                self.NotEnoughPointsLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    func setPurchased() {
        self.BuyBikeButton.alpha = 0.4
        self.BuyBikeButton.isEnabled = false
        self.UseBikeButton.isHidden = false
        
        if bikeInUse.bikeName == bike!.bikeName {
            self.UseBikeButton.alpha = 0.4
            self.UseBikeButton.isEnabled = false
        }else {
            self.UseBikeButton.alpha = 1.0
            self.UseBikeButton.isEnabled = true
        }
    }
    
    func justPurchased() {
        setPurchased()
        bikeInUse = self.bike!
        UserDefaults.standard.set(bikeInUse.bikeName, forKey: "BikeInUse")
        self.UseBikeButton.alpha = 0.4
        self.UseBikeButton.isEnabled = false
    }
    
}
