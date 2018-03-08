//
//  SingleSchoolViewController.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import MapKit

class SingleSchoolViewController: UIViewController, SATDelegate, TwicketSegmentedControlDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var segmentControl: TwicketSegmentedControl!
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var contactView: UIView!
    
    
    @IBOutlet weak var readingLabel: UILabel!
    @IBOutlet weak var writingLabel: UILabel!
    @IBOutlet weak var mathLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var numStudentsLabel: UILabel!
    @IBOutlet weak var graduationPercentageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    
    
    
    var school: School?
    let schoolNetworkManager = SchoolsNetworkingManager()
    
    let contactActions = ContactActions()

    override func viewDidLoad() {
        super.viewDidLoad()
        contactView.isHidden = true
        
 
        let frame = CGRect(x: 0, y: 0, width: (self.view.frame.width), height: (self.navigationController?.navigationBar.frame.size.height)!)
        let tlabel = UILabel(frame: frame)
        tlabel.text = self.title
//        tlabel.textColor = UIColor.bl
        tlabel.font = UIFont.boldSystemFont(ofSize: 60) //UIFont(name: "Helvetica", size: 17.0)
        tlabel.adjustsFontSizeToFitWidth = true
        tlabel.textAlignment = .left
        tlabel.text = school?.schoolName
        tlabel.numberOfLines = 4
        
        
        
        self.navigationItem.titleView = tlabel
       
        let titles = ["Details", "Contact Info"]
        segmentControl.setSegmentItems(titles)
        segmentControl.delegate = self
        
        setupInfoView()
        setupContactView()
        
        schoolNetworkManager.satDelegate = self
        schoolNetworkManager.getSATScoreForSchool(dbn: (school?.dbn)!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelect(_ segmentIndex: Int) {
        if segmentIndex == 0 {
            infoView.isHidden = false
            contactView.isHidden = true
        }else {
            dropPinForSchoolLocation()
            infoView.isHidden = true
            contactView.isHidden = false
        }
    }
    
    func addSATScoreToSchool(satScore: SATScore) {
        school?.SATScore = satScore
        readingLabel.text = String(describing: satScore.readingScore!)
        writingLabel.text = String(describing: satScore.writingScore!)
        mathLabel.text = String(describing: satScore.mathScore!)
        let total = satScore.mathScore! + satScore.readingScore! + satScore.writingScore!
        totalLabel.text = String(describing: total)
    }
    
    
    func setupInfoView(){
        overviewLabel.text = school?.overview
        graduationPercentageLabel.text = String(describing: school!.graduationRate!)
        numStudentsLabel.text = String(describing: school!.numStudents!)
    }
    
    func setupContactView(){
        addressLabel.text = school?.address?.addressString
        phoneButton.setTitle(("☎ " + (school?.phoneNumber)!), for: .normal)
        emailButton.setTitle(("📧 " + (school?.schoolEmail)!), for: .normal)
        websiteButton.setTitle(("🌐 To School Website"), for: .normal)
        mapView.delegate = self
        dropPinForSchoolLocation()
        
    }
    
    func dropPinForSchoolLocation(){
        let center = CLLocationCoordinate2D(latitude: (school?.address?.latitude)!, longitude: (school?.address?.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = center
        mapView.addAnnotation(pin)
    }
    
    @IBAction func emailTapped(_ sender: Any) {
        contactActions.openEmail(emailAddress: (school?.schoolEmail)!)
    }
    
    @IBAction func phoneTapped(_ sender: Any) {
        contactActions.openPhone(phoneNumber: (school?.phoneNumber)!)
    }
    
    @IBAction func webTapped(_ sender: Any) {
        contactActions.openWebsite(urlString: (school?.website)!)
    }
    
}
