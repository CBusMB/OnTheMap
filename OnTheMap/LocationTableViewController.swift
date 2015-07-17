//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/16/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource
{
  let mapLocations = OnTheMapLocations.sharedCollection
  private var userWantsToOverwriteLocation: Bool? {
    didSet {
      dropPin()
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NavigationBarConstants.Logout, style: .Plain, target: self, action: "logout")
    let pin = UIBarButtonItem(image: UIImage(named: NavigationBarConstants.PinImage), style: .Plain, target: self, action: "confirmUserWantsToOverwriteLocation")
    let reload = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "getStudentLocations")
    var rightBarButtonItems = [reload, pin]
    navigationItem.rightBarButtonItems = rightBarButtonItems
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  // MARK: - Table view data source & delegate
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mapLocations.locations.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierConstants.CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
    cell.imageView?.image = UIImage(named: NavigationBarConstants.PinImage)
    cell.textLabel?.text = "\(mapLocations.locations[indexPath.row].firstName) \(mapLocations.locations[indexPath.row].lastName)"
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // if the user did not enter a full URL, do a search with the mediaURL as the search term
    let https = "https://"
    let http = "http://"
    let googleSearch = "https://google.com/search?q="
    
    var urlString = mapLocations.locations[indexPath.row].mediaURL
    if !urlString.hasPrefix(https) && !urlString.hasPrefix(http) {
      urlString = googleSearch.stringByAppendingString(urlString)
    }
    let application = UIApplication.sharedApplication()
    if let studentURL = NSURL(string: urlString) {
      application.openURL(studentURL)
    }
  }
  
  // MARK: - Navigation
  
  private func dropPin() {
    performSegueWithIdentifier(SegueIdentifierConstants.TableToPostSegue, sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == SegueIdentifierConstants.TableToPostSegue {
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

  
  func getStudentLocations() {
    if !mapLocations.locations.isEmpty {
      // clear the locations array
      mapLocations.removeAllLocations()
    }
    
    ParseAPISession.getStudentLocationsSession { (success, completionMessage) in
      if !success {
        self.presentErrorAlert(completionMessage!)
      } else {
        dispatch_async(dispatch_get_main_queue(), { () in
          self.tableView.reloadData()
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
  
  func logout() {
    let logoutActionSheet = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionMessageLogout, preferredStyle: .Alert)
    let logoutConfirmed = UIAlertAction(title: AlertConstants.AlertActionTitleLogout, style: .Destructive, handler: { Void in
      self.dismissViewControllerAnimated(true, completion: nil)
      self.mapLocations.removeAllLocations()
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
  
}
