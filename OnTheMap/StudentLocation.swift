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
  let uniqueKey: String
  let firstName: String
  let lastName: String
  let mapString: String
  let mediaURL: String
  let coordinate: CLLocationCoordinate2D
  
  init(nameAndLocation: NSDictionary) {
    uniqueKey = nameAndLocation[ParseAPIConstants.UniqueKey] as! String
    firstName = nameAndLocation[ParseAPIConstants.FirstName] as! String
    lastName = nameAndLocation[ParseAPIConstants.LastName] as! String
    mapString = nameAndLocation[ParseAPIConstants.MapString] as! String
    mediaURL = nameAndLocation[ParseAPIConstants.MediaURL] as! String
    coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(nameAndLocation[ParseAPIConstants.Latitude] as! Double),
      longitude: CLLocationDegrees(nameAndLocation[ParseAPIConstants.Longitude] as! Double))
  }
}



