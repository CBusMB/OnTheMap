//
//  StudentLocationsGetSession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/16/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation
import MapKit

class StudentLocationsGetSession
{
  class func getStudentLocationsTask(locationsCompletionHandler: (success: Bool, completionMessage: String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: ParseAPIConstants.ParseURL)!)
    request.addValue(ParseAPIConstants.ParseApplicationID, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForApplicationID)
    request.addValue(ParseAPIConstants.RestAPIKey, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForREST)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        locationsCompletionHandler(success: false, completionMessage: ErrorMessages.NetworkErrorMessage)
      } else {
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          locationsCompletionHandler(success: false, completionMessage: ErrorMessages.JsonErrorMessage)
        } else {
          if let parsedJSON = jsonData {
            let results = parsedJSON[ParseAPIConstants.Results] as! [NSDictionary]
            self.createOnTheMapLocations(fromDataSource: results)
            locationsCompletionHandler(success: true, completionMessage: nil)
          }
        }
      }
    }
    task.resume()
  }
  
  class func createOnTheMapLocations(fromDataSource studentNamesAndLocations: [NSDictionary]) {
    let locations = OnTheMapLocations.sharedCollection
    for nameAndLocation in studentNamesAndLocations {
      let studentLocation = StudentLocation(nameAndLocation: nameAndLocation)
      locations.addLocationToCollection(studentLocation)
    }
  }
  
}
