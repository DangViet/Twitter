//
//  TwitterClient.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/3/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "uiFG8vO0KwWsxiGzgkZ8cO46L", consumerSecret: "aYZjRJqd7h8i72x3hFdL941JPqNzcAXJj2FPMHABCL4gdAkEKG")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()){
    
        
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionaries = response as! [NSDictionary]
            print("\(dictionaries)")
            let tweets = Tweet.tweetWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })

    }
    
    func homeTimeline(max_id:Int, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()){
        let parameters: [String : AnyObject] = ["max_id": max_id as AnyObject]
        get("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionaries = response as! [NSDictionary]
            print("\(dictionaries)")
            let tweets = Tweet.tweetWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
        
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()){
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let responseDictionary = response as! NSDictionary
            let user = User(dictionary: responseDictionary)
            
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("Error: \(error.localizedDescription)")
            
            failure(error)
        })

    }
    
    func login(success: @escaping ()->(), failure: @escaping (Error)->()){
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string:"DangViet://oauth"), scope: nil, success:{ (requestToken: BDBOAuth1Credential?) in
            print("\(requestToken?.token)")
            let stringURL = "https://api.twitter.com/oauth/authorize?oauth_token=" + (requestToken?.token)!
            let authorizeURL = URL(string: stringURL)!
            UIApplication.shared.openURL(authorizeURL)
        }, failure: { (error:Error?) in
            print("\(error)")
            self.loginFailure?(error!)
        })

    }
    
    func logout(){
        User.currentUser = nil
        deauthorize()
    
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogOut"), object: nil)
    }
    
    func handleOpenUrl(url: URL){
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            print("Got access token ")
            
            self.currentAccount(success: { (user:User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error:Error) in
                self.loginFailure?(error)
            })
            
            
        }, failure: { (error: Error?) in
            print("\(error?.localizedDescription)")
            
        })

    }
    
    func tweet(status: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        let parameters: [String : AnyObject] = ["status": status as AnyObject]
        post("1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task:URLSessionDataTask, response:Any?) in
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: responseDictionary)
            success(tweet)

        }) { (task:URLSessionDataTask?, error:Error) in
            failure(error)
        }
    }
    
    func reply(status: String, replyId:Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        let parameters: [String : AnyObject] = ["status": status as AnyObject, "in_reply_to_status_id": replyId as AnyObject]
        post("1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task:URLSessionDataTask, response:Any?) in
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: responseDictionary)
            success(tweet)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            failure(error)
        }
    }

    
    func favorite(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        let parameters: [String : AnyObject] = ["id": id as AnyObject]
        post("1.1/favorites/create.json", parameters: parameters, progress: nil, success: { (task:URLSessionDataTask, response:Any?) in
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: responseDictionary)
            success(tweet)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            failure(error)
        }

    }
    
    func unfavorite(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        let parameters: [String : AnyObject] = ["id": id as AnyObject]
        post("1.1/favorites/destroy.json", parameters: parameters, progress: nil, success: { (task:URLSessionDataTask, response:Any?) in
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: responseDictionary)
            success(tweet)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            failure(error)
        }

    }
    
    func retweet(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        let id_str:String = "\(id)"
        let url_str = String(format: "1.1/statuses/retweet/%@.json", id_str)
        
        post(url_str, parameters: nil, progress: nil, success: { (task:URLSessionDataTask, response:Any?) in
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: responseDictionary)
            success(tweet)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            failure(error)
        }
    }
    func unRetweet(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()){
        let id_str:String = "\(id)"
        let url_str = String(format: "1.1/statuses/unretweet/%@.json", id_str)
        post(url_str, parameters: nil, progress: nil, success: { (task:URLSessionDataTask, response:Any?) in
            let responseDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: responseDictionary)
            success(tweet)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            failure(error)
        }

    }

    

}
