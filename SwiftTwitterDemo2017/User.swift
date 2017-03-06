//
//  User.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/3/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit

class User: NSObject {

    var name: String?
    var screenName: String?
    var profileURL: URL?
    var tagline: String?
    
    var dictionary:NSDictionary?
    
    init(dictionary:NSDictionary){
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        
        let profileURLString = dictionary["profile_image_url_https"] as? String
        if let profileURLString = profileURLString {
            profileURL = URL(string: profileURLString)
        }
        
        tagline = dictionary["description"] as? String
    }
    
    static var _currentUser: User?
    
    class var currentUser: User?{
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                
                let userData = defaults.object(forKey: "currentUser") as? NSData
                
                if let userData = userData{
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: userData as Data, options: []) as! NSDictionary
                        
                        _currentUser = User(dictionary: dictionary)
                    } catch {
                        _currentUser = nil
                    }
                }
            }
            return _currentUser
        }
        
        set(user){
            let defaults = UserDefaults.standard
            
            if let user = user{
                let data = try! JSONSerialization.data(withJSONObject: (user.dictionary!), options: [])
                defaults.set(data, forKey: "currentUser")
                
            } else {
                defaults.set(nil, forKey: "currentUser")
            }
            
            defaults.synchronize()
        }
    }
    
}
