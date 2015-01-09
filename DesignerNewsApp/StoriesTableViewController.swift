//
//  StoriesTableViewController.swift
//  DesignerNewsApp
//
//  Created by Meng To on 2015-01-08.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import UIKit
import Haneke

class StoriesTableViewController: UITableViewController, StoriesTableViewCellDelegate {

    var stories: JSON = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getStories("1", { (json) -> () in
            self.stories = json["stories"]
            self.tableView.reloadData()
        })
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as StoriesTableViewCell
        configureCell(cell, story: stories[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var story = stories[indexPath.row].dictionaryObject
        self.performSegueWithIdentifier("storiesToArticleSegue", sender: story)
    }
    
    func configureCell(cell: StoriesTableViewCell, story: JSON) {
        
        cell.titleLabel.text = story["title"].string
        cell.authorLabel.text = story["user_display_name"].string
        cell.upvoteButton.setTitle(toString(story["vote_count"]), forState: UIControlState.Normal)
        cell.commentButton.setTitle(toString(story["comment_count"]), forState: UIControlState.Normal)
        
        var timeAgo = dateFromString(story["created_at"].string!, "yyyy-MM-dd'T'HH:mm:ssZ")
        cell.timeLabel.text = timeAgoSinceDate(timeAgo, true)
        
        if let badge = story["badge"].string? {
            cell.storyImageView.image = UIImage(named: "badge-\(badge)")
        }
        else {
            cell.storyImageView.image = nil
        }
        
        if let urlString = story["user_portrait_url"].string? {
            ImageLoader.sharedLoader.imageForUrl(urlString, completionHandler:{(image: UIImage?, url: String) in
                cell.avatarImageView.image = image
            })
        }
        else {
            cell.avatarImageView.image = UIImage(named: "content-avatar-default")
        }
    }
    
    func animateButton(layer: SpringButton) {
        layer.animation = "pop"
        layer.force = 2
        layer.animate()
    }
    
    func upvoteButtonPressed(cell: StoriesTableViewCell, sender: AnyObject) {
        var indexPath = tableView.indexPathForCell(cell)
        
        animateButton(cell.upvoteButton)
    }
    
    func commentButtonPressed(cell: StoriesTableViewCell, sender: AnyObject) {
        var indexPath = tableView.indexPathForCell(cell)
        
        animateButton(cell.commentButton)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "storiesToArticleSegue" {
            let articleViewController = segue.destinationViewController as ArticleTableViewController
            articleViewController.data = sender
        }
    }
}