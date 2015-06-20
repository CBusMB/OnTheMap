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
  class func getStudentLocationsTask(locationsCompletionHandler: (success: Bool, completionMessage: String?) -> ()) {
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
          if let parsedJSON = jsonData {
            let results = parsedJSON[StudentLocationsGetSessionConstants.results] as! [NSDictionary]
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
      let locationUniqueKey = nameAndLocation[StudentLocationsGetSessionConstants.uniqueKey] as! String
      let locationFirstName = nameAndLocation[StudentLocationsGetSessionConstants.firstName] as! String
      let locationLastName = nameAndLocation[StudentLocationsGetSessionConstants.lastName] as! String
      let locationMapString = nameAndLocation[StudentLocationsGetSessionConstants.mapString] as! String
      let locationMediaURL = nameAndLocation[StudentLocationsGetSessionConstants.mediaURL] as! String
      let locationLatitude = CLLocationDegrees(nameAndLocation[StudentLocationsGetSessionConstants.latitude] as! Double)
      let locationLongitude = CLLocationDegrees(nameAndLocation[StudentLocationsGetSessionConstants.longitude] as! Double)
      let locationCoordinate = CLLocationCoordinate2D(latitude: locationLatitude, longitude: locationLongitude)
      
      let studentLocation = StudentLocation(uniqueKey: locationUniqueKey, firstName: locationFirstName, lastName: locationLastName, mapString: locationMapString, mediaURL: locationMediaURL, coordinate: locationCoordinate)
      
      locations.addLocationToCollection(studentLocation)
    }
  }
  
}
