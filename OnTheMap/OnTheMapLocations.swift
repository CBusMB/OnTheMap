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
    // insert the student location into the array
    _locations.append(location)
  }
  
  func removeAllLocations() {
    _locations.removeAll(keepCapacity: false)
  }
  
  func uniqueIdForUserName(name: String) -> Bool {
    var match = false
    for student in _locations {
      if name == student.uniqueKey {
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