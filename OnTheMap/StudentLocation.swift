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
}

