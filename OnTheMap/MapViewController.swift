//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/16/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate
{
  @IBOutlet weak var mapView: MKMapView! {
    didSet {
     mapView.delegate = self 
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "dropPin")
    StudentLocationsGetSession.getStudentLocationsTask { (success, completionMessage) -> () in
      if !success {
        let errorActionSheet = UIAlertController(title: "Error", message: completionMessage, preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        errorActionSheet.addAction(cancel)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.presentViewController(errorActionSheet, animated: true, completion: nil)
        })
      } else {
        
      }
    }
  }
  
  func dropPin() {
    
  }

}
