//
//  School.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import Foundation


class School {
    
    //Info collected from database via API calls
    var dbn : String?
    var schoolName: String?
    var borough: String?
    var overview: String?
    var neighborhood: String?
    var location: String?
    var phoneNumber: String?
    var schoolEmail: String?
    var website: String?
    var numStudents: Int?
    var graduationRate: Float?
    
    var SATScore: SATScore?
    
    var address: Address?
    
    //initialize with nothing
    init (){}
    
    //initialize with school name, dbn, and boroCode (because they don't show full borough name on database)
    init(schoolName: String, dbn: String, boroCode: String?){
        self.schoolName = schoolName
        self.dbn = dbn
        
        //convert boroCode to borough name
        if boroCode == "M" {
            self.borough = "Manhattan"
        }else if boroCode == "Q" {
            self.borough = "Queens"
        }else if boroCode == "K" {
            self.borough = "Brooklyn"
        }else if boroCode == "X" {
            self.borough = "The Bronx"
        }else if boroCode == "R" {
            self.borough = "Staten Island"
        }else{
            self.borough = "N/A"
        }
    }

}

//Structs for SATScore and Address (need a better place to put these in)

//SAT Score
struct SATScore {
    var readingScore: Int?
    var mathScore: Int?
    var writingScore: Int?
    var totalScore: Int?
    
    init(){}
    
    init(mathScore: Int, readingScore: Int, writingScore: Int){
        self.mathScore = mathScore
        self.readingScore = readingScore
        self.writingScore = writingScore
        self.totalScore = mathScore + readingScore + writingScore       //calculate total avg SAT score on object creation
    }
}

//Address
struct Address {
    var city: String?
    var state: String?
    var zip: String?
    var street: String?
    var longitude: Double?
    var latitude: Double?
    
    var addressString: String?
    
    //initialize with street, city, state, zip
    init(street: String, city: String, state: String, zip: String){
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        addressString = street + ", " + city + " " + state + " " + zip      //create full address string used for label text on creation 
    }
    
}
