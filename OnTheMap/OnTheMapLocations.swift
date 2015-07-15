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
  /* Singleton. Use let xxx = OnTheMapLocations.sharedCollection to access OnTheMapLocations
  public properties and methods */
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
  
  func addLocationToCollection(location: StudentLocation) {
    // insert the student location at the end the array
    _locations.append(location)
  }
  
  func addLocationToBeginningOfCollection(location: StudentLocation) {
    // insert the student location at the beginning of the array
    // when the user adds/updates a location, use this method so
    // that the users name will be at the top of the table view
    _locations.insert(location, atIndex: 0)
  }
  
  func removeAllLocations() {
    _locations.removeAll(keepCapacity: false)
  }
  
  /// :param: userName is used as the uniqueKey when posting to the web service
  func uniqueIdForUserName(userName: String) -> Bool {
    var match = false
    for student in _locations {
      if userName == student.uniqueKey {
        match = true
        break
      }
    }
    return match
  }
  
  func removeStudentLocationForObjectID(objectID: String) {
    for var i = 0; i < _locations.count; i++ {
      if objectID == _locations[i].objectID {
        _locations.removeAtIndex(i)
      }
    }
  }
  
}