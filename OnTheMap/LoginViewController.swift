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
      signUpTextView.linkTextAttributes = LinkAttributes.Link
      let signUpLink = NSAttributedString(string: LinkAttributes.SignUpLinkString, attributes: LinkAttributes.Attributes)
      signUpTextView.attributedText = signUpLink
    }
  }
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // MARK: - Login
  
  @IBAction func loginToUdacity() {
    dismissKeyboard()
    UIView.animateWithDuration(1.2, animations: { self.view.alpha = 0.6 })
    activityIndicator.startAnimating()
    // create the dictionary of parameters needed to login and pass it to the login method
    var udacityLoginParameters = prepareUdacityLoginParameters()
    UdacityAPISession.udacityLoginSession(udacityLoginParameters) { (success, completionMessage, userId) in
      if !success {
        if let message = completionMessage {
          self.presentErrorActionSheet(message: message)
        }
      } else {
        dispatch_async(dispatch_get_main_queue(), { () in
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let tabBarController = storyboard.instantiateViewControllerWithIdentifier(SegueIdentifierConstants.TabBarIdentifier) as! UITabBarController
          self.presentViewController(tabBarController, animated: true, completion: { Void in self.resetUI() })
        })
        if let persistedUserId = NSUserDefaults.standardUserDefaults().stringForKey("userId") { // is there a persisted userId?
          if persistedUserId != userId {
            // if the persisted userId is not equal to the newly downloaded userId, update the userId and the user first/last name
            self.updateUserIdFirstLastName(userId!)
          }
        } else {
          // if there is no persisted userId, persist the newly downloaded userId and update the user first/last name
          self.updateUserIdFirstLastName(userId!)
        }
      }
    }
  }
  
  ///  :returns: A Dictionary containing the parameters required for Udacity login
  func prepareUdacityLoginParameters() -> [String : [String : String]] {
    UdacityUser.saveToUserDefaults(emailTextField.text.lowercaseString, key: "userName")
    UdacityUser.saveToUserDefaults(passwordTextField.text, key: "password")
    return UdacityUser.createUdacityParametersDictionary(emailTextField.text.lowercaseString, password: passwordTextField.text)
  }
  
  /// Saves the userId to NSUserDefaults.  GETs the student first and last name from Udacity and saves both to NSUserDefaults
  func updateUserIdFirstLastName(userId: String) {
    UdacityUser.saveToUserDefaults(userId, key: "userId")
    UdacityAPISession.studentNameForUdacityUserId(userId) { (querySuccess, firstName, lastName) in
      if !querySuccess { // pass empty strings as the values for first and last name
        UdacityUser.saveToUserDefaults("", key: "firstName")
        UdacityUser.saveToUserDefaults("", key: "lastName")
      } else {
        UdacityUser.saveToUserDefaults(firstName!, key: "firstName")
        UdacityUser.saveToUserDefaults(lastName!, key: "lastName")
      }
    }
  }
  
  func presentErrorActionSheet(message completionMessage: String) {
    let errorActionSheet = UIAlertController(title: ErrorMessages.GenericErrorMessage, message: completionMessage, preferredStyle: .Alert)
    let tryAgain = UIAlertAction(title: AlertConstants.AlertActionTitleResubmit, style: .Default, handler: { Void in self.loginToUdacity() })
    errorActionSheet.addAction(tryAgain)
    let cancel = UIAlertAction(title: AlertConstants.AlertActionTitleCancel, style: .Cancel, handler: nil)
    errorActionSheet.addAction(cancel)
    dispatch_async(dispatch_get_main_queue(), { () in
      self.presentViewController(errorActionSheet, animated: true, completion: { Void in self.resetUI() })
    })
  }
  
  struct LinkAttributes {
    static let UdacityURL = "https://www.google.com/url?q=https%3A%2F%2Fwww.udacity.com%2Faccount%2Fauth%23!%2Fsignin&sa=D&sntz=1&usg=AFQjCNERmggdSkRb9MFkqAW_5FgChiCxAQ"
    static let Attributes = [
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 22)!,
      NSLinkAttributeName: UdacityURL
    ]
    static let Link = [
      NSLinkAttributeName: UdacityURL
    ]
    static let SignUpLinkString = "Don't have an account? Sign up"
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    signUpTextView.backgroundColor = view.backgroundColor
    let defaults = NSUserDefaults.standardUserDefaults()
    // if we have a persisted userName in NSUserDefaults (user did not logout), fill it in and login automatically
    if let userName = defaults.stringForKey("userName") {
      let password = defaults.stringForKey("password")
      emailTextField.text = userName
      passwordTextField.text = password
      loginToUdacity()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  func resetUI() {
    activityIndicator.stopAnimating()
    view.alpha = 1.0
  }
  
  // MARK: - textView, textField, keyboard methods
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
  
  func dismissKeyboard() {
    textFieldShouldReturn(emailTextField)
    textFieldShouldReturn(passwordTextField)
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
