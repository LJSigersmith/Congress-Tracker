//
//  BillViewController.swift
//  Congress 2
//
//  Created by Lance Sigersmith on 5/14/19.
//  Copyright © 2019 Lance Sigersmith. All rights reserved.
//

import UIKit

class BillViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var titleBox : UITextView?
    @IBOutlet var tableView : UITableView?
    @IBOutlet var billNumber : UILabel?
    @IBOutlet var actionView : UICollectionView?
    
    var bill : NSDictionary?
    var billURI : String?
    var actions : NSArray?
    var votes : NSArray?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 100 {
        return actions?.count ?? 0
        } else {
            return votes?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 100 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "action", for: indexPath)
        let date = cell.viewWithTag(10) as? UILabel
        let info = cell.viewWithTag(20) as? UITextView
        let chamber = cell.viewWithTag(30) as? UILabel
        let action = actions?[indexPath.row] as? NSDictionary
        
        date?.text = action?["datetime"] as? String
        info?.text = action?["description"] as? String
        chamber?.text = action?["chamber"] as? String
        return cell
        } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vote", for: indexPath)
            let date = cell.viewWithTag(10) as? UILabel
            let info = cell.viewWithTag(20) as? UITextView
            let chamber = cell.viewWithTag(30) as? UILabel
            let question = cell.viewWithTag(50) as? UILabel
            let result = cell.viewWithTag(40) as? UILabel
            let vote = votes?[indexPath.row] as? NSDictionary
            
            date?.text = vote?["date"] as? String
            info?.text = vote?["description"] as? String
            chamber?.text = vote?["chamber"] as? String
            question?.text = vote?["question"] as? String
            result?.text = vote?["result"] as? String
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sponsor", for: indexPath)
            let nameLbl = cell.viewWithTag(10) as? UILabel
            let stateLbl = cell.viewWithTag(20) as? UILabel
            let pic = cell.viewWithTag(40) as? UIImageView
            
            let sponsor = (bill?["sponsor_title"] as? String ?? "") + " " + (bill?["sponsor"] as? String ?? "")
            let state = "(\(bill?["sponsor_party"] as? String ?? "")) - \(bill?["sponsor_state"] as? String ?? "")"
            let id = bill?["sponsor_id"] as? String
            
            let img = UIImage(named: "person_placeholder.png")
            let prefix = id?.prefix(1)
            let imageUrl = "http://bioguide.congress.gov/bioguide/photo/\(prefix ?? "")/\(id ?? "").jpg"
            
            pic?.contentMode = UIView.ContentMode.scaleAspectFit
            //pic?.image = img
            pic?.downloadImageFrom(link: imageUrl, contentMode: UIView.ContentMode.scaleAspectFit, backup: "person_placeholder.png")
            nameLbl?.text = sponsor
            stateLbl?.text = state
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "actions", for: indexPath)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "votes", for: indexPath)
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Sponsor"}
        else if section == 1 { return "Actions"}
        else if section == 2 { return "Votes"}
        else { return "404" }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func getBill() {
        var request = URLRequest(url: URL(string: billURI ?? "")!)
        request.addValue("ejwe2qYUPHfjSZMADpAuBCHqIkN75KJ0UYSKqbtS", forHTTPHeaderField: "X-API-Key")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error)
            in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            do {
                var dictionary : NSDictionary?
                
                dictionary = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: AnyObject] as NSDictionary?
                let results = dictionary?["results"] as? NSArray
                self.bill = results?[0] as? NSDictionary
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                    let number = self.bill?["number"] as? String
                    let title = self.bill?["title"] as? String
                    let shtitle = self.bill?["short_title"] as? String
                    let summary = self.bill?["summary"] as? String
                    self.billNumber?.text = number ?? ""
                    self.titleBox?.text = "\(shtitle ?? "") \n\(title ?? "") \n\n\(summary ?? "")"
                    self.actions = self.bill?["actions"] as? NSArray
                    self.votes = self.bill?["votes"] as? NSArray
                }
                
            } catch let error as NSError {
                print(error)
            }
        
    }
        task.resume()
    }
    
    override func viewDidLoad() {
        
        tableView?.delegate = self
        tableView?.dataSource = self
        getBill()
    }
    
}
