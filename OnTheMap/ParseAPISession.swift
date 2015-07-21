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
  /**
  GETs student locations from the server
  
  :param: completionHandler   returns a Bool to indicate success and a completionMessage description
  */
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
  
  /**
  Adds the student locations to the OnTheMapLocations.sharedCollection
  
  :param: studentNamesAndLocations   The dictionary parsed from the web service's JSON response
  */
  private class func createOnTheMapLocations(fromDataSource studentNamesAndLocations: [NSDictionary]) {
    OnTheMapLocations.sharedCollection.locations = studentNamesAndLocations.map {
      var studentInfo = StudentLocation(nameAndLocation: $0)
      return studentInfo }
  }
  
  /**
  POSTs a student location to the web service
  
  :param: studentInformation   A dictionary of required paramenters for the POST session
  :param: completionHandler    Returns a Bool to indicate success of the POST and a string tuple for messages regarding the success or failure of the POST
  */
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
  
  /**
  PUTs (updates) a student location on the web service
  
  :param: studentInformation   A dictionary of required paramenters for the POST session
  :param: urlWithObjectId      The URL for the web service that includes the objectId of the object to be updated
  :param: completionHandler    Returns a Bool to indicate success of the POST and a string tuple for messages regarding the success or failure of the POST
  */
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
  
  /**
  GETs an array of student location objects for a given uniqueId
  :param: userId   The userId to query
  :param: completionHandler    Returns a Bool to indicate success of the POST and an array of objectIds associated with the userId
  */
  class func queryStudentLocationSession(byUserId userId: String, completionHandler: (success: Bool, objectIDs: [String]?) -> Void) {
    let urlString = escapeURL(forUserId: userId)
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
                let studentObjectId = student[ParseAPIConstants.ObjectIDKey] as! String
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
  
  private class func escapeURL(forUserId userId: String) -> String {
    let urlString = ParseAPIConstants.ParseURL + "?where={\"\(ParseAPIConstants.UniqueKeyKey)\":\"\(userId)\"}"
    let escapedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    return escapedURLString!
  }
  
}
