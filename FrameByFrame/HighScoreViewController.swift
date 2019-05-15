//
//  HighScoreViewController.swift
//  FrameByFrame
//
//  Created by Mac de Pol on 15/05/2019.
//  Copyright © 2019 CFGS La Salle Gracia. All rights reserved.
//

import UIKit

class HighScoreViewController: UIViewController {

    @IBOutlet weak var highScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        highScore.text = String(defaults.value(forKey: "highscore") as! Int)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
