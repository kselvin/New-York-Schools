//
//  KeithSelvinContactViewController.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import UIKit

class KeithSelvinContactViewController: UIViewController {

    let contactActions = ContactActions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func phoneButtonTapped(_ sender: Any) {
        contactActions.openPhone(phoneNumber: "2012904179")
    }
    @IBAction func emailButtonTapped(_ sender: Any) {
        contactActions.openEmail(emailAddress: "selvinkeith@gmail.com")
    }
    @IBAction func websiteButtonTapped(_ sender: Any) {
        contactActions.openWebsite(urlString: "https://kselvin.com")
    }
    

}
