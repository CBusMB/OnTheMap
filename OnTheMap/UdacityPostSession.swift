//
//  UdacityPostSession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

class UdacityPostSession {
  let user: UdacityUser
  let udacity: [String: [String: AnyObject]]
  
  struct PostSessionConstants {
    static let udacitySessionURL = "https://www.udacity.com/api/session"
    static let httpMethod = "POST"
    static let applicationJSON = "application/json"
    static let httpHeaderFieldAccept = "Accept"
    static let httpHeaderFieldContentType = "Content-Type"
    static let username = "username"
    static let password = "password"
    static let udacity = "udacity"
    static let errorCode400 = 400
    static let errorCode403 = 403
    static let errorCodeMessage = "Account not found or invalid credentials"
    static let networkErrorMessage = "Network Error"
    static let jsonErrorMessage = "Error, could not read response from server"
    static let successfulLoginMessage = "Logged in"
  }
  
  init(credentials: UdacityUser) {
    user = credentials
    udacity = [PostSessionConstants.udacity: [PostSessionConstants.username: user.userName, PostSessionConstants.password: user.password]]
  }
  
  func postSessionTask(loginCompletionHandler: (success: Bool, completionMessage: String) -> ()) {
    let request = NSMutableURLRequest(URL: NSURL(string: PostSessionConstants.udacitySessionURL)!)
    request.HTTPMethod = PostSessionConstants.httpMethod
    request.addValue(PostSessionConstants.applicationJSON, forHTTPHeaderField: PostSessionConstants.httpHeaderFieldAccept)
    request.addValue(PostSessionConstants.applicationJSON, forHTTPHeaderField: PostSessionConstants.httpHeaderFieldContentType)
    var networkError: NSError? = nil
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(udacity, options: nil, error: &networkError)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, downloadError in
      if downloadError != nil {
        loginCompletionHandler(success: false, completionMessage: PostSessionConstants.networkErrorMessage)
      } else {
        let subsetData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) // subset response data!
        println(NSString(data: subsetData, encoding: NSUTF8StringEncoding))
        var jsonError: NSError? = nil
        let jsonData = NSJSONSerialization.JSONObjectWithData(subsetData, options: .MutableLeaves, error: &jsonError) as? NSDictionary
        if jsonError != nil {
          println(jsonError?.localizedDescription)
          let jsonErrorString = NSString(data: subsetData, encoding: NSUTF8StringEncoding)
          println("Error could not parse JSON: '\(jsonErrorString)'")
          loginCompletionHandler(success: false, completionMessage: PostSessionConstants.jsonErrorMessage)
        } else {
          if let parsedJSON = jsonData {
            if let account = parsedJSON["account"] as? NSDictionary {
              let loggedIn = account["registered"] as! Bool
              println("parsed JSON succesfully")
              loginCompletionHandler(success: loggedIn, completionMessage: PostSessionConstants.successfulLoginMessage)
            } else {
              if parsedJSON["status"] as! Int == PostSessionConstants.errorCode403 || parsedJSON["status"] as! Int == PostSessionConstants.errorCode400 {
                loginCompletionHandler(success: false, completionMessage: PostSessionConstants.errorCodeMessage)
              }
            }
          } else {
            loginCompletionHandler(success: false, completionMessage: PostSessionConstants.jsonErrorMessage)
            println("Error, couldn't parse JSON")
          }
        }
      }
    }
    task.resume()
  }
  
}
