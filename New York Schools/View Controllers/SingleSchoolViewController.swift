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
   
    @IBOutlet weak var infoView: UIView!                        //Info View: view with sat info, graduation rate, description
    @IBOutlet weak var contactView: UIView!                     //Contact View: view with school's contact information
    
    //Info View
    @IBOutlet weak var overviewLabel: UILabel!                  //school overview
    @IBOutlet weak var readingLabel: UILabel!                   //SAT reading label
    @IBOutlet weak var writingLabel: UILabel!                   //SAT writing label
    @IBOutlet weak var mathLabel: UILabel!                      //SAT math label
    @IBOutlet weak var totalLabel: UILabel!                     //total SAT label
    @IBOutlet weak var numStudentsLabel: UILabel!               //number of students at school
    @IBOutlet weak var graduationPercentageLabel: UILabel!      //percentage of students who graduate
   
    //Contact view
    @IBOutlet weak var mapView: MKMapView!                      //map on contact view
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    
    var school: School?                                         //school object passed from AllSchoolsViewController
    let schoolNetworkManager = SchoolsNetworkingManager()       //networking manager
    
    let contactActions = ContactActions()                       //used to call, email, and go to web from app
    
    //used for pin on map showing school's location
    var center: CLLocationCoordinate2D?
    var region: MKCoordinateRegion?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide Contact View because default start on Info View
        contactView.isHidden = true
    
        //segment control
        let titles = ["Details", "Contact Info"]
        segmentControl.setSegmentItems(titles)
        segmentControl.delegate = self
        
        //UI setup
        setupNavBarLabel()
        setupInfoView()
        setupContactView()
        
        schoolNetworkManager.satDelegate = self
        schoolNetworkManager.getSATScoreForSchool(dbn: (school?.dbn)!)      //API call to get school SAT scores
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //switch between showing info view and contact view
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
    
    //called by delegate method when sat score is received from API
    func addSATScoreToSchool(satScore: SATScore) {
        school?.SATScore = satScore
        readingLabel.text = String(describing: satScore.readingScore!)
        writingLabel.text = String(describing: satScore.writingScore!)
        mathLabel.text = String(describing: satScore.mathScore!)
        let total = satScore.mathScore! + satScore.readingScore! + satScore.writingScore!
        totalLabel.text = String(describing: total)
    }
    
    //info view setup
    func setupInfoView(){
        overviewLabel.text = school?.overview
        graduationPercentageLabel.text = String(describing: school!.graduationRate!)
        numStudentsLabel.text = String(describing: school!.numStudents!)
    }
    
    //contact view setup
    func setupContactView(){
        addressLabel.text = school?.address?.addressString
        phoneButton.setTitle(("☎ " + (school?.phoneNumber)!), for: .normal)
        emailButton.setTitle(("📧 " + (school?.schoolEmail)!), for: .normal)
        websiteButton.setTitle(("🌐 To School Website"), for: .normal)
        mapView.delegate = self
        dropPinForSchoolLocation()
        
    }
    
    //fit school name in nav bar as it's title by creating a label and adjusting font
    func setupNavBarLabel(){
        let frame = CGRect(x: 0, y: 0, width: (self.view.frame.width), height: (self.navigationController?.navigationBar.frame.size.height)!)
        let navBarLabel = UILabel(frame: frame)
        navBarLabel.text = self.title
        
        navBarLabel.adjustsFontSizeToFitWidth = true
        navBarLabel.textAlignment = .left
        navBarLabel.text = school?.schoolName
        navBarLabel.numberOfLines = 4

        self.navigationItem.titleView = navBarLabel
    }
    
    //show pin on map view of school's location
    func dropPinForSchoolLocation(){
        center = CLLocationCoordinate2D(latitude: (school?.address?.latitude)!, longitude: (school?.address?.longitude)!)
        region = MKCoordinateRegion(center: center!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region!, animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = center!
        mapView.addAnnotation(pin)
    }
    
    //open Mail app with email to school
    @IBAction func emailTapped(_ sender: Any) {
        contactActions.openEmail(emailAddress: (school?.schoolEmail)!)
    }
    //ask user if he/she wants to call school's number
    @IBAction func phoneTapped(_ sender: Any) {
        contactActions.openPhone(phoneNumber: (school?.phoneNumber)!)
    }
    //open Safari to school's website
    @IBAction func webTapped(_ sender: Any) {
        contactActions.openWebsite(urlString: (school?.website)!)
    }
    //open maps with pin on school's location -- ask user if they want route to school
    @IBAction func viewInMapsTapped(_ sender: Any) {
        openMaps(center: center!, region: region!)
    }
    
    func openMaps(center: CLLocationCoordinate2D, region: MKCoordinateRegion) {
        let options = [
            MKLaunchOptionsMapCenterKey:  center,
            MKLaunchOptionsMapSpanKey:  region.span
            ] as [String : Any] as [String : Any]
        let placemark = MKPlacemark(coordinate: center, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = school?.schoolName
        mapItem.openInMaps(launchOptions: options)
    }
    
}
