//
//  SchoolsNetworkingManager.swift
//  New York Schools
//
//  Created by Keith Selvin on 3/7/18.
//  Copyright © 2018 Keith Selvin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SchoolsNetworkingManager {
    
    var delegate: SchoolsDelegate?
    var satDelegate: SATDelegate?
    
    func getSchools(){
        let url = "https://data.cityofnewyork.us/resource/97mf-9njv.json"
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
           // print(response)
            if let value = response.value {
                let json = JSON(value)
                print(json)
                if json.array != nil {
                    if json.count > 0 {
                        for i in 0...json.count-1 {
                            //get essential information to creates school object
                            let schoolName = json[i]["school_name"].string ?? "N/A"
                            let dbn = json[i]["dbn"].string ?? "N/A"
                            let boroCode = json[i]["boro"].string ?? "N/A"
                            
                            let newSchool = School(schoolName: schoolName, dbn: dbn, boroCode: boroCode)
                            
                            let overView = json[i]["overview_paragraph"].string ?? "No overview available"
                            let neighborhood = json[i]["neighborhood"].string ?? "No neighborhood information available"
                            let location = json[i]["location"].string ?? "Can't find location"
                            let phoneNumber = json[i]["phone_number"].string ?? "No phone number available"
                            let schoolEmail = json[i]["school_email"].string ?? "No email available"
                            let schoolWebsite = json[i]["website"].string ?? "No website available"
                            let totalStudents = json[i]["total_students"].string ?? "0"
                            let graduationRate = json[i]["graduation_rate"].string ?? "0.00"
                            
                            let street = json[i]["primary_address_line_1"].string ?? "no street"
                            let city = json[i]["city"].string ?? "no city"
                            let state = json[i]["state_code"].string ?? "no state"
                            let zip = json[i]["zip"].string ?? "00000"
                            let latitude = json[i]["latitude"].string ?? "0.00"
                            let longitude = json[i]["longitude"].string ?? "0.00"
                            
                            
                            newSchool.overview = overView
                            newSchool.neighborhood = neighborhood
                            newSchool.location = location
                            newSchool.phoneNumber = phoneNumber
                            newSchool.schoolEmail = schoolEmail
                            newSchool.website = schoolWebsite
                            newSchool.numStudents = Int(totalStudents)
                            let formattedGraduationRate = String(format: "%.3f", Float(graduationRate)!*100)
                            newSchool.graduationRate = Float(formattedGraduationRate)
                            
                            newSchool.address = Address(street: street, city: city, state: state, zip: zip)
                            newSchool.address?.longitude = Double(longitude)
                            newSchool.address?.latitude = Double(latitude)
                            
  
                            self.delegate?.addSchool(school: newSchool)
                        }
                    }
                }
            }
        }
    }
    
    func getSATScoreForSchool(dbn: String){
        let url = "https://data.cityofnewyork.us/resource/734v-jeq5.json?DBN=\(dbn)"
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            print(response)
            if let value = response.value {
                let json = JSON(value)
                let math = json[0]["sat_math_avg_score"].string ?? "0"
                let writing = json[0]["sat_writing_avg_score"].string ?? "0"
                let reading = json[0]["sat_critical_reading_avg_score"].string ?? "0"
                
                if let mathScore = Int(math), let readingScore = Int(reading), let writingScore = Int(writing) {
                    let satScore = SATScore(mathScore: mathScore, readingScore: readingScore, writingScore: writingScore)
                    self.satDelegate?.addSATScoreToSchool(satScore: satScore)
                }
            }
        }
        
        
    }
}

protocol SchoolsDelegate: class {
    func addSchool(school: School)
}

protocol SATDelegate: class {
    func addSATScoreToSchool(satScore: SATScore)
}
