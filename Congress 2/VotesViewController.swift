//
//  VotesViewController.swift
//  Congress 2
//
//  Created by Lance Sigersmith on 4/15/19.
//  Copyright © 2019 Lance Sigersmith. All rights reserved.
//

import UIKit

class VotesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var vote_uri : String = ""
    var voteInfo : NSDictionary?
    var votePositions : [NSDictionary] = []
    var yesPositions : [NSDictionary] = []
    var noPositions : [NSDictionary] = []
    var nvPositions : [NSDictionary] = []
    var presPositions : [NSDictionary] = []
    var dataSet : Int = 0
    var currentInfo : [NSDictionary] = []
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var switchControl : UISegmentedControl?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataSet {
        case 0:
            return votePositions.count
        case 1:
            return yesPositions.count
        case 2:
            return noPositions.count
        case 3:
            return nvPositions.count
        case 4:
            return presPositions.count
        default:
            print("Error with NumRows")
            return votePositions.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position = currentInfo[indexPath.row]
        let memberID = position["member_id"]
        self.performSegue(withIdentifier: "member", sender: memberID)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nameLbl = cell.viewWithTag(10) as? UILabel
        let partyLbl = cell.viewWithTag(20) as? UILabel
        let voteLbl = cell.viewWithTag(30) as? UILabel
        let image = cell.viewWithTag(40) as? UIImageView
        
        let position = currentInfo[indexPath.row]
        
        nameLbl?.text = position["name"] as? String
        voteLbl?.text = position["vote_position"] as? String
        
        let partyStr = position["party"] as? String ?? "P"
        let stateStr = position["state"] as? String ?? "ST"
        
        let fullStr = "(\(partyStr))" + " - " + "\(stateStr)"
        partyLbl?.text = fullStr
        
        let memberID = position["member_id"] as? String ?? ""
        let prefix = memberID.prefix(1)
        let imageUrl = "http://bioguide.congress.gov/bioguide/photo/\(String(describing: prefix))/\(memberID).jpg"
        //print(imageUrl)
        
        image?.image = UIImage(named: "person_placeholder.png")
        image?.contentMode = UIView.ContentMode.scaleAspectFit
        print(nameLbl?.text)
        print(imageUrl)
        image?.downloadImageFrom(link: imageUrl, contentMode: UIView.ContentMode.scaleAspectFit, backup: "person_placeholder.png")
        
        return cell
    }
    
    
    func getVoteInfo() {
        
        var request = URLRequest(url: URL(string: vote_uri)!)
        request.addValue("ejwe2qYUPHfjSZMADpAuBCHqIkN75KJ0UYSKqbtS", forHTTPHeaderField: "X-API-Key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return }
            do {
                var dictionary : NSDictionary?
                
                dictionary = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String:AnyObject] as NSDictionary?
                
                let results = dictionary?["results"] as? NSDictionary
                let votes = results?["votes"] as? NSDictionary
                let vote = votes?["vote"] as? NSDictionary
                self.voteInfo = vote
                self.votePositions = vote?["positions"] as? [NSDictionary] ?? []
                self.currentInfo = self.votePositions
                self.voteInfo = vote
                //print(self.votePositions)
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
                self.createDicts()
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    func createDicts() {
        for i in 0...(votePositions.count - 1) {
            let position = votePositions[i]
            let vote = position["vote_position"] as? String
            
            switch vote {
            case "Yes":
                yesPositions.append(position)
            case "No":
                noPositions.append(position)
            case "Not Voting":
                nvPositions.append(position)
            case "Present":
                presPositions.append(position)
            default:
                print("Error with Position: \(String(describing: vote))")
            }
        }
    }
    
    @IBAction func back(sender:Any) {
    
        self.performSegue(withIdentifier: "back", sender: voteInfo)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "back") {
            let voteViewControllerVar = segue.destination as! VoteViewController
            let dictionaryO = sender as! NSDictionary
            let dictionaryC = dictionaryO.mutableCopy() as! NSMutableDictionary
            dictionaryC["vote_uri"] = vote_uri
            let dictionary = NSDictionary(dictionary: dictionaryC)
            voteViewControllerVar.voteInfo = dictionary
        }
        if (segue.identifier == "member") {
            let memberViewControllerVar = segue.destination as! MemberViewController
            let memberID = sender as! String
            let dictionary = ["vote_uri":vote_uri, "member_id":memberID]
            memberViewControllerVar.recieved = dictionary
        }
    }
    
    @objc func handleSwitch() {
        
        currentInfo = []
        
        switch switchControl?.selectedSegmentIndex {
        case 0:
            dataSet = 0
            currentInfo = votePositions
            tableView?.reloadData()
        case 1:
            dataSet = 1
            currentInfo = yesPositions
            tableView?.reloadData()
        case 2:
            dataSet = 2
            currentInfo = noPositions
            tableView?.reloadData()
        case 3:
            dataSet = 3
            currentInfo = nvPositions
            tableView?.reloadData()
        case 4:
            dataSet = 4
            currentInfo = presPositions
            tableView?.reloadData()
        default:
            print("Error: with Switch Control")
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        print(vote_uri)
        tableView?.delegate = self
        tableView?.dataSource = self
        
        switchControl?.addTarget(self, action: #selector(self.handleSwitch), for: UIControl.Event.valueChanged)
        
        getVoteInfo()
     
        super.viewDidLoad()
    }
    
}
