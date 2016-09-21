//
//  SignInVC.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 13.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper



class SignInVC: UIViewController {

  
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        
            if let keychain =  KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID){
                performSegueWithIdentifier("LoggedInSegue", sender: nil)
                print("MOTOROUTES: checked keychain \(keychain)")
            }
    }
    
    @IBAction func facebookButtonTapped(sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) in
            
            print("MOTOROUTES: Result")
            print(result)
            
            if error != nil {
                print("MOTOROUTES: Unable to login with facebook")
            }
            
            else if result.isCancelled == true {
                print("MOTOROUTES: Facebook Login is cancelled")
            }
            else{
                print("MOTOROUTES: Successfully authentificated")
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                self.firebaseAuth(credential)
            }
            
        }
    }
    
    @IBAction func signInTapped(sender: AnyObject) {
        
        if let email = emailField.text, let password = passwordField.text {
            
            FIRAuth.auth()!.signInWithEmail(email, password: password, completion: { (user, error) in
            
                if error == nil{
                    print("MOTOROUTES: SIGNED IN BY MAIL")
                    
                    if let fir_user = user {
                        self.completeSignIn(fir_user.uid)
                    }
                    
                } else {
                    print("MOTOROUTS: ERROR BY MAIL NO LOGIn, CREATE ONE")
                    FIRAuth.auth()!.createUserWithEmail(email, password: password, completion: { (user, error) in
                    
                        if error == nil{
                            print("MOTOROUTES: CREATE USER BY MAIL ")
                            
                            if let fir_user = user {
                                self.completeSignIn(fir_user.uid)
                            }
                            
                        } else {
                             print("MOTOROUTES: ERROR CREATE USER BY MAIL \(error)")
                        }
                    })
                }
            })
        }
    }
    
    
    func firebaseAuth(credential: FIRAuthCredential){
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            
            if error != nil {
                print("MOTOROUTES: Unable to login with firebase")
            } else {
                print("MOTOROUTES: Auth with Firebase")
                if let fir_user = user {
                   self.completeSignIn(fir_user.uid)
                }
            }
        }
    }
    
    //write to jeychain for autosign in
    func completeSignIn(uid: String){
           let keychain =  KeychainWrapper.defaultKeychainWrapper().setString((uid), forKey: KEY_UID)
           performSegueWithIdentifier("LoggedInSegue", sender: nil)
           print("MOTOROUTS: Saved to keyhcain \(keychain)")
        }
    
    
    /*
     * Close segue
     */
    @IBAction func closeSignInVC(segue:UIStoryboardSegue) {
        
        print("segue close closeSignInVC")
        
    }
    
    
}
