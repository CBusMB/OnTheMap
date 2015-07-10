//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/16/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocation {
  let objectID: String?
  let uniqueKey: String
  let firstName: String
  let lastName: String
  let mapString: String
  let mediaURL: String
  let coordinate: CLLocationCoordinate2D
  
  init(nameAndLocation: NSDictionary) {
    objectID = nameAndLocation[ParseAPIConstants.ObjectIDKey] as? String
    uniqueKey = nameAndLocation[ParseAPIConstants.UniqueKeyKey] as! String
    firstName = nameAndLocation[ParseAPIConstants.FirstNameKey] as! String
    lastName = nameAndLocation[ParseAPIConstants.LastNameKey] as! String
    mapString = nameAndLocation[ParseAPIConstants.MapStringKey] as! String
    mediaURL = nameAndLocation[ParseAPIConstants.MediaURLKey] as! String
    coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(nameAndLocation[ParseAPIConstants.LatitudeKey] as! Double),
      longitude: CLLocationDegrees(nameAndLocation[ParseAPIConstants.LongitudeKey] as! Double))
  }
}



