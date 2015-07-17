//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/17/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//


struct ParseAPIConstants {
  static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
  static let HeaderFieldForApplicationID = "X-Parse-Application-Id"
  static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
  static let HeaderFieldForREST = "X-Parse-REST-API-Key"
  static let ParseURL = "https://api.parse.com/1/classes/StudentLocation"
  static let ParseURLWithLimit = "https://api.parse.com/1/classes/StudentLocation?limit=100"
  static let Results = "results"
  static let ObjectIDKey = "objectId"
  static let UniqueKeyKey = "uniqueKey"
  static let FirstNameKey = "firstName"
  static let LastNameKey = "lastName"
  static let MapStringKey = "mapString"
  static let MediaURLKey = "mediaURL"
  static let LatitudeKey = "latitude"
  static let LongitudeKey = "longitude"
  static let HttpHeaderFieldContentType = "Content-Type"
  static let ApplicationJSON = "application/json"
  static let HTTPMethodPOST = "POST"
  static let HTTPMethodPUT = "PUT"
  static let UploadComplete = "Upload Complete"
  static let LocationUpdated = "Location Updated"
  static let UploadSuccessful = "Upload Successful"
  static let LocationAdded = "Location Added"
}

struct UdacityAPIConstants {
  static let UdacitySessionURL = "https://www.udacity.com/api/session"
  static let UdacityGetURL = "https://www.udacity.com/api/users/"
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
  static let NetworkErrorMessage = "Network Error, please try again later"
  static let JsonErrorMessage = "Error, could not read response from server"
  static let GenericErrorMessage = "Error"
  static let GeocodingErrorMessage = "Could not find location, please try again"
  static let LocationNotUpdated = "Location Not Updated, please try again later"
  static let LocationNotAdded = "Location Not Added, please try again later"
}

struct NavigationBarConstants {
  static let Logout = "Logout"
  static let PinImage = "pin"
}

struct ReuseIdentifierConstants {
  static let ReuseIdentifier = "pin"
  static let CellIdentifier = "studentInformationCell"
}

struct AlertConstants {
  static let AlertActionTitleConfirmation = "Confirmation Required"
  static let AlertActionTitleLogout = "Logout"
  static let AlertActionMessageLogout = "Are you sure you want to logout?"
  static let AlertActionTitleResubmit = "Resubmit?"
  static let AlertActionTitleCancel = "Cancel"
  static let AlertActionTitleError = "Error"
  static let AlertActionTitleMultipleMatches = "Multiple matches found."
  static let AlertActionMessageChooseLocation = "Choose the best match"
  static let AlertActionFormattedAddressLines = "FormattedAddressLines"
  static let AlertActionMessageOverwrite = "You've already added a location to the map.  Do you want to overwrite it or add a new location?"
  static let AlertActionOverwriteTitleConfirmation = "Overwrite"
  static let AlertActionTitleNewLocation = "Add New Location"
  static let AlertActionTitleUrlRequired = "URL Required"
  static let AlertActionMessageUrlRequired = "Please enter a URL"
  static let AlertActionTitleOK = "OK"
}

struct SegueIdentifierConstants {
  static let MapToPostSegue = "mapToPost"
  static let TableToPostSegue = "tableToPost"
  static let TabBarIdentifier = "tabBarController"
}