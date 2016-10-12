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
    
    override func viewDidAppear(_ animated: Bool) {
       
          if let keychain = KeychainWrapper.standard.string(forKey: KEY_UID){
                performSegue(withIdentifier: "LoggedInSegue", sender: nil)
                print("MOTOROUTES: checked keychain \(keychain)")
          }
    }
    
    @IBAction func facebookButtonTapped(_ sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            print("MOTOROUTES: Result")
           // print(result)
            
            if error != nil {
                print("MOTOROUTES: Unable to login with facebook")
            }
            
            else if result?.isCancelled == true {
                print("MOTOROUTES: Facebook Login is cancelled")
            }
            else{
                print("MOTOROUTES: Successfully authentificated")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
            
        }
    }
    
    @IBAction func signInTapped(_ sender: AnyObject) {
        
        if let email = emailField.text, let password = passwordField.text {
            
            FIRAuth.auth()!.signIn(withEmail: email, password: password, completion: { (user, error) in
            
                if error == nil{
                    print("MOTOROUTES: SIGNED IN BY MAIL")
                    
                    if let fir_user = user {
                        self.completeSignIn(fir_user.uid)
                    }
                    
                } else {
                    print("MOTOROUTS: ERROR BY MAIL NO LOGIn, CREATE ONE")
                    FIRAuth.auth()!.createUser(withEmail: email, password: password, completion: { (user, error) in
                    
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
    
    
    func firebaseAuth(_ credential: FIRAuthCredential){
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            
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
    func completeSignIn(_ uid: String){
        let _ = KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        performSegue(withIdentifier: "LoggedInSegue", sender: nil)
        }
    
    

    //Close segue
    @IBAction func closeSignInVC(_ segue:UIStoryboardSegue) {
        
        print("segue close closeSignInVC")
        
    }
    
    
}
