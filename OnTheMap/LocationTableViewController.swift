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
  var objectIdForUserName: String?
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
    let pin = UIBarButtonItem(image: UIImage(named: ImageConstants.PinImage), style: .Plain, target: self, action: "dropPin")
    let reload = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
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
    let application = UIApplication.sharedApplication()
    if let mediaURL = NSURL(string: mapLocations.locationsCollection[indexPath.row].mediaURL) {
      application.openURL(mediaURL)
    }
  }
  
  func dropPin() {
    performSegueWithIdentifier(SegueIdentifierConstants.TableToPostSegue, sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "tableToPost" {
      let postInformationViewController = segue.destinationViewController as! PostInformationViewController
      postInformationViewController.userWantsToOverwriteLocation = userWantsToOverwriteLocation
      postInformationViewController.objectIdForUserName = objectIdForUserName
    }
  }
  
  func confirmUserWantsToOverwriteLocation() {
    let userName = NSUserDefaults.standardUserDefaults().stringForKey("userName")
    let objectId = mapLocations.checkForMatchingObjectId(byUserName: userName!)
    if objectId.0 {
      objectIdForUserName = objectId.1!
      let confirmationAlert = UIAlertController(title: "Overwrite Location?", message: "You've already added a location to the map.  Do you want to overwrite it or add a new location?", preferredStyle: .Alert)
      let overwrite = UIAlertAction(title: "Overwrite", style: .Default, handler: { Void in
        self.userWantsToOverwriteLocation = true })
      let addNewLocation = UIAlertAction(title: "Add New Location", style: .Default, handler: { Void in
        self.userWantsToOverwriteLocation = false })
      confirmationAlert.addAction(overwrite)
      confirmationAlert.addAction(addNewLocation)
      presentViewController(confirmationAlert, animated: true, completion: nil)
    } else {
      // setting userWantsToOverwriteLocation to false initiates segue
      userWantsToOverwriteLocation = false
    }
  }
  
  func refresh() {
    tableView.reloadData()
  }
  
  func logout() {
    let logoutActionSheet = UIAlertController(title: AlertConstants.AlertActionTitleConfirmation, message: AlertConstants.AlertActionMessageLogout, preferredStyle: .Alert)
    let logoutConfirmed = UIAlertAction(title: AlertConstants.AlertActionTitleLogout, style: .Destructive, handler: { Void in
      self.dismissViewControllerAnimated(true, completion: nil)
      self.mapLocations.removeAllLocations() })
    logoutActionSheet.addAction(logoutConfirmed)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    logoutActionSheet.addAction(cancel)
    presentViewController(logoutActionSheet, animated: true, completion: nil)
  }
  
  
}
