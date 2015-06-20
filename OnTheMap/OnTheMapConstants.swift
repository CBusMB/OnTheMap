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
  static let results = "results"
  static let uniqueKey = "uniqueKey"
  static let firstName = "firstName"
  static let lastName = "lastName"
  static let mapString = "mapString"
  static let mediaURL = "mediaURL"
  static let latitude = "latitude"
  static let longitude = "longitude"
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
}

struct ErrorMessages {
  static let errorCode400 = 400
  static let errorCode403 = 403
  static let errorCodeMessage = "Account not found or invalid credentials"
  static let networkErrorMessage = "Network Error"
  static let jsonErrorMessage = "Error, could not read response from server"
  static let genericErrorMessage = "Error"
}

struct TableViewConstants {
  static let cellIdentifier = "studentInformationCell"
}

struct NavigationItemConstants {
  static let logout = "Logout"
}

struct ImageConstants {
  static let pinImage = "pin"
}

struct MapViewConstants {
  static let reuseIdentifier = "pin"
}

struct ActionSheetConstants {
  static let alertActionTitleConfirmation = "Confirmation Required"
  static let alertActionTitleLogout = "Logout"
  static let alertActionMessageLogout = "Are you sure you want to logout?"
  static let alertActionTitleResubmit = "Resubmit?"
  static let alertActionTitleCancel = "Cancel"
}
