//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

/// Implements helper methods for 1) creating parameters needed for Udacity login 2) Persisting Udacity information to NSUserDefaults
class UdacityUser {
  
  /**
  Saves Strings to NSUserDefaults
  
  :param: object    value of the key value pair to persist
  :param: key       key of the key value pair to persist
  */
  class func saveToUserDefaults(object: String, key: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(object, forKey: key)
  }
  
  /**
  Creates Dictionary of parameters needed to complete Udacity login
  
  :param: userName    Udacity user name
  :param: password    Udacity password
  :returns: Dictionary of parameters needed for Udacity login
  */
  class func createUdacityParametersDictionary(userName: String, password: String) -> [String : [String : String]] {
    let udacityLoginParameters = [UdacityAPIConstants.Udacity : [UdacityAPIConstants.Username : userName, UdacityAPIConstants.Password : password]]
    return udacityLoginParameters
  }
}




