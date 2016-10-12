//
//  LoggedIn.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 19.09.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoggedIn: UIViewController {
    
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        
        let _ : Bool = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "ShowVCSignOut", sender: nil)
        print("MOTOROUTES: Sign out from Firebase");

    }

}
