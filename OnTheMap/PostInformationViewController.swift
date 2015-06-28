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
  var userWantsToOverwriteLocation: Bool?
  var objectIdForUserName: String?
  
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
    }
  }
  
  func setAttributes(forButton button: UIButton, hiddenOnLoad: Bool) {
    button.layer.cornerRadius = 3.0
    button.layer.borderWidth = 0.7
    button.hidden = hiddenOnLoad
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    let singleTap = UITapGestureRecognizer(target: self, action: "singleTap:")
    view.addGestureRecognizer(singleTap)
    view.userInteractionEnabled = true
    println("\(userWantsToOverwriteLocation)")
  }
  
  @IBAction func unwindFromWebView(segue: UIStoryboardSegue) {
    let webViewController = segue.sourceViewController as! BrowseForURLViewController
    if let userSelectedURL = webViewController.webView.request?.URL?.absoluteString {
      urlTextView.text = userSelectedURL
    }
  }
  
  // MARK: MKMapView
  @IBAction func searchForStudentLocation() {
    geocodeUserLocation()
  }
  
  func geocodeUserLocation() {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(locationTextView.text, completionHandler: { (placemark, error) in
      if error != nil {
        self.presentErrorAlert()
      } else {
        if let placemarks = placemark as? [CLPlacemark] {
          if placemarks.count > 1 {
            self.presentLocationChoiceActionSheet(forLocations: placemarks)
          } else {
            let location = placemarks[0].location
            self.addUserLocationAnnotationToMap(atLocation: location)
          }
        } else {
          self.presentErrorAlert()
        }
      }
    })
  }
  
  func addUserLocationAnnotationToMap(atLocation location: CLLocation) {
    locationToSubmit = location
    let regionCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let mapRegion = MKCoordinateRegion(center: regionCenter, span: MKCoordinateSpanMake(0.25, 0.25))
    mapView.setRegion(mapRegion, animated: true)
    let annotation = MKPointAnnotation()
    annotation.coordinate = location.coordinate
    mapView.addAnnotation(annotation)
    updateUIForMapView()
  }
  
  func updateUIForMapView() {
    UIView.animateWithDuration(1.5, animations: {
      self.bottomView.alpha = -1.0
      self.locationTextView.alpha = -1.0
      self.searchButton.alpha = -1.0
      self.locationQuestionTopLabel.alpha = -1.0
      self.locationQuestionMiddleLabel.alpha = -1.0
      self.locationQuestionBottomLabel.alpha = -1.0 })
      { (finished) in
        if finished {
          self.bottomView.alpha = 1.0
          self.bottomView.backgroundColor = UIColor.clearColor()
          // self.bottomView.userInteractionEnabled = false
          self.bottomView.bringSubviewToFront(self.submitButton)
          self.locationTextView.hidden = true
          self.submitButton.hidden = false
          self.searchButton.hidden = true
          self.locationQuestionTopLabel.hidden = true
          self.locationQuestionMiddleLabel.hidden = true
          self.locationQuestionBottomLabel.hidden = true
          self.urlTextView.hidden = false
          self.browseWebButton.hidden = false
          self.mapView.hidden = false
        }
      }
  }
  
  @IBAction func submitLocationToServer() {
    println("submit information")
    println("\(userWantsToOverwriteLocation) user wants to overwrite")
    var alertTitleAndMessage: (String?, String?)
    if let overwrite = userWantsToOverwriteLocation {
      let studentInformationToPost = createStudentInformationDictionaryToPost()
      if overwrite {
        let putSessionURL = "https://api.parse.com/1/classes/StudentLocation/" + objectIdForUserName!
        ParseAPISession.putStudentLocationSession(studentInformationToPost, urlWithObjectId: putSessionURL) { (success, completionMessage) in
          println("\(success), \(completionMessage)")
          if !success {
            alertTitleAndMessage = ("Upload Failed", "Location Not Updated")
            println("\(alertTitleAndMessage.0)")
          } else {
            alertTitleAndMessage = completionMessage
            println("\(alertTitleAndMessage.0)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              let completionAlert = UIAlertController(title: alertTitleAndMessage.0, message: alertTitleAndMessage.1, preferredStyle: .Alert)
              let dismiss = UIAlertAction(title: "OK", style: .Default, handler: { Void in self.dismissViewControllerAnimated(true, completion: nil) })
              completionAlert.addAction(dismiss)
              self.presentViewController(completionAlert, animated: true, completion: nil)
            })
          }
        }
      } //else {
//        ParseAPISession.postStudentLocationSession(studentInformationToPost) { (success, message) in
//          if !success {
//            alertTitleAndMessage = ("Upload Failed", "Location Not Added")
//            
//          } else {
//            
//            alertTitleAndMessage = message
//            
//          }
//        }
//      }
//        println("\(alertTitleAndMessage.0)")
//        let completionAlert = UIAlertController(title: alertTitleAndMessage.0, message: alertTitleAndMessage.1, preferredStyle: .Alert)
//        let dismiss = UIAlertAction(title: "OK", style: .Default, handler: { Void in self.dismissViewControllerAnimated(true, completion: nil) })
//        completionAlert.addAction(dismiss)
//        presentViewController(completionAlert, animated: true, completion: nil)
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
      self.addUserLocationAnnotationToMap(atLocation: location) })
    locationChoiceActionSheet.addAction(firstLocation)
    
    let secondLocationAddressLines = placemarks[1].addressDictionary[ActionSheetConstants.AlertActionFormattedAddressLines] as! [String]
    let secondLocation = UIAlertAction(title: secondLocationAddressLines[0], style: .Default, handler: { Void in
      let location =  placemarks[1].location
      self.addUserLocationAnnotationToMap(atLocation: location) })
    locationChoiceActionSheet.addAction(secondLocation)
    
    if placemarks.count > 2 {
      let thirdLocationAddressLines = placemarks[2].addressDictionary[ActionSheetConstants.AlertActionFormattedAddressLines] as! [String]
      let thirdLocation = UIAlertAction(title: thirdLocationAddressLines[0], style: .Default, handler: { Void in
        let location =  placemarks[2].location
        self.addUserLocationAnnotationToMap(atLocation: location) })
      locationChoiceActionSheet.addAction(thirdLocation)
    }
    
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    locationChoiceActionSheet.addAction(cancel)
    
    presentViewController(locationChoiceActionSheet, animated: true, completion: nil)
  }
  
  func presentErrorAlert() {
    let errorActionSheet = UIAlertController(title: ErrorMessages.GenericErrorMessage, message: ErrorMessages.GeocodingErrorMessage, preferredStyle: .Alert)
    let tryAgain = UIAlertAction(title: ActionSheetConstants.AlertActionTitleResubmit, style: .Default, handler: { Void in self.geocodeUserLocation() })
    errorActionSheet.addAction(tryAgain)
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    errorActionSheet.addAction(cancel)
    presentViewController(errorActionSheet, animated: true, completion:nil)
  }
  
  func resetUI() {
    bottomView.alpha = 1.0
    locationTextView.alpha = 1.0
    searchButton.alpha = 1.0
    locationQuestionTopLabel.alpha = 1.0
    locationQuestionMiddleLabel.alpha = 1.0
    locationQuestionBottomLabel.alpha = 1.0
    mapView.hidden = true
    bottomView.backgroundColor = self.topView.backgroundColor
    bottomView.userInteractionEnabled = true
    locationTextView.hidden = false
    submitButton.hidden = true
    searchButton.hidden = false
    locationQuestionTopLabel.hidden = false
    locationQuestionMiddleLabel.hidden = false
    locationQuestionBottomLabel.hidden = false
    urlTextView.hidden = true
    browseWebButton.hidden = true
  }
  
  @IBAction func cancel(sender: UIButton) {
    if mapView.hidden {
      dismissViewControllerAnimated(true, completion: nil)
    } else {
      resetUI()
    }
  }
  
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
