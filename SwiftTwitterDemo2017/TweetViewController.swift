//
//  TweetViewController.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/4/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TweetViewController: UIViewController {

    @IBOutlet weak var tweetTable: UITableView!
    
    let client = TwitterClient.sharedInstance
    
    var tweets:[Tweet] = []
    
    var isMoreDataLoading = false
    var loadingMoreView:NVActivityIndicatorView?
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var composeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initilize loading animation
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotate
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor.cyan
        let activityData = ActivityData()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tweetTable.insertSubview(refreshControl, at: 0)
        
        // Initilize title image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "Twitter_Logo_Blue")
        self.navigationItem.titleView = imageView
       
        // Initilize table view
        tweetTable.estimatedRowHeight = 100
        tweetTable.rowHeight = UITableViewAutomaticDimension
        
        tweetTable.delegate = self
        tweetTable.dataSource = self
        
        // Set up infinite loading
        
        let frame = CGRect(x: 0, y: tweetTable.contentSize.height, width: tweetTable.bounds.size.width/2, height: 60.0)
        loadingMoreView = NVActivityIndicatorView(frame: frame, type: .ballBeat, color: UIColor.gray)
        loadingMoreView?.isHidden = true
        tweetTable.addSubview(loadingMoreView!)
        
        var insets = tweetTable.contentInset
        insets.bottom += 60.0
        tweetTable.contentInset = insets
        
        
        // Start loading animation
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        // Fetch home timeline
        client?.homeTimeline(success: { (tweets:[Tweet]) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            for tweet in tweets{
                self.tweets.append(tweet)
            }
            self.tweetTable.reloadData()
        }, failure: { (error:Error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            print(error.localizedDescription)
        })

    }

    
    @IBAction func onLogout(_ sender: Any) {
        client?.logout()
    }

    // Refresh action
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        client?.homeTimeline(success: { (tweets:[Tweet]) in
            self.tweets = [Tweet]()
            for tweet in tweets{
                self.tweets.append(tweet)
            }
            self.tweetTable.reloadData()
            refreshControl.endRefreshing()
        }, failure: { (error:Error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            print(error.localizedDescription)
            refreshControl.endRefreshing()
        })
 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "composeSegue"){
            let destVC = segue.destination as! ComposeViewController
            destVC.delegate = self
        } else if(segue.identifier == "detailSegue"){
            let destVC = segue.destination as! DetailViewController
            destVC.tweet = tweets[(tweetTable.indexPathForSelectedRow?.row)!]
            destVC.tableIndex = tweetTable.indexPathForSelectedRow?.row
            
        }
    }
}

extension TweetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
}

extension TweetViewController: ComposeViewControllerDelegate{
    func composeViewController(composeViewController: ComposeViewController, didTweet newTweet: Tweet) {
        tweets.insert(newTweet, at: 0)
        
        tweetTable.reloadData()
    }
}

extension TweetViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetTable.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetTable.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetTable.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tweetTable.contentSize.height, width: tweetTable.bounds.size.width, height: 60.0)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                if(tweets.count > 0){
                    let max_id:Int = (tweets[tweets.count - 1]).id! - 1
                    
                    client?.homeTimeline(max_id: max_id, success: { (tweets:[Tweet]) in
                        for tweet in tweets{
                            self.tweets.append(tweet)
                        }
                        
                        self.loadingMoreView!.stopAnimating()
                        
                        self.isMoreDataLoading = false
                        self.tweetTable.reloadData()
                        
                    }, failure: { (error:Error) in
                        self.loadingMoreView!.stopAnimating()
                        self.isMoreDataLoading = false
                        print(error.localizedDescription)
                        
                    })

                }
                
            }
        
        }
    }
}
