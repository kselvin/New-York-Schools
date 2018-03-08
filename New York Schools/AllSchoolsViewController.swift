//
//  ViewController.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import UIKit

class AllSchoolsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SchoolsDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet weak var schoolsTableView: UITableView!
    
    let schoolNetworkingManager = SchoolsNetworkingManager()
    var schoolsList = [School]()
    var searchResults = [School]()
    
   
    
    let alphabeticalSections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
    
    var boroughs = ["All", "Manhattan", "Brooklyn", "Queens", "Staten Island", "The Bronx"]
    
    var schoolsInAlphabeticalOrder = [[School]]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...alphabeticalSections.count-1 {
            schoolsInAlphabeticalOrder.append([School]())
        }
        
        
        schoolsTableView.delegate = self
        schoolsTableView.dataSource = self
        schoolsTableView.estimatedRowHeight = 55.0
        schoolsTableView.rowHeight = UITableViewAutomaticDimension
        
        
        schoolNetworkingManager.delegate = self
        schoolNetworkingManager.getSchools()
        
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        
        searchController.searchBar.placeholder = "Search Schools"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["ALL", "MAN", "BKLYN", "QUEENS", "SI", "BRONX"]
        searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-Medium", size: 11.0)!], for: .normal)
        searchController.searchBar.delegate = self
        
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() == true {
            return searchResults.count
        }else{
            return schoolsInAlphabeticalOrder[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = schoolsTableView.dequeueReusableCell(withIdentifier: "schoolCell") as? SchoolsTableViewCell
        
        if isFiltering() == false {
           cell?.schoolNameLabel.text = schoolsInAlphabeticalOrder[indexPath.section][indexPath.row].schoolName
        }else{
            cell?.schoolNameLabel.text = searchResults[indexPath.row].schoolName
        }
       return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() == false {
            return alphabeticalSections[section]
        }else{
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isFiltering() == false {
            return alphabeticalSections.count
        }else{
            return 1
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering() == true {
            return [String]()
        }
        return alphabeticalSections
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isFiltering() {
            performSegue(withIdentifier: "toSchoolPage", sender: schoolsInAlphabeticalOrder[indexPath.section][indexPath.row])
        }else{
            performSegue(withIdentifier: "toSchoolPage", sender: searchResults[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSchoolPage" {
            if let school = sender as? School {
                if let navVC = segue.destination as? UINavigationController {
                    if let destinationVC = navVC.topViewController as? SingleSchoolViewController {
                        destinationVC.school = school
                    }
                }
            }
        }
    }
    
    func addSchool(school: School) {
        //print("YOO")
        let trimmedString = school.schoolName?.trimmingCharacters(in: .whitespaces)
        let firstLetter = trimmedString![0]
        if let index = alphabeticalSections.index(of: String(firstLetter)) {
            schoolsInAlphabeticalOrder[index].append(school)
            schoolsTableView.insertRows(at: [IndexPath(row: schoolsInAlphabeticalOrder[index].count-1, section: index)], with: .none)
        }else{
            schoolsInAlphabeticalOrder[alphabeticalSections.count-1].append(school)
            schoolsTableView.insertRows(at: [IndexPath(row: schoolsInAlphabeticalOrder[alphabeticalSections.count-1].count-1, section: alphabeticalSections.count-1)], with: .none)
        }
        
        schoolsList.append(school)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
//        let searchBar = searchController.searchBar
        let scope = boroughs[searchController.searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    
    func filterContentForSearchText(_ searchText: String, scope: String) {
        searchResults = schoolsList.filter({( school : School) -> Bool in
            let doesCategoryMatch = (scope == "All") || (school.borough == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && school.schoolName!.lowercased().contains(searchText.lowercased())
            }
        })
        schoolsTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("index changed! to \(String(selectedScope)) with text " + searchBar.text!)
    
        filterContentForSearchText(searchBar.text!, scope: boroughs[selectedScope])
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        schoolsTableView.reloadData()
    }
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
}


extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}



