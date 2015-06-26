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
  var locationToSubmit: CLLocation?
  
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
      let placeholderText = NSAttributedString(string: AttributedStringAttributes.locationPlaceholder, attributes: AttributedStringAttributes.TextFieldTextAttributes)
      locationTextView.attributedText = placeholderText
      setAttributes(forTextView: locationTextView, hiddenOnLoad: false)
    }
  }
  
  @IBOutlet weak var urlTextView: UITextView! {
    didSet {
      let placeholderText = NSAttributedString(string: AttributedStringAttributes.urlPlaceholder, attributes: AttributedStringAttributes.TextFieldTextAttributes)
      urlTextView.attributedText = placeholderText
      setAttributes(forTextView: urlTextView, hiddenOnLoad: true)
    }
  }
  
  func setAttributes(forTextView textView: UITextView, hiddenOnLoad: Bool) {
    textView.delegate = self
    textView.textAlignment = .Center
    textView.backgroundColor = UIColor.clearColor()
    textView.hidden = hiddenOnLoad
  }
  
  struct AttributedStringAttributes {
    static let TextFieldTextAttributes = [
      NSForegroundColorAttributeName : UIColor.whiteColor(),
      NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 22)!
    ]
    static let locationPlaceholder = "Enter your location here"
    static let urlPlaceholder = "Please tap here to enter a URL"
    static let TopLabelTextAttributes = [
      
    ]
  }

  @IBOutlet weak var searchButton: UIButton! {
    didSet {
      setAttributes(forButton: searchButton, hiddenOnLoad: false)
    }
  }
  
  @IBOutlet weak var submitButton: UIButton! {
    didSet {
      setAttributes(forButton: submitButton, hiddenOnLoad: true)
    }
  }
  
  @IBOutlet weak var browseWebButton: UIButton! {
    didSet {
      setAttributes(forButton: browseWebButton, hiddenOnLoad: true)
      browseWebButton.layer.borderWidth = 0.0
    }
  }
  
  func setAttributes(forButton button: UIButton, hiddenOnLoad: Bool) {
    button.layer.cornerRadius = 3.5
    button.layer.borderWidth = 1.0
    button.hidden = hiddenOnLoad
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
    locationToSubmit = location
    updateUIForMapView()
    let regionCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let mapRegion = MKCoordinateRegion(center: regionCenter, span: MKCoordinateSpanMake(0.25, 0.25))
    mapView.setRegion(mapRegion, animated: true)
    let annotation = MKPointAnnotation()
    annotation.coordinate = location.coordinate
    mapView.addAnnotation(annotation)
  }
  
  func updateUIForMapView() {
    mapView.hidden = false
    bottomView.backgroundColor = UIColor.clearColor()
    bottomView.userInteractionEnabled = false
    locationTextView.hidden = true
    bottomView.addSubview(submitButton)
    bottomView.bringSubviewToFront(submitButton)
    submitButton.hidden = false
    searchButton.hidden = true
    locationQuestionTopLabel.hidden = true
    locationQuestionMiddleLabel.hidden = true
    locationQuestionBottomLabel.hidden = true
    urlTextView.hidden = false
    browseWebButton.hidden = false
  }
  
  @IBAction func submitLocationToServer() {
    let studentInformationToPost = createStudentInformationDictionaryToPost()
    StudentLocationPostSession.postStudentLocationSession(studentInformationToPost) { (success, completionMessage) in
      if !success {
        if let message = completionMessage {
          println("Error")
        }
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.dismissViewControllerAnimated(true, completion: nil)
        })
      }
    }
  }
  
  func createStudentInformationDictionaryToPost() -> NSDictionary {
    let defaults = NSUserDefaults.standardUserDefaults()
    let udacityUserName = defaults.stringForKey("userName")
    
    var urlToSubmit: String
    if urlTextView.text == AttributedStringAttributes.urlPlaceholder {
      urlToSubmit = DefaultStudentInformationConstants.UdacityHomePage
    } else {
      urlToSubmit = urlTextView.text
    }
    
    let studentInformation = NSDictionary(dictionary: [
      ParseAPIConstants.UniqueKey : udacityUserName!,
      ParseAPIConstants.FirstName : NameConstants.FirstName,
      ParseAPIConstants.LastName : NameConstants.LastName,
      ParseAPIConstants.MapString : locationTextView.text,
      ParseAPIConstants.MediaURL : urlToSubmit,
      ParseAPIConstants.Latitude : locationToSubmit!.coordinate.latitude,
      ParseAPIConstants.Longitude : locationToSubmit!.coordinate.longitude
      ])
    
    return studentInformation
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
    let errorActionSheet = UIAlertController(title: ErrorMessages.GenericErrorMessage, message: ErrorMessages.GeocodingErrorMessage, preferredStyle: .Alert)
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
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      searchButton.enabled = true
      return false
    }
    return true
  }
  
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    textView.text = String()
    return true
  }
  
  func keyboardWillShow(notification: NSNotification) {
    //self.view.frame.origin.y -= (keyboardHeight(notification) / 2)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    //self.view.frame.origin.y += (keyboardHeight(notification) / 2)
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
