//
//  UdacityLoginSession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

class UdacityLoginSession {
  
  class func udacityLoginTask(udacityParameters: [String: [String: String]], loginCompletionHandler: (success: Bool, completionMessage: String) -> ()) {
    let request = NSMutableURLRequest(URL: NSURL(string: UdacityLoginSessionConstants.udacitySessionURL)!)
    request.HTTPMethod = UdacityLoginSessionConstants.httpMethod
    request.addValue(UdacityLoginSessionConstants.applicationJSON, forHTTPHeaderField: UdacityLoginSessionConstants.httpHeaderFieldAccept)
    request.addValue(UdacityLoginSessionConstants.applicationJSON, forHTTPHeaderField: UdacityLoginSessionConstants.httpHeaderFieldContentType)
    var networkError: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(udacityParameters, options: nil, error: &networkError)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, downloadError in
      if downloadError != nil {
        loginCompletionHandler(success: false, completionMessage: ErrorMessages.networkErrorMessage)
      } else {
        let subsetData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) // subset response data!
        println(NSString(data: subsetData, encoding: NSUTF8StringEncoding))
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(subsetData, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          println(jsonError?.localizedDescription)
          let jsonErrorString = NSString(data: subsetData, encoding: NSUTF8StringEncoding)
          println("Error could not parse JSON: '\(jsonErrorString)'")
          loginCompletionHandler(success: false, completionMessage: ErrorMessages.jsonErrorMessage)
        } else {
          if let parsedJSON = jsonData {
            if let account = parsedJSON["account"] as? NSDictionary {
              let loggedIn = account["registered"] as! Bool
              loginCompletionHandler(success: loggedIn, completionMessage: UdacityLoginSessionConstants.successfulLoginMessage)
            } else {
              if parsedJSON["status"] as! Int == ErrorMessages.errorCode403 || parsedJSON["status"] as! Int == ErrorMessages.errorCode400 {
                loginCompletionHandler(success: false, completionMessage: ErrorMessages.errorCodeMessage)
              }
            }
          } else {
            loginCompletionHandler(success: false, completionMessage: ErrorMessages.jsonErrorMessage)
          }
        }
      }
    }
    task.resume()
  }
  
}
