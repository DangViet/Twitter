//
//  LogInViewController.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/1/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */
    @IBAction func onLogInButton(_ sender: UIButton) {
        let client = TwitterClient.sharedInstance
        
        client?.login(success: { 
            print("Log INNNNNNN")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }, failure: { (error:Error) in
            print("\(error.localizedDescription)")
        })
    }
    
}
