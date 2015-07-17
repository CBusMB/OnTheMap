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
  class var sharedCollection: OnTheMapLocations {
    struct LocationsSingleton {
      static let instance: OnTheMapLocations = OnTheMapLocations()
    }
    return LocationsSingleton.instance
  }
  
  // private array, accessed from locations
  private var _locations = [StudentLocation]()
  
  var locations: [StudentLocation] {
    get {
      return _locations
    }
  }
  
  /**
  Adds a StudentLocation struct to the locations array
  
  :param: location    The StudentLocation Array to add
  */
  func addLocationToCollection(location: StudentLocation) {
    _locations.append(location)
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
    var match = false
    for student in _locations {
      if uniqueId == student.uniqueKey {
        match = true
        break
      }
    }
    return match
  }
  
  /**
  Removes a StudentLocation that contains a given objectID
  
  :param: objectID    the objectID of a StudentLocation
  */
  func removeStudentLocationForObjectID(objectID: String) {
    for var i = 0; i < _locations.count; i++ {
      if objectID == _locations[i].objectID {
        _locations.removeAtIndex(i)
      }
    }
  }
  
}