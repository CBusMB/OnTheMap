//
//  PostInformationViewController.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/19/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import UIKit
import MapKit

class PostInformationViewController: UIViewController, MKMapViewDelegate
{

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self , action: "cancelPost")
  }
  
  
}
