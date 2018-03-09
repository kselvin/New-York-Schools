//
//  ViewController.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import UIKit
import JHSpinner

class AllSchoolsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SchoolsDelegate {

    @IBOutlet weak var schoolsTableView: UITableView!               //table view with list of schools displayed on it
    
    let schoolNetworkingManager = SchoolsNetworkingManager()        //makes api calls to get school data
    var schoolsList = [School]()                                    //list of ALL schools
    var searchResults = [School]()                                  //search results from list of ALL schools
    var schoolsInAlphabeticalOrder = [[School]]()                   //schools organized into arrays alphabetically
   
    
    //used for sections when looking at alphabetical list
    let alphabeticalSections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
   
    var boroughs = ["All", "Manhattan", "Brooklyn", "Queens", "Staten Island", "The Bronx"]     //boroughs for searching with borough filter
    
    
    let searchController = UISearchController(searchResultsController: nil) //search controller used for search bar functionality
    
    
    var spinner: JHSpinnerView?         //used while schools are loading into table
    let nyPurple = UIColor(red: 128.0/255.0, green: 45.0/255.0, blue: 179.0/255.0, alpha: 1.0)  //shade of purple
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()                              //initial UI setup
        setupSearchBar()                            //initial search bar setup
        
        //show loading spinner until schools are loaded
        spinner = JHSpinnerView.showOnView(view, spinnerColor: UIColor.white, overlay: .roundedSquare, overlayColor:UIColor.black.withAlphaComponent(0.6), text: "Loading 🏫s" )
        view.addSubview(spinner!)
    }
    
    func initialSetup(){
        //add an empty array for each letter of the alphabet (and # for schools starting with anything other than letters)
        for _ in 0...alphabeticalSections.count-1 {
            schoolsInAlphabeticalOrder.append([School]())
        }
        
        //tableview delegate and data source
        schoolsTableView.delegate = self
        schoolsTableView.dataSource = self
        
        //allows cells to automatically resize to fit content
        schoolsTableView.estimatedRowHeight = 55.0
        schoolsTableView.rowHeight = UITableViewAutomaticDimension
        
        //start with tableview hidden until schools are loaded
        schoolsTableView.isHidden = true
        
        //SchoolsDelegate allows networking manager to call function to add school to tableview in this VC
        schoolNetworkingManager.delegate = self
        schoolNetworkingManager.getSchools()        //api call to get schools from database
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if !isSearching() {                                         //if not searching return rows in alphabetical sections
            return schoolsInAlphabeticalOrder[section].count
        }else{
            return searchResults.count                              //return search results if searching
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = schoolsTableView.dequeueReusableCell(withIdentifier: "schoolCell") as? SchoolsTableViewCell
        
        //if not searching get school names in correct alphabetical sections and rows in those sections
        if !isSearching() {
           cell?.schoolNameLabel.text = schoolsInAlphabeticalOrder[indexPath.section][indexPath.row].schoolName
        }else{
            cell?.schoolNameLabel.text = searchResults[indexPath.row].schoolName        //search results
        }
       return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //if not searchig, show alphabetical section headers
        if !isSearching() {
            return alphabeticalSections[section]
        }else{
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return section for each letter if not searching
        if !isSearching() {
            return alphabeticalSections.count
        }else{
            return 1            //one large section for search results
        }
    }
    
    //help resize table view cells to contents
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    //show section headers in column on right side of screen
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if !isSearching() {
            return alphabeticalSections
        }else{
            return [String]()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //go to school's page when tapped
        if !isSearching() {
            performSegue(withIdentifier: "toSchoolPage", sender: schoolsInAlphabeticalOrder[indexPath.section][indexPath.row])
        }else{
            performSegue(withIdentifier: "toSchoolPage", sender: searchResults[indexPath.row])
        }
        
        //deselect row so when you return to this vc it doesn't look like a cell is selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //sender is school selected on table view
        if segue.identifier == "toSchoolPage" {
            if let school = sender as? School {
                if let navVC = segue.destination as? UINavigationController {
                    if let destinationVC = navVC.topViewController as? SingleSchoolViewController {
                        destinationVC.school = school       //pass school selected to SingleSchoolViewController where school's data will be displayed
                    }
                }
            }
        }
    }
    
    //called by delegate to add schools to the tableview after they are returned from api call
    func addSchool(school: School) {
        let trimmedString = school.schoolName?.trimmingCharacters(in: .whitespaces)     //some school names in db start with whitespace -- needed to trim whitespace to get true first letter
        let firstLetter = trimmedString![0]                                         //get true first letter school
        if let index = alphabeticalSections.index(of: String(firstLetter)) {
            //find index of letter in alphabeticalSections that matches first letter of school, add school to that section
            schoolsInAlphabeticalOrder[index].append(school)
            schoolsTableView.insertRows(at: [IndexPath(row: schoolsInAlphabeticalOrder[index].count-1, section: index)], with: .none)
        }else{
            //otherwise if school does not start with a letter, add school to last section (titled: #)
            schoolsInAlphabeticalOrder[alphabeticalSections.count-1].append(school)
            schoolsTableView.insertRows(at: [IndexPath(row: schoolsInAlphabeticalOrder[alphabeticalSections.count-1].count-1, section: alphabeticalSections.count-1)], with: .none)
        }
        
        //append to list of ALL Schools
        schoolsList.append(school)
    }
    
    //called by delegate method when schools are finished loading
    func finishedLoading() {
        searchController.searchBar.isUserInteractionEnabled = true      //allow users to search
        schoolsTableView.isHidden = false                               //show tableview
        spinner?.removeFromSuperview()                                  //remove loading spinnner
    }
    
}

//Extension with all methods related to search and search bar
extension AllSchoolsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    //setup search bar in navigation controller
    func setupSearchBar(){
        searchController.searchBar.isUserInteractionEnabled = false     //initially do not allow users to interact with search bar until schools are finished loading
        
        searchController.searchResultsUpdater = self                    //set result updater to self
        searchController.obscuresBackgroundDuringPresentation = false   //don't obscure underyling content
        
        searchController.searchBar.placeholder = "Search Schools"
        
        //scope buttons for filters user can use to narrow search to be borough specific
        searchController.searchBar.scopeButtonTitles = ["ALL", "MAN", "BKLYN", "QUEENS", "SI", "BRONX"]
        searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-Medium", size: 11.0)!], for: .normal)
        
        navigationItem.searchController = searchController      //add search controller to navigation controller
        navigationItem.hidesSearchBarWhenScrolling = false      //don't hide search bar when scroling
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self              //set search bar delegate to self to use search bar delegate methods
    }
    
    
    //delegate method to check if scope changed
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterForSearch(searchBar.text!, scope: boroughs[selectedScope])
    }
    
    //delegate method for cancel button tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        schoolsTableView.reloadData()
    }
    
    //update search results based on scope selected and text in search bar
    func updateSearchResults(for searchController: UISearchController) {
        let scope = boroughs[searchController.searchBar.selectedScopeButtonIndex]   //selected borough
        filterForSearch(searchController.searchBar.text!, scope: scope)            //filter with scope and search text
    }
    
    //check if search bar is empty
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //true if user is currently searching
    func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    //filter search
    func filterForSearch(_ searchText: String, scope: String) {
        searchResults = schoolsList.filter({( school : School) -> Bool in
            let boroughMatch = (scope == "All") || (school.borough == scope)  //all or school's borough is equal to selected borough
            
            if searchBarIsEmpty() {
                return boroughMatch          //if search is empty
            } else {
                return boroughMatch && school.schoolName!.lowercased().contains(searchText.lowercased()) //search not empty look for school that contains search text and is in matching borough or ALL
            }
        })
        schoolsTableView.reloadData()       //reload table with filtering
    }
    
}


extension String {
    //get letter at index of a string
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}



