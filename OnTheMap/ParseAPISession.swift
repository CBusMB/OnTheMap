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
  /// :param: completionHandler returns a Bool to indicate success of the get session and a String message regarding the success/failure
  class func getStudentLocationsSession(completionHandler: (success: Bool, completionMessage: String?) -> Void) {
    let escapedURLString = ParseAPIConstants.ParseURLWithLimit.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let request = NSMutableURLRequest(URL: NSURL(string: escapedURLString!)!)
    request.addValue(ParseAPIConstants.ParseApplicationID, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForApplicationID)
    request.addValue(ParseAPIConstants.RestAPIKey, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForREST)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        completionHandler(success: false, completionMessage: ErrorMessages.NetworkErrorMessage)
      } else {
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          completionHandler(success: false, completionMessage: ErrorMessages.JsonErrorMessage)
        } else {
          if let parsedJSON = jsonData {
            let results = parsedJSON[ParseAPIConstants.Results] as! [NSDictionary]
            self.createOnTheMapLocations(fromDataSource: results)
            completionHandler(success: true, completionMessage: nil)
          }
        }
      }
    }
    task.resume()
  }
  
  private class func createOnTheMapLocations(fromDataSource studentNamesAndLocations: [NSDictionary]) {
    let locations = OnTheMapLocations.sharedCollection
    for nameAndLocation in studentNamesAndLocations {
      let studentLocation = StudentLocation(nameAndLocation: nameAndLocation)
      locations.addLocationToCollection(studentLocation)
    }
  }
  
  /// :param: studentInformation is a NSDictionary that contains the parameters to post to the web service
  /// :param: completionHandler returns a Bool to indicate success of the post session and a String tuple with messages regarding the success/failure
  class func postStudentLocationSession(studentInformation: NSDictionary, completionHandler: (success: Bool, message: (String?, String?)) -> Void) {
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
        completionHandler(success: false, message: (ErrorMessages.NetworkErrorMessage, ErrorMessages.LocationNotAdded))
      } else {
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          completionHandler(success: false, message: (ErrorMessages.JsonErrorMessage, ErrorMessages.LocationNotAdded))
        } else {
          completionHandler(success: true, message: (ParseAPIConstants.UploadSuccessful, ParseAPIConstants.LocationAdded))
        }
      }
    }
    task.resume()
  }
  
  /// :param: studentInformation a NSDictionary that contains the parameters to post to the web service
  /// :param: urlWithObjectId the web service url plus the object ID for the location the user wants to update
  /// :param: completionHandler returns a Bool to indicate success of the put session and a String tuple with messages regarding the success/failure
  class func putStudentLocationSession(studentInformation: NSDictionary, urlWithObjectId: String, completionHandler: (success: Bool, message: (String?, String?)) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: urlWithObjectId)!)
    request.HTTPMethod = ParseAPIConstants.HTTPMethodPUT
    request.addValue(ParseAPIConstants.ParseApplicationID, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForApplicationID)
    request.addValue(ParseAPIConstants.RestAPIKey, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForREST)
    request.addValue(ParseAPIConstants.ApplicationJSON, forHTTPHeaderField: ParseAPIConstants.HttpHeaderFieldContentType)
    var networkError: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(studentInformation, options: nil, error: &networkError)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        completionHandler(success: false, message: (ErrorMessages.NetworkErrorMessage, ErrorMessages.LocationNotUpdated))
      } else {
        var jsonError: NSError?
        if let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? NSDictionary {
          if jsonError != nil {
            completionHandler(success: false, message: (ErrorMessages.JsonErrorMessage, ErrorMessages.LocationNotUpdated))
          } else {
            completionHandler(success: true, message: (ParseAPIConstants.UploadComplete, ParseAPIConstants.LocationUpdated))
          }
        } else {
          completionHandler(success: false, message: (ErrorMessages.JsonErrorMessage, ErrorMessages.LocationNotUpdated))
        }
      }
    }
    task.resume()
  }
  
  /// :param: userName used to query the web service if a given unique ID (userName) exists
  /// :param: completionHandler returns a Bool to indicate if the query was successful and an array of objectIDs for the given userName (unique ID)
  class func queryStudentLocationSession(byUserName userName: String, completionHandler: (success: Bool, objectIDs: [String]?) -> Void) {
    let urlString = escapeURL(forUserName: userName)
    let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    request.addValue(ParseAPIConstants.ParseApplicationID, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForApplicationID)
    request.addValue(ParseAPIConstants.RestAPIKey, forHTTPHeaderField: ParseAPIConstants.HeaderFieldForREST)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        completionHandler(success: false, objectIDs: nil)
      } else {
        var jsonError: NSError?
        if let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &jsonError) as? NSDictionary {
          if jsonError != nil {
            completionHandler(success: false, objectIDs: nil)
          } else {
            if let students = jsonData[ParseAPIConstants.Results] as? [NSDictionary] {
            var studentObjectIds = [String]()
            for student in students {
              var studentObjectId = student[ParseAPIConstants.ObjectIDKey] as! String
              studentObjectIds.append(studentObjectId)
            }
            completionHandler(success: true, objectIDs: studentObjectIds)
            } else {
              completionHandler(success: false, objectIDs: nil)
            }
          }
        } else {
          completionHandler(success: false, objectIDs: nil)
        }
      }
    }
    task.resume()
  }
  
  private class func escapeURL(forUserName userName: String) -> String {
    let urlString = ParseAPIConstants.ParseURL + "?where={\"\(ParseAPIConstants.UniqueKeyKey)\":\"\(userName)\"}"
    let escapedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    return escapedURLString!
  }
  
}
