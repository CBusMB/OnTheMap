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
    } else {
      return
    }
  }
  
  // MARK: - Navigation
//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == SegueIdentifierConstants.TableToPostSegue {
//      
//    }
//  }
  
  func dropPin() {
    performSegueWithIdentifier(SegueIdentifierConstants.TableToPostSegue, sender: self)
  }
  
  func logout() {    
    let logoutActionSheet = UIAlertController(title: ActionSheetConstants.AlertActionTitleConfirmation, message: ActionSheetConstants.AlertActionMessageLogout, preferredStyle: .ActionSheet)
    let logoutConfirmed = UIAlertAction(title: ActionSheetConstants.AlertActionTitleLogout, style: .Destructive, handler: { Void in
      self.dismissViewControllerAnimated(true, completion: nil) })
    logoutActionSheet.addAction(logoutConfirmed)
    let cancel = UIAlertAction(title: ActionSheetConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    logoutActionSheet.addAction(cancel)
    presentViewController(logoutActionSheet, animated: true, completion: nil)
  }
  

}
