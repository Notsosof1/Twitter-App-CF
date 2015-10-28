//
//  TweetViewController.swift
//  Twitter App
//
//  Created by Cynthia Whitlatch on 10/26/15.
//  Copyright © 2015 Cynthia Whitlatch. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func refreshBarButton(sender: AnyObject) {
        
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshBarButton: IUBarButtonItem!
    var spinner: UIActivityIndicatorView!
    
    var maxRows = 10
    var maxSection = 8
    
    class func identifier() -> String {
        return "TweetViewController"
    }
    
    var tweets = [Tweet]() {
        didSet {
            self.tableView.reloadData()
        }
    
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        self.getAccount()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "getTweets")
        self.navigationItem.rightBarButtonItem = self.refreshBarButton
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.spinner.hidesWhenStopped = true
    }
    
    func getAccount() {
        TwitterLoginService.loginTwitter({ (error, account) -> () in
            if let error = error {
                print(error)
                return
            }
            
            if let account = account {
                TwitterService.sharedService.account = account
                self.authenticateUser()
            }
        })
    }
    
    func authenticateUser(){
        TwitterService.getAuthUser { (error, user) -> () in
            if let error = error {
                print(error)
                return
            }
            
            if let user = user {
                TwitterService.sharedService.user = user
                self.getTweets()
            }
        }
    }
    
    func getTweets() {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinner)
        }
        TwitterService.tweetsFromHomeTimeline { (error, tweets) -> () in
            if let error = error {
                print(error)
                return
            }
            
            if let tweets = tweets {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tweets = tweets
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: UITableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return maxSection
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TwitterTableViewCell
        
        let tweet = tweets[indexPath.row]
        
        cell.nameLabel.text = tweet.text
        
        if let user = tweet.user {
            cell.tweetLabel.text = "Posted by: \(user.name)"
        } else {
            cell.tweetLabel.text = "Posted by: Sponsor."
        }
        
        cell.backgroundColor = cellColorForIndex(indexPath)
        
        return cell
    }
    
    func cellColorForIndex(indexPath:NSIndexPath) -> UIColor {
        let row = CGFloat(indexPath.row)
        let section = CGFloat(indexPath.section)
        
        let saturation = 1.0 - row / CGFloat(maxRows)
        let hue = section / CGFloat(maxSection)
        
        return UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
        }
    }

