//
//  DetailViewController.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/5/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var statusLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabelTop: NSLayoutConstraint!
    
    
    var tweet:Tweet!
    
    var isFavorited:Bool?
    var isRetweeted:Bool?
    
    var tableIndex:Int?
   
    @IBAction func onRetweet(_ sender: Any) {
        if self.isRetweeted!{
            // TODO: Unretweet
            
        } else {
            // Retweet
            TwitterClient.sharedInstance?.retweet(id: self.tweet.id!, success: { (tweet:Tweet) in
                self.tweet = Tweet(dictionary: tweet.retweetStatus!)
                
                self.retweetCountLabel.text = ("\(Int(self.retweetCountLabel.text!)! + 1)")
                self.retweetButton.setImage(#imageLiteral(resourceName: "retweet-green"), for: UIControlState.normal)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })
            self.isRetweeted = true
        }
    }
    
    @IBAction func onFavorite(_ sender: Any) {
        if self.isFavorited!{
            // Unfavorited
            TwitterClient.sharedInstance?.unfavorite(id: self.tweet.id!, success: { (tweet:Tweet) in
                self.tweet = tweet
                
                self.favoriteCountLabel.text = ("\(Int(self.favoriteCountLabel.text!)! - 1)")
                self.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-grey"), for: UIControlState.normal)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })
            
            self.isFavorited = false
        } else {
            // Favorited
            TwitterClient.sharedInstance?.favorite(id: self.tweet.id!, success: { (tweet:Tweet) in
                self.tweet = tweet
                
                self.favoriteCountLabel.text = ("\(Int(self.favoriteCountLabel.text!)! + 1)")
                self.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-red"), for: UIControlState.normal)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })

            
            self.isFavorited = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewFromTweet()

        
    }

    func loadViewFromTweet(){
        var rootTweet:Tweet! = tweet
        
        // Check if it is a reply
        if(rootTweet.inReplyTo != nil){
            statusLabel.text = "Replied to " + (rootTweet.inReplyTo)!
            statusImage.image = #imageLiteral(resourceName: "reply")
            
            statusLabelHeight.constant = 16
            statusLabelTop.constant = 4
        } else {
            statusLabel.text = ""
            statusLabelHeight.constant = 0
            
        }

        
        // Check if it is a retweet
        if(tweet.retweetStatus != nil){
            rootTweet = Tweet(dictionary: tweet.retweetStatus!)
            statusLabel.text = (tweet.user?.name)! + " retweeted"
            
            statusLabelHeight.constant = 16
            statusLabelTop.constant = 4
        }
        
        
        
        profileImage.image = nil
        if rootTweet?.user != nil {
            profileImage.setImageWith((rootTweet?.user?.profileURL!)!)
            nameLabel.text = rootTweet?.user?.name
            screennameLabel.text = "@"+(rootTweet?.user?.screenName)!
        }
        textLabel.text = rootTweet.text
        
        
        if rootTweet.favorite == true{
            favoriteButton.setImage(#imageLiteral(resourceName: "favorite-red"), for: UIControlState.normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "favorite-grey"), for: UIControlState.normal)
        }
        isFavorited = rootTweet.favorite
        favoriteCountLabel.text = "\(rootTweet.favoritesCount)"
        
        
        
        if rootTweet.retweeted == true{
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-green"), for: UIControlState.normal)
        } else {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: UIControlState.normal)
        }
        isRetweeted = rootTweet.retweeted
        retweetCountLabel.text = "\(rootTweet.retweetCount)"
        
        
        self.timeLabel.text = rootTweet.timestamp?.dateTimeAgo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "replySegue"){
            let tweetVC = self.navigationController?.viewControllers[0] as! TweetViewController
            let vc = segue.destination as! ComposeViewController
            vc.replyTweet = self.tweet
            vc.delegate = tweetVC
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let vc = self.navigationController?.viewControllers[0] as! TweetViewController
        vc.tweets[self.tableIndex!] = self.tweet
        vc.tweetTable.reloadData()
    }
    

    @IBAction func onReply(_ sender: AnyObject) {
        performSegue(withIdentifier: "replySegue", sender: sender)
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
