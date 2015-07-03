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
  private var userWantsToOverwriteLocation: Bool? {
    didSet {
      // as soon as the user confirms to overwrite / make new location, we "drop the pin" and segue to the next vc
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
    // start the network session to pull in the student location data as soon as the view loads
    getStudentLocations()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // locationsCollection is empty first time the view loads / appears.  When returning from posting a new location,
    // addLocationPinsToMap will add the new location to the map without going out to the network
    if !mapLocations.locationsCollection.isEmpty {
      addLocationPinsToMap()
    }
  }
  
  func getStudentLocations() {
    if !annotations.isEmpty {
      mapView.removeAnnotations(annotations)
      mapLocations.removeAllLocations()
    }
    
    ParseAPISession.getStudentLocationsTask { (success, completionMessage) -> Void in
      if !success {
        let errorAlert = UIAlertController(title: AlertConstants.AlertActionTitleError, message: completionMessage, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
        errorAlert.addAction(cancel)
        dispatch_async(dispatch_get_main_queue(), { () in
          self.presentViewController(errorAlert, animated: true, completion: nil)
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
    let objectId = mapLocations.checkForMatchingObjectId(byUserName: userName!)
    if objectId.0 {
      objectIdForUserName = objectId.1!
      let confirmationAlert = UIAlertController(title: "Overwrite Location?", message: "You've already added a location to the map.  Do you want to overwrite it or add a new location?", preferredStyle: .Alert)
      let overwrite = UIAlertAction(title: "Overwrite", style: .Default, handler: { Void in
        self.userWantsToOverwriteLocation = true })
      let addNewLocation = UIAlertAction(title: "Add New Location", style: .Default, handler: { Void in
        self.userWantsToOverwriteLocation = false })
      confirmationAlert.addAction(overwrite)
      confirmationAlert.addAction(addNewLocation)
      presentViewController(confirmationAlert, animated: true, completion: nil)
    } else {
      // setting userWantsToOverwriteLocation to false initiates segue
      userWantsToOverwriteLocation = false
    }
  }
  
  func logout() {
    let logoutActionSheet = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionMessageLogout, preferredStyle: .Alert)
    let logoutConfirmed = UIAlertAction(title: AlertConstants.AlertActionTitleLogout, style: .Destructive, handler: { Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    self.mapLocations.removeAllLocations()
    self.annotations.removeAll(keepCapacity: false) })
    logoutActionSheet.addAction(logoutConfirmed)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
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
    let https = "https://"
    let www = "www."
    var urlString = view.annotation.subtitle!
    if !urlString.hasPrefix(www) {
      urlString = www.stringByAppendingString(view.annotation.subtitle!)
    }
    if !urlString.hasPrefix(https) {
      urlString = https.stringByAppendingString(urlString)
    }
    
    println("\(urlString)")
    if let studentURL = NSURL(string: urlString) {
      println("\(studentURL)")
      if control == view.rightCalloutAccessoryView {
        let application = UIApplication.sharedApplication()
        application.openURL(studentURL)
      }
    }
  }

}
