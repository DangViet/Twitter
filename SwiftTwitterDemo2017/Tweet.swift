//
//  Tweet.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/3/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: String?
    var timestamp: NSDate?
    var retweetCount:Int = 0
    var favoritesCount:Int = 0
    
    var retweeted:Bool?
    var favorite:Bool?
    
    var retweetStatus:NSDictionary?
    var inReplyTo:String?
    
    var id:Int?
    
    var user: User?
    
    init(dictionary: NSDictionary){
        text = dictionary["text"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        
        favorite = (dictionary["favorited"] as? Bool) ?? false
        
        retweetStatus = dictionary["retweeted_status"] as? NSDictionary
        
        inReplyTo = dictionary["in_reply_to_screen_name"] as? String
        
        id = (dictionary["id"] as? Int) ?? 0

        let userDictionary = dictionary["user"] as? NSDictionary
        user = User(dictionary: userDictionary!)
        
        let timestampString = dictionary["created_at"] as? String
        if let timestampString = timestampString{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString) as NSDate?
        
        }
    }
    
    class func tweetWithArray(dictionaries:[NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
    
            tweets.append(tweet)
        }
        
        return tweets
    }
}

