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
  var annotations = [MKPointAnnotation]()
  let mapLocations = OnTheMapLocations.sharedCollection
  var objectIdForUserName: String?
  var userWantsToOverwriteLocation: Bool? {
    didSet {
      dropPin()
    }
  }
  
  @IBOutlet weak var mapView: MKMapView! {
    didSet {
      mapView.mapType = .Satellite
      mapView.delegate = self
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NavigationItemConstants.Logout, style: .Plain, target: self, action: "logout")
    let pin = UIBarButtonItem(image: UIImage(named: ImageConstants.PinImage), style: .Plain, target: self, action: "confirmUserWantsToOverwriteLocation")
    let reload = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "getStudentLocations")
    var rightBarButtonItems = [reload, pin]
    navigationItem.rightBarButtonItems = rightBarButtonItems
    getStudentLocations()
  }
  
  func getStudentLocations() {
    if !annotations.isEmpty {
      mapView.removeAnnotations(annotations)
      mapLocations.removeAllLocations()
    }
    
    ParseAPISession.getStudentLocationsTask { (success, completionMessage) -> Void in
      if !success {
        let errorActionSheet = UIAlertController(title: ActionSheetConstants.AlertActionTitleError, message: completionMessage, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
        errorActionSheet.addAction(cancel)
        dispatch_async(dispatch_get_main_queue(), { () in
          self.presentViewController(errorActionSheet, animated: true, completion: nil)
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), { () in
          self.addLocationPinsToMap()
        })
      }
    }
  }
  
  private func addLocationPinsToMap() {
    for location in mapLocations.locationsCollection {
      let annotation = MKPointAnnotation()
      annotation.coordinate = location.coordinate
      annotation.title = "\(location.firstName) \(location.lastName)"
      annotation.subtitle = location.mediaURL
      annotations.append(annotation)
    }
    mapView.addAnnotations(annotations)
  }
  
  func dropPin() {
    performSegueWithIdentifier(SegueIdentifierConstants.MapToPostSegue, sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "mapToPost" {
      let postInformationViewController = segue.destinationViewController as! PostInformationViewController
      postInformationViewController.userWantsToOverwriteLocation = userWantsToOverwriteLocation
      postInformationViewController.objectIdForUserName = objectIdForUserName
    }
  }
  
  func confirmUserWantsToOverwriteLocation() {
    let userName = NSUserDefaults.standardUserDefaults().stringForKey("userName")
    let match = mapLocations.checkForMatchingObjectId(byUserName: userName!)
    if match.0 {
      objectIdForUserName = match.1!
      let confirmationAlert = UIAlertController(title: "Overwrite Location?", message: "You've already added a location to the map.  Do you want to overwrite it or add a new location?", preferredStyle: .Alert)
      let overwrite = UIAlertAction(title: "Overwrite", style: .Default, handler: { Void in
        self.userWantsToOverwriteLocation = true })
      let addNewLocation = UIAlertAction(title: "Add New Location", style: .Default, handler: { Void in
        self.userWantsToOverwriteLocation = false })
      confirmationAlert.addAction(overwrite)
      confirmationAlert.addAction(addNewLocation)
      presentViewController(confirmationAlert, animated: true, completion: nil)
    }
  }
  
  func logout() {
    let logoutActionSheet = UIAlertController(title: ActionSheetConstants.AlertActionTitleConfirmation, message: ActionSheetConstants.AlertActionMessageLogout, preferredStyle: .Alert)
    let logoutConfirmed = UIAlertAction(title: ActionSheetConstants.AlertActionTitleLogout, style: .Destructive, handler: { Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    self.mapLocations.removeAllLocations()
    self.annotations.removeAll(keepCapacity: false) })
    logoutActionSheet.addAction(logoutConfirmed)
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    logoutActionSheet.addAction(cancel)
    presentViewController(logoutActionSheet, animated: true, completion: nil)
  }
  
  // MARK: - MKMapViewDelegate
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    let reuseIdentifier = MapViewConstants.ReuseIdentifier
    var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
    
    if pinAnnotationView == nil {
      pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
      pinAnnotationView!.canShowCallout = true
      pinAnnotationView!.pinColor = .Red
      pinAnnotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
      pinAnnotationView?.animatesDrop = false
    }
    else {
      pinAnnotationView!.annotation = annotation
    }
    
    return pinAnnotationView
  }
  
  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    if let studentURL = NSURL(string: view.annotation.subtitle!) {
      if control == view.rightCalloutAccessoryView {
        let application = UIApplication.sharedApplication()
        application.openURL(studentURL)
      }
    }
  }

}
