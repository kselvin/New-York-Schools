//
//  ContactActions.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import Foundation
import UIKit


class ContactActions {
    
    func openEmail(emailAddress: String) {
        if let url = URL(string: "mailto:\(emailAddress)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func openPhone(phoneNumber: String) {
        if let num = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(num, options: [:], completionHandler: nil)
        }
    }
    
    func openWebsite(urlString: String) {
        print("TAPPED")
        var website: String?
        if !(urlString.hasPrefix("http")) || !(urlString.hasPrefix("https")) {
            website = "http://" + (urlString)
        }else{
            website = urlString
        }
        
        if let website = URL(string: (website)!){
            UIApplication.shared.open(website, options: [:], completionHandler: nil)
        }
    }
    
}
