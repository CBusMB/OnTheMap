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
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NavigationItemConstants.logout, style: .Plain, target: self, action: "logout")
    let pin = UIBarButtonItem(image: UIImage(named: ImageConstants.pinImage), style: .Plain, target: self, action: "dropPin")
    let reload = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
    var rightBarButtonItems = [reload, pin]
    navigationItem.rightBarButtonItems = rightBarButtonItems
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
  }

  // MARK: - Table view data source & delegate
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mapLocations.locationsCollection.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewConstants.cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
    cell.imageView?.image = UIImage(named: ImageConstants.pinImage)
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

  // In a storyboard-based application, you will often want to do a little preparation before navigation
//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == "tableToPost" {
//      
//    }
//  }
  
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
  

}
