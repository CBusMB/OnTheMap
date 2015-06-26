//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

struct UdacityUser {
  let userName: String
  let password: String
  lazy var udacityParameters: [String : [String : String]] = [UdacityLoginSessionConstants.Udacity : [UdacityLoginSessionConstants.Username : self.userName, UdacityLoginSessionConstants.Password : self.password]]
  
  init(userName: String, password: String) {
    self.userName = userName
    self.password = password
    saveUserNameAndPassword()
  }
  
  func saveUserNameAndPassword() {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(userName, forKey: "userName")
    // this is a student app, but normally would not store password in NSUserDefaults
    defaults.setObject(password, forKey: "password")
  }

}
