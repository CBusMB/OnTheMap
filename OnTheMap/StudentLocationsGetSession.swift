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
    let request = NSMutableURLRequest(URL: NSURL(string: StudentLocationsGetSessionConstants.ParseURL)!)
    request.addValue(StudentLocationsGetSessionConstants.ParseApplicationID, forHTTPHeaderField: StudentLocationsGetSessionConstants.HeaderFieldForApplicationID)
    request.addValue(StudentLocationsGetSessionConstants.RestAPIKey, forHTTPHeaderField: StudentLocationsGetSessionConstants.HeaderFieldForREST)
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
            let results = parsedJSON[StudentLocationsGetSessionConstants.Results] as! [NSDictionary]
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
      let locationUniqueKey = nameAndLocation[StudentLocationsGetSessionConstants.UniqueKey] as! String
      let locationFirstName = nameAndLocation[StudentLocationsGetSessionConstants.FirstName] as! String
      let locationLastName = nameAndLocation[StudentLocationsGetSessionConstants.LastName] as! String
      let locationMapString = nameAndLocation[StudentLocationsGetSessionConstants.MapString] as! String
      let locationMediaURL = nameAndLocation[StudentLocationsGetSessionConstants.MediaURL] as! String
      let locationLatitude = CLLocationDegrees(nameAndLocation[StudentLocationsGetSessionConstants.Latitude] as! Double)
      let locationLongitude = CLLocationDegrees(nameAndLocation[StudentLocationsGetSessionConstants.Longitude] as! Double)
      let locationCoordinate = CLLocationCoordinate2D(latitude: locationLatitude, longitude: locationLongitude)
      
      let studentLocation = StudentLocation(uniqueKey: locationUniqueKey, firstName: locationFirstName, lastName: locationLastName, mapString: locationMapString, mediaURL: locationMediaURL, coordinate: locationCoordinate)
      
      locations.addLocationToCollection(studentLocation)
    }
  }
  
}
