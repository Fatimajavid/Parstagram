//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Fatima Javid on 10/8/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
    }
    
    func numberOfSections(in tableeView:UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            
            let url = URL(string: urlString)!
            cell.photoView.af.setImage(withURL: url)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row-1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
    }
    //If we tap on a cell, we can generate a comment to add.
    //So TableView supports selectionbyDefault so if I add a function didSelect
    //every time the user taps on an image, I will get a callback here.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
    //The way I create the comment object is the same way as I create any object
        //After we choose an object name.
        let comment = PFObject(className: "Comments")
        //All comments should have text
        comment["text"] = "This is a random comment"
        //I want the comment to know which post it belongs to.
        comment["post"] = post
        //I want to know who created the comment.
        comment["author"] = PFUser.current()!
        
        //So this is an object just like post was an object before I saved it. But this time I want to do
        post.add(comment, forKey: "comments")
        //Evert post should have an array called comments and I would like you to add this comment to the array.
        
        //Now I can save the post.
        post.saveInBackground{(success, error) in
            if success{
                print("Comment saved!")
            }
            else {
                print("Error saving comment!")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onLogoutButton(_ sender: Any) {
        //Clears the parse cache so from parse's perspective we are no longer signed in.
        PFUser.logOut()
        //So we want to switch the user back into the login screen.
        //Just like in persistent login, I have to give the storyboard I am using (the login page) a name.
        //1) Grab the storyboard
        let main = UIStoryboard(name: "Main", bundle: nil)
        //This is kind of parsing the xml?
        
        //2) I can instantiate the storyboard so
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        //Access to the window via the appdelegate,
        //so the app at any point can get a handle on the shared application object.
        //This is the one object that exists for each application.
        //I need to cast this so that its clear that this delegate is from appdelegate.
        //There is also something of type UI Application Delegate so casting can save us from any confusion or probable errors.
        //However, in the AppDelegate just the subclass has the window property and its not contained in the whole AppDlegate class, so I need to turn it into the AppDelegate.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate =
                windowScene.delegate as? SceneDelegate
                else { return }
        
        //Now I have access to that delegate and I can do
        delegate.window?.rootViewController = loginViewController
        //Once this runs you should immediately be able to switch into the loginViewController.
    }
    
}
