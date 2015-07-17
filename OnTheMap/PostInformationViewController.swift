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
  let mapLocations = OnTheMapLocations.sharedCollection
  var locationToSubmit: CLLocation?
  var userWantsToOverwriteLocation: Bool? {
    didSet {
      // if this var is set to TRUE we do a background fetch of the objectIDs for the userName
      if userWantsToOverwriteLocation == true {
        ParseAPISession.queryStudentLocationSession(byUserId: NSUserDefaults.standardUserDefaults().stringForKey("userId")!) { (success, objectIDs) in
          if success {
            self.studentObjectIDs = objectIDs
          } else {
            self.presentNetworkErrorAlert()
          }
        }
      }
    }
  }
  
  var studentObjectIDs: [String]?
  
  private func presentNetworkErrorAlert() {
    let errorActionSheet = UIAlertController(title: ErrorMessages.GenericErrorMessage, message: ErrorMessages.NetworkErrorMessage, preferredStyle: .Alert)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleOK, style: .Default) { Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    errorActionSheet.addAction(cancel)
    presentViewController(errorActionSheet, animated: true, completion:nil)
  }
  
  @IBOutlet weak var mapView: MKMapView! {
    didSet {
      mapView.hidden = true
      mapView.delegate = self
    }
  }
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  @IBOutlet weak var locationQuestionTopLabel: UILabel! {
    didSet {
      let text = NSAttributedString(string: AttributedStringAttributes.LocationQuestionTop, attributes: AttributedStringAttributes.TopLabelsTextAttributes)
      locationQuestionTopLabel.attributedText = text
    }
  }
  @IBOutlet weak var locationQuestionMiddleLabel: UILabel! {
    didSet {
      let text = NSAttributedString(string: AttributedStringAttributes.LocationQuestionMiddle, attributes: AttributedStringAttributes.TopLabelsTextAttributes)
      locationQuestionMiddleLabel.attributedText = text
    }
  }
  @IBOutlet weak var locationQuestionBottomLabel: UILabel! {
    didSet {
      let text = NSAttributedString(string: AttributedStringAttributes.LocationQuestionBottom, attributes: AttributedStringAttributes.TopLabelsTextAttributes)
      locationQuestionBottomLabel.attributedText = text
    }
  }
  
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var bottomView: UIView!
  
  @IBOutlet weak var locationTextView: UITextView! {
    didSet {
      let placeholderText = NSAttributedString(string: AttributedStringAttributes.LocationPlaceholder, attributes: AttributedStringAttributes.TextFieldTextAttributes)
      locationTextView.attributedText = placeholderText
      setAttributes(forTextView: locationTextView, hiddenOnLoad: false)
    }
  }
  
  @IBOutlet weak var urlTextView: UITextView! {
    didSet {
      let placeholderText = NSAttributedString(string: AttributedStringAttributes.UrlPlaceholder, attributes: AttributedStringAttributes.TextFieldTextAttributes)
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
    static let LocationPlaceholder = "Enter your location here"
    static let UrlPlaceholder = "Please tap here to enter a URL"
    static let TopLabelsTextAttributes = [
      NSForegroundColorAttributeName : UIColor.yellowColor(),
      NSFontAttributeName : UIFont(name: "Helvetica-Bold", size: 20)!
    ]
    static let LocationQuestionTop = "Where are you"
    static let LocationQuestionMiddle = "studying"
    static let LocationQuestionBottom = "today?"
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
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    let singleTap = UITapGestureRecognizer(target: self, action: "singleTap:")
    view.addGestureRecognizer(singleTap)
    view.userInteractionEnabled = true
  }
  
  @IBAction func unwindFromWebView(segue: UIStoryboardSegue) {
    let webViewController = segue.sourceViewController as! BrowseForURLViewController
    if let userSelectedURL = webViewController.webView.request?.URL?.absoluteString {
      urlTextView.text = userSelectedURL
    }
  }
  
  // MARK: - MKMapView
  @IBAction func searchForStudentLocation() {
    geocodeUserLocation()
  }
  
  private func geocodeUserLocation() {
    activityIndicator.startAnimating()
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(locationTextView.text, completionHandler: { (placemark, error) in
      if error != nil {
        self.presentGeocodeErrorAlert()
      } else {
        if let placemarks = placemark as? [CLPlacemark] {
          if placemarks.count > 1 {
            self.presentLocationChoiceActionSheet(forLocations: placemarks)
          } else {
            let location = placemarks[0].location
            self.addUserLocationAnnotationToMap(atLocation: location)
          }
        } else {
          self.presentGeocodeErrorAlert()
        }
      }
    })
  }
  
  private func presentGeocodeErrorAlert() {
    activityIndicator.stopAnimating()
    let errorActionSheet = UIAlertController(title: ErrorMessages.GenericErrorMessage, message: ErrorMessages.GeocodingErrorMessage, preferredStyle: .Alert)
    let tryAgain = UIAlertAction(title: AlertConstants.AlertActionTitleResubmit, style: .Default, handler: { Void in self.geocodeUserLocation() })
    errorActionSheet.addAction(tryAgain)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    errorActionSheet.addAction(cancel)
    presentViewController(errorActionSheet, animated: true, completion:nil)
  }
  
  /**
  Display an action sheet to let the user choose the best location for what the CLGeocoder returned
  :param: placemarks    An array of CLPlacemarks returned from the CLGeocoder
  */
  private func presentLocationChoiceActionSheet(forLocations placemarks: [CLPlacemark]) {
    let locationChoiceActionSheet = UIAlertController(title: AlertConstants.AlertActionTitleMultipleMatches, message: AlertConstants.AlertActionMessageChooseLocation, preferredStyle: .ActionSheet)
    
    let firstLocationAddressLines = placemarks[0].addressDictionary[AlertConstants.AlertActionFormattedAddressLines] as! [String]
    let firstLocation = UIAlertAction(title: "\(firstLocationAddressLines[0], firstLocationAddressLines[1])", style: .Default, handler: { Void in
      let location = placemarks[0].location
      self.addUserLocationAnnotationToMap(atLocation: location) })
    locationChoiceActionSheet.addAction(firstLocation)
    
    let secondLocationAddressLines = placemarks[1].addressDictionary[AlertConstants.AlertActionFormattedAddressLines] as! [String]
    let secondLocation = UIAlertAction(title: "\(secondLocationAddressLines[0], secondLocationAddressLines[1])", style: .Default, handler: { Void in
      let location = placemarks[1].location
      self.addUserLocationAnnotationToMap(atLocation: location) })
    locationChoiceActionSheet.addAction(secondLocation)
    
    if placemarks.count > 2 {
      let thirdLocationAddressLines = placemarks[2].addressDictionary[AlertConstants.AlertActionFormattedAddressLines] as! [String]
      let thirdLocation = UIAlertAction(title: "\(thirdLocationAddressLines[0], thirdLocationAddressLines[1])", style: .Default, handler: { Void in
        let location = placemarks[2].location
        self.addUserLocationAnnotationToMap(atLocation: location) })
      locationChoiceActionSheet.addAction(thirdLocation)
    }
    
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: { Void in
      self.activityIndicator.stopAnimating() })
    locationChoiceActionSheet.addAction(cancel)
    
    presentViewController(locationChoiceActionSheet, animated: true, completion: nil)
  }
  
  private func addUserLocationAnnotationToMap(atLocation location: CLLocation) {
    // assign the location from the geocode to the locationToSubmit instance variable
    locationToSubmit = location
    let regionCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    let mapRegion = MKCoordinateRegion(center: regionCenter, span: MKCoordinateSpanMake(0.25, 0.25))
    mapView.setRegion(mapRegion, animated: true)
    let annotation = MKPointAnnotation()
    annotation.coordinate = location.coordinate
    mapView.addAnnotation(annotation)
    updateUIForMapView()
  }
  
  // MARK: - POST / PUT calls to web service
  @IBAction func submitLocationToServer() {
    if let overwrite = userWantsToOverwriteLocation {
      // create the parameters needed to post / put to the server
      let studentInformationWithoutObjectIdToPost = createStudentInformationDictionaryWithoutObjectId()
      if overwrite { // call the PUT method
        updateStudentLocationOnServer(fromStudentInformation: studentInformationWithoutObjectIdToPost)
      } else { // call the POST method
        createNewStudentLocationOnServer(fromStudentInformation: studentInformationWithoutObjectIdToPost)
      }
    }
  }
  
  /**
  Prepare the parameters needed for the PUT session and then call the appropriate ParseAPI session method
  
  :param: studentInformation    An NSMutableDictionary containing the nessecary paramenters for the PUT session
  */
  private func updateStudentLocationOnServer(fromStudentInformation studentInformation: NSMutableDictionary) {
    if studentInformation[ParseAPIConstants.MediaURLKey] as! String == AttributedStringAttributes.UrlPlaceholder {
      displayUrlRequiredAlert()
    } else {
      /// The objectId for the object to be updated
      let objectId = studentObjectIDs?.last
      // add the "/" before the objectId and then add it to the Parse URL
      let objectIdForURL = "/" + objectId!
      let putSessionURL = ParseAPIConstants.ParseURL + objectIdForURL
      ParseAPISession.putStudentLocationSession(studentInformation, urlWithObjectId: putSessionURL) { (success, completionMessage) in
        if success {
          /// An NSDictionary with the objectID included.  This is not needed for the PUT parameters but it is used to identify the correct object in the local data model
          let studentInformationWithObjectID = self.createStudentInformationDictionary(fromDictionary: studentInformation, withObjectId: objectId!)
          /// A StudentLocation struct created from the studentInformationWithObjectID NSDictionary
          let studentLocation = StudentLocation(nameAndLocation: studentInformationWithObjectID)
          // remove any locations in the collection that have the same objectID as the location
          // that was just posted
          self.mapLocations.removeStudentLocationForObjectID(studentLocation.objectID!)
          // add the StudentLocation to the beginning of the collection so that it will be at the top of the table view
          self.mapLocations.addLocationToBeginningOfCollection(studentLocation)
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.displayPostInformationCompletionMessage(completionMessage, forSuccessfulOrFailedSession: success)
        })
      }
    }
  }
  
  /**
  Prepare the parameters needed for the POST session and then call the appropriate ParseAPI session method
  
  :param: studentInformation    An NSMutableDictionary containing the nessecary paramenters for the POST session
  */
  private func createNewStudentLocationOnServer(fromStudentInformation studentInformation: NSMutableDictionary) {
    if studentInformation[ParseAPIConstants.MediaURLKey] as! String == AttributedStringAttributes.UrlPlaceholder {
      displayUrlRequiredAlert()
    } else {
      ParseAPISession.postStudentLocationSession(studentInformation) { (success, completionMessage) in
        if success {
          let uniqueKey = studentInformation[ParseAPIConstants.UniqueKeyKey] as! String
          ParseAPISession.queryStudentLocationSession(byUserId: uniqueKey) { (querySuccess, objectIDs) in
            if querySuccess {
              /// The objectId for the object that was just POSTed
              let justPostedObjectID = objectIDs!.last
              /// An NSDictionary with the objectID included.  This is not needed for the POST parameters but it is used to identify the correct object in the local data model
              let studentInformationWithObjectID = self.createStudentInformationDictionary(fromDictionary: studentInformation, withObjectId: justPostedObjectID!)
              /// A StudentLocation struct created from the studentInformationWithObjectID NSDictionary
              let studentLocation = StudentLocation(nameAndLocation: studentInformationWithObjectID)
              // add the StudentLocation to the beginning of the collection so that it will be at the top of the table view
              self.mapLocations.addLocationToBeginningOfCollection(studentLocation)
            }
          }
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.displayPostInformationCompletionMessage(completionMessage, forSuccessfulOrFailedSession: success)
        })
      }
    }
  }
  
  /**
  Create an NSDictionary containing the parameters needed to POST or PUT the student location information plus an objectId parameter used in the local data model
  
  :param: studentInformation    An NSMutableDictionary containing the nessecary paramenters for the POST/PUT session
  :param: objectId    the objectId of the object we want to work with
  :returns: A new NSDictionary containing key value pairs that mirror what is returned in JSON from the web service
  */
  private func createStudentInformationDictionary(fromDictionary studentInformation: NSMutableDictionary, withObjectId objectId: String) -> NSDictionary {
    studentInformation.setValue(objectId, forKey: ParseAPIConstants.ObjectIDKey)
    let studentInformationWithObjectID = NSDictionary(dictionary: studentInformation)
    return studentInformationWithObjectID
  }
  
  /**
  Create an NSMutableDictionary containing the parameters needed to POST or PUT the student location information
  
  :returns: A new NSMutableDictionary containing key value pairs required for the POST or PUT session
  */
  private func createStudentInformationDictionaryWithoutObjectId() -> NSMutableDictionary {
    // get persisted values from NSUserDefaults
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let studentInformation = NSMutableDictionary(dictionary: [
      ParseAPIConstants.UniqueKeyKey : defaults.stringForKey("userId")!,
      ParseAPIConstants.FirstNameKey : defaults.stringForKey("firstName")!,
      ParseAPIConstants.LastNameKey : defaults.stringForKey("lastName")!,
      ParseAPIConstants.MapStringKey : locationTextView.text,
      ParseAPIConstants.MediaURLKey : urlTextView.text,
      ParseAPIConstants.LatitudeKey : locationToSubmit!.coordinate.latitude,
      ParseAPIConstants.LongitudeKey : locationToSubmit!.coordinate.longitude
      ])
    // return an NSMutableDictionary so that we can add the objectID to it later
    return studentInformation
  }
  
  private func displayPostInformationCompletionMessage(message: (String?, String?), forSuccessfulOrFailedSession success: Bool) {
    let completionAlert = UIAlertController(title: message.0, message: message.1, preferredStyle: .Alert)
    if success {
      let dismiss = UIAlertAction(title: AlertConstants.AlertActionTitleOK, style: .Default, handler: { Void in
        self.dismissViewControllerAnimated(true, completion: nil) })
      completionAlert.addAction(dismiss)
    } else {
      let dismiss = UIAlertAction(title: AlertConstants.AlertActionTitleOK, style: .Default, handler: nil)
      completionAlert.addAction(dismiss)
    }
    self.presentViewController(completionAlert, animated: true, completion: nil)
  }
  
  func displayUrlRequiredAlert() {
    let urlAlert = UIAlertController(title: AlertConstants.AlertActionTitleUrlRequired, message: AlertConstants.AlertActionMessageUrlRequired, preferredStyle: .Alert)
    let dismiss = UIAlertAction(title: AlertConstants.AlertActionTitleOK, style: .Default, handler: nil)
    urlAlert.addAction(dismiss)
    presentViewController(urlAlert, animated: true, completion: nil)
  }
  
  // MARK: UI update, reset, cancel
  func updateUIForMapView() {
    UIView.animateWithDuration(1.0, animations: {
      self.bottomView.alpha = -1.0
      self.locationTextView.alpha = -1.0
      self.searchButton.alpha = -1.0
      self.locationQuestionTopLabel.alpha = -1.0
      self.locationQuestionMiddleLabel.alpha = -1.0
      self.locationQuestionBottomLabel.alpha = -1.0 })
      { if $0 {
        self.bottomView.alpha = 1.0
        self.bottomView.backgroundColor = UIColor.clearColor()
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
        self.activityIndicator.stopAnimating()
        }
    }
  }
  
  private func resetUI() {
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
