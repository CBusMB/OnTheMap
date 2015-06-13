//
//  UdacityPostSession.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

class UdacityPostSession {
  let user: UdacityUser?
  let udacity: [String: AnyObject?]
  let username = "username"
  let password = "password"
  
  struct PostSessionConstants {
    static let udacitySessionURL = "https://www.udacity.com/api/session"
    static let httpMethod = "POST"
    static let applicationJSON = "application/json"
    static let httpHeaderFieldAccept = "Accept"
    static let httpHeaderFieldContentType = "Content-Type"
    
  }
  
  init(credentials: UdacityUser) {
    user = credentials
    udacity = [username: user?.userName, password: user?.password]
  }
  
  func postSessionTask() {
    let request = NSMutableURLRequest(URL: NSURL(string: PostSessionConstants.udacitySessionURL)!)
    request.HTTPMethod = PostSessionConstants.httpMethod
    request.addValue(PostSessionConstants.applicationJSON, forHTTPHeaderField: PostSessionConstants.httpHeaderFieldAccept)
    request.addValue(PostSessionConstants.applicationJSON, forHTTPHeaderField: PostSessionConstants.httpHeaderFieldContentType)
    var jsonError: NSError? = nil
    // request.HTTPBody = NSJSONSerialization.dataWithJSONObject(udacity as! [String: AnyObject], options: nil, error: &jsonError)
    request.HTTPBody = "{\"udacity\": {\"username\": \"cbusmb@gmail.com\", \"password\": \"Ma3Xiu1\"}}".dataUsingEncoding(NSUTF8StringEncoding)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        // handle error
        return
      }
      let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) // subset response data!
      println(NSString(data: newData, encoding: NSUTF8StringEncoding))
    }
    task.resume()
    
  }
  
}
