//
//  ViewController.swift
//  Congress 2
//
//  Created by Lance Sigersmith on 4/3/19.
//  Copyright © 2019 Lance Sigersmith. All rights reserved.
//

import UIKit

class ViewController: UIViewController, XMLParserDelegate, UITableViewDataSource, UITableViewDelegate {

    

    @IBOutlet var tableView : UITableView?
    
    
    @IBAction func switchSenate(sender: UIBarButtonItem) {
        chamber = 0
        tableView?.reloadData()
    }
    
    @IBAction func switchHouse(sender: UIBarButtonItem) {
        chamber = 1
        tableView?.reloadData()
    }
    
    
    var currentContent = String()
    
    var isVote = false
    var alt = true
    var chamber = 0
    
    var senateVotes : [NSDictionary] = []
    var houseVotes : [NSDictionary] = []
    
    class VoteCell : UITableViewCell {
        
        @IBOutlet public var descriptionLbl : UILabel?
        @IBOutlet public var resultLbl : UILabel?
        @IBOutlet public var issueLbl : UILabel?
        
    }

    func getHouseVotes() {
        var request = URLRequest(url: URL(string: "https://api.propublica.org/congress/v1/house/votes/recent.json")!)
        request.addValue("ejwe2qYUPHfjSZMADpAuBCHqIkN75KJ0UYSKqbtS", forHTTPHeaderField: "X-API-Key")
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do {
                
                var dictonary:NSDictionary?
                
                dictonary = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String:AnyObject] as NSDictionary?
                
                let results = dictonary?["results"] as? NSDictionary
                let votes = results?["votes"] as? NSArray
                
                for vote in votes ?? [] {
                    var currentObj : NSDictionary
                    currentObj = vote as! NSDictionary
                    self.houseVotes.append(currentObj)
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                }
                
            } catch let error as NSError {
                        print(error)
            }
        }
        task.resume()
        
    }
    func getSenateVotes() {
        var request = URLRequest(url: URL(string: "https://api.propublica.org/congress/v1/senate/votes/recent.json")!)
        request.addValue("ejwe2qYUPHfjSZMADpAuBCHqIkN75KJ0UYSKqbtS", forHTTPHeaderField: "X-API-Key")
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do {
                
                var dictonary:NSDictionary?
                
                dictonary = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String:AnyObject] as NSDictionary?
                
                let results = dictonary?["results"] as? NSDictionary
                let votes = results?["votes"] as? NSArray
                
                for vote in votes ?? [] {
                    var currentObj : NSDictionary
                    currentObj = vote as! NSDictionary
                    self.senateVotes.append(currentObj)
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                    
                }
                
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentObj : NSDictionary?
        
        if (chamber == 0) {
        currentObj = senateVotes[indexPath.row]
        } else {
        currentObj = houseVotes[indexPath.row]
        }
        let senderD = currentObj
        self.performSegue(withIdentifier: "voteSegue", sender: senderD)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("Rows")
        if (chamber == 0) {
            return senateVotes.count
        } else {
            return houseVotes.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let description = cell.viewWithTag(10) as? UILabel
        let result = cell.viewWithTag(20) as? UILabel
        let issue = cell.viewWithTag(30) as? UILabel
        
        
        if (chamber == 0) {
            let currentObj = senateVotes[indexPath.row]
            
            description?.text = currentObj["question"] as? String ?? "Description"
            result?.text = currentObj["result"] as? String
            issue?.text = currentObj["description"] as? String
        } else {
            let currentObj = houseVotes[indexPath.row]
            
            description?.text = currentObj["question"] as? String ?? "Description"
            result?.text = currentObj["result"] as? String
            issue?.text = currentObj["description"] as? String
        }
        if (alt == true) {
            alt = false;
            cell.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1.0)
        } else {
            alt = true
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "voteSegue") {
            let voteViewControllerVar = segue.destination as! VoteViewController
            let dictionary = sender as! NSDictionary
            voteViewControllerVar.voteInfo = dictionary
        }
    }
    
    override func viewDidLoad() {

        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        self.view.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        
        getSenateVotes()
        getHouseVotes()
        
        let button = UIBarButtonItem()
        switchSenate(sender: button)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

