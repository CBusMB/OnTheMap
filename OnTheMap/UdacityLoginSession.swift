//
//  UdacityLoginSession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

class UdacityLoginSession {
  
  class func udacityLoginTask(udacityParameters: [String : [String : String]], loginCompletionHandler: (success: Bool, completionMessage: String?) -> Void) {
    let request = NSMutableURLRequest(URL: NSURL(string: UdacityLoginSessionConstants.UdacitySessionURL)!)
    request.HTTPMethod = UdacityLoginSessionConstants.HttpMethod
    request.addValue(UdacityLoginSessionConstants.ApplicationJSON, forHTTPHeaderField: UdacityLoginSessionConstants.HttpHeaderFieldAccept)
    request.addValue(UdacityLoginSessionConstants.ApplicationJSON, forHTTPHeaderField: UdacityLoginSessionConstants.HttpHeaderFieldContentType)
    var networkError: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(udacityParameters, options: nil, error: &networkError)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, downloadError in
      if downloadError != nil {
        loginCompletionHandler(success: false, completionMessage: ErrorMessages.NetworkErrorMessage)
      } else {
        let subsetData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        var jsonError: NSError?
        let jsonData = NSJSONSerialization.JSONObjectWithData(subsetData, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          loginCompletionHandler(success: false, completionMessage: ErrorMessages.JsonErrorMessage)
        } else {
          if let parsedJSON = jsonData {
            if let account = parsedJSON["account"] as? NSDictionary {
              let loggedIn = account["registered"] as! Bool
              loginCompletionHandler(success: loggedIn, completionMessage: nil)
            } else {
              if parsedJSON["status"] as! Int == ErrorMessages.ErrorCode403 || parsedJSON["status"] as! Int == ErrorMessages.ErrorCode400 {
                loginCompletionHandler(success: false, completionMessage: ErrorMessages.ErrorCodeMessage)
              }
            }
          } else {
            loginCompletionHandler(success: false, completionMessage: ErrorMessages.JsonErrorMessage)
          }
        }
      }
    }
    task.resume()
  }
  
}
