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
      locationTextView.delegate = self
      let placeholderText = NSAttributedString(string: UserLocationTextAttributes.placeholder, attributes: UserLocationTextAttributes.Attributes)
      locationTextView.attributedText = placeholderText
    }
  }
  
  struct UserLocationTextAttributes {
    static let Attributes = [
      NSForegroundColorAttributeName: UIColor.blueColor(),
      NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 22)!
    ]
    static let placeholder = "Enter your location here"
  }

  @IBOutlet weak var searchButton: UIButton! {
    didSet {
      searchButton.layer.cornerRadius = 3.5
      searchButton.layer.borderWidth = 1.0
      searchButton.enabled = false
    }
  }
  @IBOutlet weak var submitButton: UIButton! {
    didSet {
      submitButton.hidden = true
    }
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    let singleTap = UITapGestureRecognizer(target: self, action: "singleTap:")
    view.addGestureRecognizer(singleTap)
    view.userInteractionEnabled = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  @IBAction func searchForStudentLocation() {
    geocodeUserLocation()
  }
  
  func geocodeUserLocation() {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(locationTextView.text, completionHandler: { (placemark, error) in
      if error != nil {
        self.presentErrorActionSheet()
      } else {
        if let placemarks = placemark as? [CLPlacemark] {
          if placemarks.count > 1 {
            self.presentLocationChoiceActionSheet(forLocations: placemarks)
          } else {
            let location = placemarks[0].location
            self.displayUserLocationMap(location)
          }
        } else {
          // handle downcast error
        }
      }
    })
  }
  
  func displayUserLocationMap(location: CLLocation) {
    updateUIForMapView()
    let regionCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let mapRegion = MKCoordinateRegion(center: regionCenter, span: MKCoordinateSpanMake(0.4, 0.4))
    mapView.setRegion(mapRegion, animated: true)
  }
  
  func updateUIForMapView() {
    mapView.hidden = false
    bottomView.hidden = true
    locationTextView.hidden = true
    mapView.addSubview(submitButton)
    mapView.bringSubviewToFront(submitButton)
    submitButton.hidden = false
    searchButton.hidden = true
  }
  
  func presentLocationChoiceActionSheet(forLocations placemarks: [CLPlacemark]) {
    // display (up to) the top 3 location mataches to the user and let them choose the best one
    let locationChoiceActionSheet = UIAlertController(title: ActionSheetConstants.AlertActionTitleMultipleMatches, message: ActionSheetConstants.AlertActionMessageChooseLocation, preferredStyle: .ActionSheet)
    
    let firstLocationAddressLines = placemarks[0].addressDictionary[ActionSheetConstants.AlertActionFormattedAddressLines] as! [String]
    let firstLocation = UIAlertAction(title: firstLocationAddressLines[0], style: .Default, handler: { Void in
      let location =  placemarks[0].location
      self.displayUserLocationMap(location) })
    locationChoiceActionSheet.addAction(firstLocation)
    
    let secondLocationAddressLines = placemarks[1].addressDictionary[ActionSheetConstants.AlertActionFormattedAddressLines] as! [String]
    let secondLocation = UIAlertAction(title: secondLocationAddressLines[0], style: .Default, handler: { Void in
      let location =  placemarks[1].location
      self.displayUserLocationMap(location) })
    locationChoiceActionSheet.addAction(secondLocation)
    
    if placemarks.count > 2 {
      let thirdLocationAddressLines = placemarks[2].addressDictionary[ActionSheetConstants.AlertActionFormattedAddressLines] as! [String]
      let thirdLocation = UIAlertAction(title: thirdLocationAddressLines[0], style: .Default, handler: { Void in
        let location =  placemarks[2].location
        self.displayUserLocationMap(location) })
      locationChoiceActionSheet.addAction(thirdLocation)
    }
    
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    locationChoiceActionSheet.addAction(cancel)
    
    presentViewController(locationChoiceActionSheet, animated: true, completion: nil)
  }
  
  func presentErrorActionSheet() {
    let errorActionSheet = UIAlertController(title: ErrorMessages.GenericErrorMessage, message: ErrorMessages.GeocodingErrorMessage, preferredStyle: .ActionSheet)
    let tryAgain = UIAlertAction(title: ActionSheetConstants.AlertActionTitleResubmit, style: .Default, handler: { Void in self.geocodeUserLocation() })
    errorActionSheet.addAction(tryAgain)
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    errorActionSheet.addAction(cancel)
    presentViewController(errorActionSheet, animated: true, completion:nil)
  }
  
  func resetUI() {
    
  }
  
  @IBAction func cancel(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: MKMapView
  
  
  // MARK: TextView Delegate
  func textViewShouldEndEditing(textView: UITextView) -> Bool {
    locationTextView.resignFirstResponder()
    searchButton.enabled = true
    return true
  }
  
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    textView.text = String()
    return true
  }
  
  func keyboardWillShow(notification: NSNotification) {
    self.view.frame.origin.y -= (keyboardHeight(notification) / 2)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    self.view.frame.origin.y += (keyboardHeight(notification) / 2)
  }
  
  func keyboardHeight(notification: NSNotification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    return keyboardSize.CGRectValue().height
  }
  
  func subscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func unsubscribeFromKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func subscribeToKeyboardWillShowNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
  }
  
  func unsubscribeFromKeyboardWillShowNotification() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
  }
  
  // MARK: Tap gesture recognizer
  func singleTap(recognizer: UITapGestureRecognizer) {
    if locationTextView.isFirstResponder() {
      // treat tapping the view as pressing return on the keyboard
      if recognizer.state == UIGestureRecognizerState.Ended {
        locationTextView.resignFirstResponder()
        searchButton.enabled = true
      }
    }
  }
  
}
