//
//  StudentLocationsGetSession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/16/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

class StudentLocationsGetSession
{
  class func getStudentLocationsTask(locationsCompletionHandler: (success: Bool, completionMessage: String) -> ()) {
    let request = NSMutableURLRequest(URL: NSURL(string: StudentLocationsGetSessionConstants.parseURL)!)
    request.addValue(StudentLocationsGetSessionConstants.parseApplicationID, forHTTPHeaderField: StudentLocationsGetSessionConstants.headerFieldForApplicationID)
    request.addValue(StudentLocationsGetSessionConstants.restAPIKey, forHTTPHeaderField: StudentLocationsGetSessionConstants.headerFieldForREST)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        locationsCompletionHandler(success: false, completionMessage: ErrorMessages.networkErrorMessage)
      } else {
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          locationsCompletionHandler(success: false, completionMessage: ErrorMessages.jsonErrorMessage)
        } else {
          // println("\(jsonData)")
          if let parsedJSON = jsonData {
            self.assignRelevantLocationInformation(fromDataSource: parsedJSON)
            let test = parsedJSON["results"]![0]["firstName"] as! String
            println("\(test)")
          }
        }
      }
    }
    task.resume()
  }
  
  class func assignRelevantLocationInformation(fromDataSource studentNamesAndLocations: NSDictionary) {
    for nameAndLocation in studentNamesAndLocations {
      // nameAndLocation["firstName"]
    }
  }
  
}
