//
//  LoginViewController.swift
//  
//
//  Created by Matthew Brown on 6/11/15.
//
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate
{

  @IBOutlet weak var emailTextField: UITextField! {
    didSet {
      emailTextField.delegate = self
    }
  }
  @IBOutlet weak var passwordTextField: UITextField! {
    didSet {
      passwordTextField.delegate = self
    }
  }
  
  @IBOutlet weak var signUpTextView: UITextView! {
    didSet {
      signUpTextView.delegate = self
      signUpTextView.linkTextAttributes = LinkAttributes.link
      let signUpLink = NSAttributedString(string: LinkAttributes.signUpLinkString, attributes: LinkAttributes.attributes)
      signUpTextView.attributedText = signUpLink
    }
  }
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  @IBAction func loginToUdacity() {
    dismissKeyboard()
    UIView.animateWithDuration(1.2, animations: { self.view.alpha = 0.6 })
    activityIndicator.startAnimating()
    var udacityLoginCredentials = UdacityUser(userName: emailTextField.text, password: passwordTextField.text)
    UdacityLoginSession.udacityLoginTask(udacityLoginCredentials.udacityParameters) { (success, completionMessage) -> () in
      if !success {
        let errorActionSheet = UIAlertController(title: ErrorMessages.genericErrorMessage, message: completionMessage, preferredStyle: .ActionSheet)
        let tryAgain = UIAlertAction(title: ActionSheetConstants.alertActionTitleResubmit, style: .Default, handler: { Void in self.loginToUdacity() })
        errorActionSheet.addAction(tryAgain)
        let cancel = UIAlertAction(title: ActionSheetConstants.alertActionTitleCancel, style: .Cancel, handler: nil)
        errorActionSheet.addAction(cancel)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.presentViewController(errorActionSheet, animated: true, completion: { Void in self.resetUI() })
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
          self.presentViewController(tabBarController, animated: true, completion: { Void in self.resetUI() })
        })
      }
    }
  }
  
  func resetUI() {
    activityIndicator.stopAnimating()
    view.alpha = 1.0
  }
  
  func dismissKeyboard() {
    textFieldShouldReturn(emailTextField)
    textFieldShouldReturn(passwordTextField)
  }
  
  struct LinkAttributes {
    static let udacityURL = "https://www.udacity.com"
    static let attributes = [
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 22)!,
      NSLinkAttributeName: udacityURL
    ]
    static let link = [
      NSLinkAttributeName: udacityURL
    ]
    static let signUpLinkString = "Don't have an account? Sign up"
  }

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    signUpTextView.backgroundColor = view.backgroundColor
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  // MARK: textView, textField, keyboard methods
  func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    return true
  }

  func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func keyboardWillShow(notification: NSNotification) {
    self.view.frame.origin.y -= (keyboardHeight(notification) / 2)
    unsubscribeFromKeyboardWillShowNotification()
  }
  
  func keyboardWillHide(notification: NSNotification) {
    self.view.frame.origin.y += (keyboardHeight(notification) / 2)
    subscribeToKeyboardWillShowNotification()
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


}
