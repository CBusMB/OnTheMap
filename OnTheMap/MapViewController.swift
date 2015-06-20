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
  
  @IBOutlet weak var mapView: MKMapView! {
    didSet {
     mapView.delegate = self 
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NavigationItemConstants.logout, style: .Plain, target: self, action: "logout")
    let pin = UIBarButtonItem(image: UIImage(named: ImageConstants.pinImage), style: .Plain, target: self, action: "dropPin")
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
    
    StudentLocationsGetSession.getStudentLocationsTask { (success, completionMessage) -> () in
      if !success {
        let errorActionSheet = UIAlertController(title: "Error", message: completionMessage, preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: ActionSheetConstants.alertActionTitleCancel, style: .Cancel, handler: nil)
        errorActionSheet.addAction(cancel)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.presentViewController(errorActionSheet, animated: true, completion: nil)
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
      mapView.addAnnotations(annotations)
    }
  }
  
  func dropPin() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let postInformationViewController = storyboard.instantiateViewControllerWithIdentifier("postInformationViewController") as! PostInformationViewController
    navigationController?.pushViewController(postInformationViewController, animated: true)
  }
  
  func logout() {
    let logoutActionSheet = UIAlertController(title: ActionSheetConstants.alertActionTitleConfirmation, message: ActionSheetConstants.alertActionMessageLogout, preferredStyle: .ActionSheet)
    let logoutConfirmed = UIAlertAction(title: ActionSheetConstants.alertActionTitleLogout, style: .Destructive, handler: { Void in
      self.dismissViewControllerAnimated(true, completion: nil) })
    logoutActionSheet.addAction(logoutConfirmed)
    let cancel = UIAlertAction(title: ActionSheetConstants.alertActionTitleCancel, style: .Cancel, handler: nil)
    logoutActionSheet.addAction(cancel)
    presentViewController(logoutActionSheet, animated: true, completion: nil)
  }
  
  // MARK: - MKMapViewDelegate
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    let reuseIdentifier = MapViewConstants.reuseIdentifier
    var pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
    
    if pinAnnotationView == nil {
      pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
      pinAnnotationView!.canShowCallout = true
      pinAnnotationView!.pinColor = .Red
      pinAnnotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
      pinAnnotationView?.animatesDrop = true
    }
    else {
      pinAnnotationView!.annotation = annotation
    }
    
    return pinAnnotationView
  }
  
//  func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
//    let annotationViews = views as! [MKAnnotationView]
//    for annotationView in annotationViews {
//      let mapPoint = MKMapPointForCoordinate(annotationView.annotation.coordinate)
//      if !MKMapRectContainsPoint(mapView.visibleMapRect, mapPoint) {
//        mapView.removeAnnotation(annotationView.annotation)
//      }
//    }
//  }
//  
//  func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
//    addLocationPinsToMap()
//  }
  
  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    if let studentURL = NSURL(string: view.annotation.subtitle!) {
      if control == view.rightCalloutAccessoryView {
        let application = UIApplication.sharedApplication()
        application.openURL(studentURL)
      }
    }
  }

}
