//
//  PostInformationViewController.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/19/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import UIKit
import MapKit

class PostInformationViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate
{
  @IBOutlet weak var mapView: MKMapView! {
    didSet {
      mapView.hidden = true
      mapView.delegate = self
    }
  }

  @IBOutlet weak var locationQuestionTopLabel: UILabel!
  @IBOutlet weak var locationQuestionMiddleLabel: UILabel!
  @IBOutlet weak var locationQuestionBottomLabel: UILabel!
  
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var bottomView: UIView!
  
  @IBOutlet weak var locationTextView: UITextView! {
    didSet {
      let singleTap = UITapGestureRecognizer(target: self, action: "singleTap:")
      view.addGestureRecognizer(singleTap)
      view.userInteractionEnabled = true
    }
  }
  
  @IBOutlet weak var searchAndSubmitButton: UIButton! {
    didSet {
      searchAndSubmitButton.layer.cornerRadius = 3.5
      searchAndSubmitButton.layer.borderWidth = 1.0
      searchAndSubmitButton.enabled = false
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func searchForStudentLocation(sender: AnyObject) {
    geocodeUserLocation()
  }
  
  func geocodeUserLocation() {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(locationTextView.text, completionHandler: { (placemark, error) in
      if error != nil {
        self.presentErrorActionSheet()
      } else {
        if let placemarks = placemark as? [CLPlacemark] {
          self.validateUserLocations(fromLocationsInPlacemarks: placemarks)
        }
      }
      
    })
  }
  
  private func validateUserLocations(fromLocationsInPlacemarks placemarks: [CLPlacemark]) {
    if placemarks.count > 1 {
      presentLocationChoiceActionSheet(forLocations: placemarks)
    } else {
      let location = placemarks[0].location
      displayUserLocationMap(location)
    }
  }
  
  func displayUserLocationMap(location: CLLocation) {
    
  }
  
  func presentLocationChoiceActionSheet(forLocations placemarks: [CLPlacemark]) {
    // display the top 3 location mataches to the user and let them choose the best one
    let firstCityName = placemarks[0].locality
    let secondCityName = placemarks[1].locality
    let thirdCityName = placemarks[2].locality
    let locationChoiceActionSheet = UIAlertController(title: ActionSheetConstants.AlertActionTitleMultipleMatches, message: ActionSheetConstants.AlertActionMessageChooseLocation, preferredStyle: .ActionSheet)
    let firstLocation = UIAlertAction(title: firstCityName, style: .Default, handler: { Void in
      let location =  placemarks[0].location
      self.displayUserLocationMap(location) })
    locationChoiceActionSheet.addAction(firstLocation)
    let secondLocation = UIAlertAction(title: secondCityName, style: .Default, handler: { Void in
      let location =  placemarks[1].location
      self.displayUserLocationMap(location) })
    locationChoiceActionSheet.addAction(secondLocation)
    let thirdLocation = UIAlertAction(title: thirdCityName, style: .Default, handler: { Void in
      let location =  placemarks[2].location
      self.displayUserLocationMap(location) })
    locationChoiceActionSheet.addAction(thirdLocation)
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    locationChoiceActionSheet.addAction(cancel)
  }
  
  func presentErrorActionSheet() {
    let errorActionSheet = UIAlertController(title: ErrorMessages.GenericErrorMessage, message: ErrorMessages.NetworkErrorMessage, preferredStyle: .ActionSheet)
    let tryAgain = UIAlertAction(title: ActionSheetConstants.AlertActionTitleResubmit, style: .Default, handler: { Void in self.geocodeUserLocation() })
    errorActionSheet.addAction(tryAgain)
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    errorActionSheet.addAction(cancel)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.presentViewController(errorActionSheet, animated: true, completion: { Void in self.resetUI() })
    })
  }
  
  func resetUI() {
    
  }

  @IBAction func cancel(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: MKMapViewDelegate
  
  
  // MARK: Tap gesture recognizer
  func singleTap(recognizer: UITapGestureRecognizer) {
    if locationTextView.isFirstResponder() {
      // treat tapping the view as pressing return on the keyboard
      if recognizer.state == UIGestureRecognizerState.Ended {
        locationTextView.resignFirstResponder()
        searchAndSubmitButton.enabled = true
      }
    }
  }
  
  
}
