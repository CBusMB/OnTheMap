//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/17/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

struct StudentLocationsGetSessionConstants {
  static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
  static let headerFieldForApplicationID = "X-Parse-Application-Id"
  static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
  static let headerFieldForREST = "X-Parse-REST-API-Key"
  static let parseURL = "https://api.parse.com/1/classes/StudentLocation"
}

struct UdacityLoginSessionConstants {
  static let udacitySessionURL = "https://www.udacity.com/api/session"
  static let httpMethod = "POST"
  static let applicationJSON = "application/json"
  static let httpHeaderFieldAccept = "Accept"
  static let httpHeaderFieldContentType = "Content-Type"
  static let username = "username"
  static let password = "password"
  static let udacity = "udacity"
  static let successfulLoginMessage = "Logged in"
}

struct ErrorMessages {
  static let errorCode400 = 400
  static let errorCode403 = 403
  static let errorCodeMessage = "Account not found or invalid credentials"
  static let networkErrorMessage = "Network Error"
  static let jsonErrorMessage = "Error, could not read response from server"
}

struct TableViewConstants {
  static let cellIdentifier = "studentInformationCell"
  static let pinImage = "pin"
}
