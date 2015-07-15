//
//  UdacityAPISession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

class UdacityAPISession
{
  /// :param: udacityParameters A Dictionary containing the parameters required to login to Udacity
  /// :param: completionHandler Returns a Bool to indicate the succes of the login and a String message providing information about the success / failure
  class func udacityLoginSession(udacityParameters: [String : [String : String]], completionHandler: (success: Bool, message: String?, userId: String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: UdacityAPIConstants.UdacitySessionURL)!)
    request.HTTPMethod = UdacityAPIConstants.HttpMethod
    request.addValue(UdacityAPIConstants.ApplicationJSON, forHTTPHeaderField: UdacityAPIConstants.HttpHeaderFieldAccept)
    request.addValue(UdacityAPIConstants.ApplicationJSON, forHTTPHeaderField: UdacityAPIConstants.HttpHeaderFieldContentType)
    var networkError: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(udacityParameters, options: nil, error: &networkError)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, downloadError in
      if downloadError != nil {
        completionHandler(success: false, message: ErrorMessages.NetworkErrorMessage, userId: nil)
      } else {
        let subsetData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(subsetData, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          completionHandler(success: false, message: ErrorMessages.JsonErrorMessage, userId: nil)
        } else {
          if let parsedJSON = jsonData {
            if let account = parsedJSON["account"] as? NSDictionary {
              let userId = account["key"] as! String
              let loggedIn = account["registered"] as! Bool
              completionHandler(success: loggedIn, message: nil, userId: userId)
            } else {
              if parsedJSON["status"] as! Int == ErrorMessages.ErrorCode403 || parsedJSON["status"] as! Int == ErrorMessages.ErrorCode400 {
                completionHandler(success: false, message: ErrorMessages.ErrorCodeMessage, userId: nil)
              }
            }
          } else {
            completionHandler(success: false, message: ErrorMessages.JsonErrorMessage, userId: nil)
          }
        }
      }
    }
    task.resume()
  }
  
  class func studentNameForUdacityUserId(userId: String, completionHandler: (success: Bool, studentName: (String, String)) -> Void) {
    let udacityGetSessionURL = UdacityAPIConstants.UdacityGetURL + "\(userId)"
    let request = NSMutableURLRequest(URL: NSURL(string: udacityGetSessionURL)!)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        // handle error
      }
      let subsetData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
      var jsonError: NSError?
      let jsonData = NSJSONSerialization.JSONObjectWithData(subsetData, options: .MutableLeaves, error: &jsonError) as? NSDictionary
      if jsonError != nil {
        // handle error
      } else {
        if let parsedJSON = jsonData {
          let user = parsedJSON["user"] as! NSDictionary
          completionHandler(success: true, studentName: (user["nickname"] as! String, user["last_name"] as! String))
        }
      }
    }
    task.resume()
    
    
  }
  
}
