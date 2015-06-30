//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/17/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

struct ParseAPIConstants {
  static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
  static let HeaderFieldForApplicationID = "X-Parse-Application-Id"
  static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
  static let HeaderFieldForREST = "X-Parse-REST-API-Key"
  static let ParseURL = "https://api.parse.com/1/classes/StudentLocation"
  static let Results = "results"
  static let ObjectID = "objectId"
  static let UniqueKey = "uniqueKey"
  static let FirstName = "firstName"
  static let LastName = "lastName"
  static let MapString = "mapString"
  static let MediaURL = "mediaURL"
  static let Latitude = "latitude"
  static let Longitude = "longitude"
  static let HttpHeaderFieldContentType = "Content-Type"
  static let ApplicationJSON = "application/json"
  static let HTTPMethodPOST = "POST"
  static let HTTPMethodPUT = "PUT"
}

struct UdacityLoginSessionConstants {
  static let UdacitySessionURL = "https://www.udacity.com/api/session"
  static let HttpMethod = "POST"
  static let ApplicationJSON = "application/json"
  static let HttpHeaderFieldAccept = "Accept"
  static let HttpHeaderFieldContentType = "Content-Type"
  static let Username = "username"
  static let Password = "password"
  static let Udacity = "udacity"
}

struct ErrorMessages {
  static let ErrorCode400 = 400
  static let ErrorCode403 = 403
  static let ErrorCodeMessage = "Account not found or invalid credentials"
  static let NetworkErrorMessage = "Network Error"
  static let JsonErrorMessage = "Error, could not read response from server"
  static let GenericErrorMessage = "Error"
  static let GeocodingErrorMessage = "Could not find location, please try again"
}

struct TableViewConstants {
  static let CellIdentifier = "studentInformationCell"
}

struct NavigationItemConstants {
  static let Logout = "Logout"
}

struct ImageConstants {
  static let PinImage = "pin"
}

struct MapViewConstants {
  static let ReuseIdentifier = "pin"
}

struct DefaultStudentInformationConstants {
  static let UdacityHomePage = "https://www.udacity.com/"
}

struct ActionSheetConstants {
  static let AlertActionTitleConfirmation = "Confirmation Required"
  static let AlertActionTitleLogout = "Logout"
  static let AlertActionMessageLogout = "Are you sure you want to logout?"
  static let AlertActionTitleResubmit = "Resubmit?"
  static let AlertActionTitleCancel = "Cancel"
  static let AlertActionTitleError = "Error"
  static let AlertActionTitleMultipleMatches = "Multiple matches found."
  static let AlertActionMessageChooseLocation = "Choose the best match"
  static let AlertActionFormattedAddressLines = "FormattedAddressLines"
}

struct SegueIdentifierConstants {
  static let MapToPostSegue = "mapToPost"
  static let TableToPostSegue = "tableToPost"
}

struct NameConstants {
  static let FirstName = "Matthew"
  static let LastName = "Brown"
}


