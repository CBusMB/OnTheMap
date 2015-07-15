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
  var mapLocations = OnTheMapLocations.sharedCollection
  
  private var studentObjectIDs: [String]?
  private var userWantsToOverwriteLocation: Bool? {
    didSet {
      // as soon as the user confirms to overwrite / make new location, we "drop the pin" and segue to the next vc
      dropPin()
    }
  }
  
  @IBOutlet weak var mapView: MKMapView! {
    didSet {
      mapView.mapType = .Hybrid
      mapView.delegate = self
    }
  }
  
  // MARK: - Lifecycle
  
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
    if !mapLocations.locations.isEmpty {
      mapView.removeAnnotations(annotations)
      annotations.removeAll(keepCapacity: false)
      addLocationPinsToMap()
     }
  }
  
  // MARK: - Network calls
  
  func getStudentLocations() {
    if !annotations.isEmpty {
      mapLocations.removeAllLocations()
    }
    
    ParseAPISession.getStudentLocationsSession { (success, completionMessage) in
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
    mapView.removeAnnotations(annotations)
    for location in mapLocations.locations {
      let annotation = MKPointAnnotation()
      annotation.coordinate = location.coordinate
      annotation.title = "\(location.firstName) \(location.lastName)"
      annotation.subtitle = location.mediaURL
      annotations.append(annotation)
    }
    mapView.addAnnotations(annotations)
  }
  
  // MARK: - Navigation
  
  private func dropPin() {
    performSegueWithIdentifier(SegueIdentifierConstants.MapToPostSegue, sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierConstants.MapToPostSegue {
      let postInformationViewController = segue.destinationViewController as! PostInformationViewController
      postInformationViewController.userWantsToOverwriteLocation = userWantsToOverwriteLocation
      postInformationViewController.studentObjectIDs = studentObjectIDs
    }
  }
  
  func confirmUserWantsToOverwriteLocation() {
    let userName = NSUserDefaults.standardUserDefaults().stringForKey("userName")
    let studentExistsInCollection = mapLocations.uniqueIdForUserName(userName!)
    if studentExistsInCollection {
      let confirmationAlert = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionMessageOverwrite, preferredStyle: .Alert)
      let overwrite = UIAlertAction(title: AlertConstants.AlertActionOverwriteTitleConfirmation, style: .Default, handler: { Void in
          self.userWantsToOverwriteLocation = true })
      let addNewLocation = UIAlertAction(title: AlertConstants.AlertActionTitleNewLocation, style: .Default, handler: { Void in
          self.userWantsToOverwriteLocation = false })
      confirmationAlert.addAction(overwrite)
      confirmationAlert.addAction(addNewLocation)
      presentViewController(confirmationAlert, animated: true, completion: nil)
    } else {
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
    var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(MapViewConstants.ReuseIdentifier) as? MKPinAnnotationView
    
    if pinAnnotationView == nil {
      pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: MapViewConstants.ReuseIdentifier)
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
    let http = "http://"
    let googleSearch = "https://google.com/search?q="
    var urlString = view.annotation.subtitle!
    
    if !urlString.hasPrefix(https) && !urlString.hasPrefix(http) {
      urlString = googleSearch.stringByAppendingString(urlString)
    }
    
    if let studentURL = NSURL(string: urlString) {
      if control == view.rightCalloutAccessoryView {
        let application = UIApplication.sharedApplication()
        application.openURL(studentURL)
      }
    }
  }

}
