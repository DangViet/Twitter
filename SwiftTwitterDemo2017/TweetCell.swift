//
//  TweetCell.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/4/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit
import NSDate_TimeAgo

class TweetCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
   
    
    @IBOutlet weak var replyImage: UIImageView!
    @IBOutlet weak var retweetImage: UIImageView!
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var retweetLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var retweetLabelTop: NSLayoutConstraint!
    
    
    var tweet:Tweet!{
        didSet {
            var rootTweet:Tweet! = tweet
            
            // Check if it is a reply
            if(rootTweet.inReplyTo != nil){
                retweetLabel.text = "Replied to " + (rootTweet.inReplyTo)!
                statusImage.image = #imageLiteral(resourceName: "reply")
                
                retweetLabelHeight.constant = 16
                retweetLabelTop.constant = 4
            } else {
                retweetLabel.text = ""
                retweetLabelHeight.constant = 0
            }
            
            // Check if it is a retweet
            if(tweet.retweetStatus != nil){
                rootTweet = Tweet(dictionary: tweet.retweetStatus!)
                retweetLabel.text = (tweet.user?.name)! + " retweeted"
                
                retweetLabelHeight.constant = 16
                retweetLabelTop.constant = 4
            }
            
            
            
            userImage.image = nil
            if rootTweet?.user != nil {
                userImage.setImageWith((rootTweet?.user?.profileURL!)!)
                nameLabel.text = rootTweet?.user?.name
                screennameLabel.text = "@" + (rootTweet?.user?.screenName)!
            }
            tweetTextLabel.text = rootTweet.text
            
            
            if rootTweet.favorite == true{
               favoriteImage.image = #imageLiteral(resourceName: "favorite-red")
            } else {
                favoriteImage.image = #imageLiteral(resourceName: "favorite-grey")
            }
            if(rootTweet.favoritesCount != 0){
                favoriteCountLabel.text = "\(rootTweet.favoritesCount)"
            } else {
                favoriteCountLabel.text = ""
            }
            
            
            if rootTweet.retweeted == true{
                retweetImage.image = #imageLiteral(resourceName: "retweet-green")
            } else {
                retweetImage.image = #imageLiteral(resourceName: "retweet")
            }
            if rootTweet.retweetCount != 0 {
                retweetCountLabel.text = "\(rootTweet.retweetCount)"
            } else {
                retweetCountLabel.text = ""
            }
            
            self.timeLabel.text = rootTweet.timestamp?.dateTimeAgo()
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
