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
  
  private var userWantsToOverwriteLocation: Bool? {
    didSet {
      // as soon as the user confirms to overwrite or make new location, we "drop the pin" and segue to the next vc
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
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NavigationBarConstants.Logout, style: .Plain, target: self, action: "logout")
    let pin = UIBarButtonItem(image: UIImage(named: NavigationBarConstants.PinImage), style: .Plain, target: self, action: "confirmUserWantsToOverwriteLocation")
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
    if !mapLocations.locations.isEmpty {
      // clear the model array, annotations array, and mapView
      mapLocations.removeAllLocations()
      mapView.removeAnnotations(annotations)
      annotations.removeAll(keepCapacity: false)
    }
    
    ParseAPISession.getStudentLocationsSession { (success, completionMessage) in
      if !success {
        self.presentErrorAlert(completionMessage!)
      } else {
        dispatch_async(dispatch_get_main_queue(), { () in
          self.addLocationPinsToMap()
        })
      }
    }
  }
  
  func presentErrorAlert(message: String) {
    let errorAlert = UIAlertController(title: AlertConstants.AlertActionTitleError, message: message, preferredStyle: .Alert)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    errorAlert.addAction(cancel)
    dispatch_async(dispatch_get_main_queue(), { () in
      self.presentViewController(errorAlert, animated: true, completion: nil)
    })
  }
  
  private func addLocationPinsToMap() {
    annotations = mapLocations.locations.map {
      var annotation = MKPointAnnotation()
      annotation.coordinate = $0.coordinate
      annotation.title = "\($0.firstName) \($0.lastName)"
      annotation.subtitle = $0.mediaURL
      return annotation
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
    }
  }
  
  /**
  If the locations Array contains a location posted by the current user, confrim if the user wants to overwrite
  that location or POST a new location.  Setting the value of userWantsToOverwriteLocation initiates segue to next vc.
  */
  func confirmUserWantsToOverwriteLocation() {
    // get the persisted uniqueId
    let uniqueId = NSUserDefaults.standardUserDefaults().stringForKey("userId")
    let studentExistsInCollection = mapLocations.checkLocationsForMatchingUniqueId(uniqueId!)
    if studentExistsInCollection {
      presentOverwriteConfirmation()
    } else {
      userWantsToOverwriteLocation = false
    }
  }
  
  func presentOverwriteConfirmation() {
    let confirmationAlert = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionMessageOverwrite, preferredStyle: .Alert)
    let overwrite = UIAlertAction(title: AlertConstants.AlertActionOverwriteTitleConfirmation, style: .Default, handler: { Void in
      self.userWantsToOverwriteLocation = true })
    let addNewLocation = UIAlertAction(title: AlertConstants.AlertActionTitleNewLocation, style: .Default, handler: { Void in
      self.userWantsToOverwriteLocation = false })
    confirmationAlert.addAction(overwrite)
    confirmationAlert.addAction(addNewLocation)
    presentViewController(confirmationAlert, animated: true, completion: nil)
  }
  
  func logout() {
    let logoutActionSheet = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionMessageLogout, preferredStyle: .Alert)
    let logoutConfirmed = UIAlertAction(title: AlertConstants.AlertActionTitleLogout, style: .Destructive, handler: { Void in
      self.dismissViewControllerAnimated(true, completion: nil)
      self.mapLocations.removeAllLocations()
      self.annotations.removeAll(keepCapacity: false)
      self.deleteUserDefaults()	})
    logoutActionSheet.addAction(logoutConfirmed)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    logoutActionSheet.addAction(cancel)
    presentViewController(logoutActionSheet, animated: true, completion: nil)
  }
  
  func deleteUserDefaults() {
    let appDomain = NSBundle.mainBundle().bundleIdentifier
    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
  }
  
  // MARK: - MKMapViewDelegate
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(ReuseIdentifierConstants.ReuseIdentifier) as? MKPinAnnotationView
    
    if pinAnnotationView == nil {
      pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ReuseIdentifierConstants.ReuseIdentifier)
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
    // if the user did not enter a full URL, do a search with the mediaURL as the search term
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
