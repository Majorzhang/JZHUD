//
//  ViewController.swift
//  JZHUD
//
//  Created by Jun Zhang on 16/9/2.
//  Copyright © 2016年 Jun Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        JZHUD.showHUD(.Random)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func tap(sender: AnyObject) {
        JZHUD.showHUD()
        JZHUD.sharedInstance.delay(4) {
            JZHUD.hideHUD()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

