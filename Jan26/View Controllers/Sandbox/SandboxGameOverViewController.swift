//
//  SandboxGameOverViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 3/11/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class SandboxGameOverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MainMenuButtonTouched(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func PlayAgainButtonTouched(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        let sandbox = self.navigationController!.viewControllers[1] as! SandboxViewController
        self.navigationController!.popViewController(animated: true)
        sandbox.gameSceneSetUp()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
