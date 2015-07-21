//
//  OnTheMapLocations.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/19/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation

class OnTheMapLocations
{
  /// Singleton.  Use OnTheMapLocations.sharedCollection to access public properties and methods
  static let sharedCollection = OnTheMapLocations()
  
  // private array, accessed from locations
  private var _locations = [StudentLocation]()
  
  var locations: [StudentLocation] {
    get {
      return _locations
    } set {
      _locations = newValue
    }
  }
  
  /**
  Adds a StudentLocation struct to the locations array at index [0]
  
  :param: location    The StudentLocation Array to add
  */
  func addLocationToBeginningOfCollection(location: StudentLocation) {
    // insert the student location at the beginning of the array
    // when the user adds/updates a location, use this method so
    // that the users name will be at the top of the table view
    _locations.insert(location, atIndex: 0)
  }
  
  func removeAllLocations() {
    _locations.removeAll(keepCapacity: false)
  }
  
  /**
  Checks the locations array for a matching uniqueKey
  
  :param: uniqueId    the uniqueId of a StudentLocation
  :returns: Bool indicating if the matching uniqueKey was found
  */
  func checkLocationsForMatchingUniqueId(uniqueId: String) -> Bool {
    return _locations.filter { $0.uniqueKey == uniqueId }.count > 0
  }
  
  /**
  Removes a StudentLocation that contains a given objectID
  
  :param: objectID    the objectID of a StudentLocation
  */
  func removeStudentLocationForObjectID(objectID: String) {
    _locations = _locations.filter { $0.objectID != objectID }
  }
  
}