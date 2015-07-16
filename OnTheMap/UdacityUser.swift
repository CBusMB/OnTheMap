//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/13/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//
// struct is used to create parameters needed for Udacity login
// values are persisted in NSUserDefaults to minimize network calls to retrieve this information
import Foundation

struct UdacityUser {
  let userName: String
  let password: String
  lazy var udacityParameters: [String : [String : String]] = [UdacityAPIConstants.Udacity : [UdacityAPIConstants.Username : self.userName, UdacityAPIConstants.Password : self.password]]
  
  init(userName: String, password: String) {
    self.userName = userName
    self.password = password
    saveToUserDefaults(userName, key: "userName")
    saveToUserDefaults(password, key: "password")
  }
  
  func saveToUserDefaults(object: String, key: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(object, forKey: key)
  }
}

struct FirstAndLastName {
  var firstName: String
  var lastName: String
  init(firstName: String, lastName: String) {
    self.firstName = firstName
    self.lastName = lastName
    NSUserDefaults.standardUserDefaults().setObject(firstName, forKey: "firstName")
    NSUserDefaults.standardUserDefaults().setObject(lastName, forKey: "lastName")
  }
}

struct UdacityUserId {
  var userId: String
  init(userId: String) {
    self.userId = userId
    NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
  }
}


