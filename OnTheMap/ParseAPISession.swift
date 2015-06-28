//
//  ParseAPISession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/16/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation
import MapKit

class ParseAPISession
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
        println("\(jsonData)")
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
  
  class func postStudentLocationSession(studentInformation: NSDictionary, completionHandler: (success: Bool, message: String?) -> Void) {
    println("postStudentLocationSession")
    let request = NSMutableURLRequest(URL: NSURL(string: ParseAPIConstants.ParseURL)!)
    request.HTTPMethod = ParseAPIConstants.HTTPMethodPOST
    request.addValue(ParseAPIConstants.ParseApplicationID, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForApplicationID)
    request.addValue(ParseAPIConstants.RestAPIKey, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForREST)
    request.addValue(ParseAPIConstants.ApplicationJSON, forHTTPHeaderField: ParseAPIConstants.HttpHeaderFieldContentType)
    var networkError: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(studentInformation, options: nil, error: &networkError)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        completionHandler(success: false, message: ErrorMessages.NetworkErrorMessage)
      } else {
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? [String : String]
        if jsonError != nil {
          completionHandler(success: false, message: ErrorMessages.JsonErrorMessage)
        } else {
          completionHandler(success: true, message: nil)
        }
      }
    }
    task.resume()
  }
  
  class func putStudentLocationSession(studentInformation: NSDictionary, urlWithObjectId: String, completionHandler: (success: Bool, message: (String?, String?)) -> Void) {
    println("putStudentLocationSession")
    let request = NSMutableURLRequest(URL: NSURL(string: ParseAPIConstants.TemporaryPutURL)!)
    request.HTTPMethod = ParseAPIConstants.HTTPMethodPUT
    request.addValue(ParseAPIConstants.ParseApplicationID, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForApplicationID)
    request.addValue(ParseAPIConstants.RestAPIKey, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForREST)
    request.addValue(ParseAPIConstants.ApplicationJSON, forHTTPHeaderField: ParseAPIConstants.HttpHeaderFieldContentType)
    var networkError: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(studentInformation, options: nil, error: &networkError)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        completionHandler(success: false, message: (ErrorMessages.NetworkErrorMessage, nil))
      } else {
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? [String : String]
        println("\(jsonData)")
        if jsonError != nil {
          completionHandler(success: false, message: (ErrorMessages.JsonErrorMessage, nil))
        } else {
          completionHandler(success: true, message: ("Upload Complete", "Location Updated"))
        }
      }
    }
    task.resume()
  }
  
}
