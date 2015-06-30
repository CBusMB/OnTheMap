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
  
  // private array, accessed from locationsCollection
  private var locations = [StudentLocation]()
  
  var locationsCollection: [StudentLocation] {
    get {
      return locations
    }
  }
  
  func addLocationToCollection(location: StudentLocation) {
    locations.append(location)
  }
  
  func removeAllLocations() {
    locations.removeAll(keepCapacity: false)
  }
  
  func checkForMatchingObjectId(byUserName name: String) -> (Bool, String?) {
    var match = false
    var objectID: String?
    for student in locations {
      if name == student.uniqueKey {
        match = true
        objectID = student.objectID
        break
      }
    }
    return (match, objectID)
  }
  
  func removeStudentLocationForObjectID(objectID: String) {
    println("removing location")
    for var i = 0; i < locations.count; i++ {
      if objectID == locations[i].objectID {
        locations.removeAtIndex(i)
      }
    }
  }
  
}