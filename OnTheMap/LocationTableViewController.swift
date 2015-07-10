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
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NavigationItemConstants.Logout, style: .Plain, target: self, action: "logout")
    let pin = UIBarButtonItem(image: UIImage(named: ImageConstants.PinImage), style: .Plain, target: self, action: "confirmUserWantsToOverwriteLocation")
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
    return mapLocations.locationsCollection.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewConstants.CellIdentifier, forIndexPath: indexPath) as! UITableViewCell
    cell.imageView?.image = UIImage(named: ImageConstants.PinImage)
    cell.textLabel?.text = "\(mapLocations.locationsCollection[indexPath.row].firstName) \(mapLocations.locationsCollection[indexPath.row].lastName)"
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let https = "https://"
    let http = "http://"
    let googleSearch = "https://google.com/search?q="
    
    var urlString = mapLocations.locationsCollection[indexPath.row].mediaURL
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
  
  func confirmUserWantsToOverwriteLocation() {
    let userName = NSUserDefaults.standardUserDefaults().stringForKey("userName")
    let objectId = mapLocations.checkForMatchingObjectId(byUserName: userName!)
    if objectId.0 {
      let confirmationAlert = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionOverwriteMessage, preferredStyle: .Alert)
      let overwrite = UIAlertAction(title: AlertConstants.AlertActionOverwriteConfirmationTitle, style: .Default, handler: { [unowned self] Void in
        self.userWantsToOverwriteLocation = true }) // setting userWantsToOverwriteLocation initiates segue
      let addNewLocation = UIAlertAction(title: AlertConstants.AlertActionNewLocationTitle, style: .Default, handler: { [unowned self] Void in
        self.userWantsToOverwriteLocation = false })
      confirmationAlert.addAction(overwrite)
      confirmationAlert.addAction(addNewLocation)
      presentViewController(confirmationAlert, animated: true, completion: nil)
    } else {
      userWantsToOverwriteLocation = false
    }
  }
  
  func getStudentLocations() {
    if !mapLocations.locationsCollection.isEmpty {
      mapLocations.removeAllLocations()
    }
    
    ParseAPISession.getStudentLocationsTask { [unowned self] (success, completionMessage) -> Void in
      if !success {
        let errorAlert = UIAlertController(title: AlertConstants.AlertActionTitleError, message: completionMessage, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
        errorAlert.addAction(cancel)
        dispatch_async(dispatch_get_main_queue(), { () in
          self.presentViewController(errorAlert, animated: true, completion: nil)
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), { () in
          self.tableView.reloadData()
        })
      }
    }
  }
  
  func logout() {
    let logoutActionSheet = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionMessageLogout, preferredStyle: .Alert)
    let logoutConfirmed = UIAlertAction(title: AlertConstants.AlertActionTitleLogout, style: .Destructive, handler: { [unowned self] Void in
      self.dismissViewControllerAnimated(true, completion: nil)
      self.mapLocations.removeAllLocations() })
    logoutActionSheet.addAction(logoutConfirmed)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    logoutActionSheet.addAction(cancel)
    presentViewController(logoutActionSheet, animated: true, completion: nil)
  }
  
  
}
