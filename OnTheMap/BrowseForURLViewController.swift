//
//  BrowseForURLViewController.swift
//  OnTheMap
//
//  Created by Matthew Brown on 6/25/15.
//  Copyright (c) 2015 Crest Technologies. All rights reserved.
//

import UIKit

class BrowseForURLViewController: UIViewController, UIWebViewDelegate
{
  let GoogleURL = NSURL(string: "https://www.google.com")
  var currentURL: String?
  
  @IBOutlet weak var webView: UIWebView! {
    didSet {
      loadGoogle()
      webView.delegate = self
    }
  }

  @IBOutlet weak var forwardButton: UIBarButtonItem! {
    didSet {
      disableWebNavigationButtonsOnLoad(forwardButton)
    }
  }
  
  @IBOutlet weak var backButton: UIBarButtonItem! {
    didSet {
      disableWebNavigationButtonsOnLoad(backButton)
    }
  }
  
  func disableWebNavigationButtonsOnLoad(button: UIBarButtonItem) {
    // web navigation buttons are disabled by default
    button.enabled = false
  }
  
  @IBAction func back(sender: UIBarButtonItem) {
    webView.goBack()
  }
  
  @IBAction func forward(sender: UIBarButtonItem) {
    webView.goForward()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // MARK: - Lifecycle

  override func viewDidLoad() {
    prefersStatusBarHidden()
  }
  
  // MARK: - Load Google
  
  @IBAction func navigateToGoogle(sender: UIBarButtonItem) {
    loadGoogle()
  }
  
  func loadGoogle() {
    let request = NSURLRequest(URL: GoogleURL!)
    webView.loadRequest(request)
  }
  
  // MARK: - UIWebViewDelegate
  
  func webViewDidFinishLoad(webView: UIWebView) {
    backButton.enabled = webView.canGoBack
    forwardButton.enabled = webView.canGoForward
  }
}
