//
//  StudentLocationPostSession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/23/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation
import MapKit

class StudentLocationPostSession
{
  class func postStudentLocationSession(studentInformation: NSDictionary, completionHandler: (success: Bool, message: String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: ParseAPIConstants.ParseURL)!)
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
  
}
