//
//  ComposeViewController.swift
//  SwiftTwitterDemo2017
//
//  Created by Viet Dang Ba on 3/4/17.
//  Copyright © 2017 Viet Dang. All rights reserved.
//

import UIKit

protocol ComposeViewControllerDelegate {
    func composeViewController(composeViewController:ComposeViewController, didTweet newTweet:Tweet)
}

class ComposeViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var composeText: UITextView!
    
    @IBOutlet weak var countButton: UIBarButtonItem!
    
    var replyTweet:Tweet?
    
    var charCount:Int! = 0
    var delegate:ComposeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.setImageWith((User.currentUser?.profileURL)!)
        nameLabel.text = User.currentUser?.name
        screenNameLabel.text = User.currentUser?.screenName
        
        
        composeText.delegate = self
        
        
        
        self.textViewDidChange(self.composeText)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        composeText.becomeFirstResponder()
        if let replyTweet = replyTweet{
            self.composeText.text = "@\(replyTweet.user!.screenName!) "
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func onTweet(_ sender: Any) {
        if let replyTweet = replyTweet{
            TwitterClient.sharedInstance?.reply(status: self.composeText.text, replyId: replyTweet.id!,success: { (tweet:Tweet) in
                self.delegate?.composeViewController(composeViewController: self, didTweet: tweet)
                self.navigationController?.popViewController(animated: true)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })
        } else {
            TwitterClient.sharedInstance?.tweet(status: self.composeText.text, success: { (tweet:Tweet) in
                self.delegate?.composeViewController(composeViewController: self, didTweet: tweet)
                self.navigationController?.popViewController(animated: true)
            }, failure: { (error:Error) in
                print(error.localizedDescription)
            })
        }
        
        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        composeText.resignFirstResponder()
    }
}

extension ComposeViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        countButton.title = "\(textView.text.characters.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        
        return numberOfChars <= 140;
    }
    
}
