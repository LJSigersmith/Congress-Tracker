//
//  VoteViewController.swift
//  Congress 2
//
//  Created by Lance Sigersmith on 4/12/19.
//  Copyright © 2019 Lance Sigersmith. All rights reserved.
//

import UIKit

class VoteViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView?
    var voteInfo : NSDictionary?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 6
        case 1:
            if let billInfo = voteInfo?["bill"] as? NSDictionary {
                if (billInfo.count > 0) {
                    if (billInfo["number"] as? String ?? "" == "JOURNAL") {
                        return 0
                    } else {
                    return 3
                    }
                } else {
                return 0
                }
            } else {
            return 0
            }
        case 2:
            return 5
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName : String
        switch section {
        case 0:
            sectionName = "Vote"
        case 1:
            sectionName = "Bill"
        case 2:
            sectionName = "Results"
        default:
            sectionName = "Section --"
        }
    return sectionName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 2 && indexPath.row == 1) {
            let senderS = voteInfo?["vote_uri"] as? String
            print("selectedRow")
            print(senderS)
            self.performSegue(withIdentifier: "votes", sender: senderS)
        }
        if (indexPath.section == 1 && indexPath.row == 2) {
            let bill = voteInfo?["bill"] as? NSDictionary
            let billURI = bill?["api_uri"]
            
            self.performSegue(withIdentifier: "bill", sender: billURI)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "votes") {
            let votesViewControllerVar = segue.destination as! VotesViewController
            let stringS = sender as? String ?? ""
            votesViewControllerVar.vote_uri = stringS
        }
        if (segue.identifier == "bill") {
            let billViewControllerVar = segue.destination as! BillViewController
            let billURI = sender as? String ?? ""
            billViewControllerVar.billURI = billURI
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = voteInfo?["chamber"] as? String
            case 1:
                if let congress = voteInfo?["congress"] as? Int {
                    cell.textLabel?.text = String(congress)
                }
            case 2:
                cell.textLabel?.text = voteInfo?["date"] as? String
            case 3:
                cell.textLabel?.text = voteInfo?["description"] as? String
            case 4:
                cell.textLabel?.text = voteInfo?["question"] as? String
            case 5:
                cell.textLabel?.text = voteInfo?["result"] as? String
            default:
                cell.textLabel?.text = ""
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let billInfo = voteInfo?["bill"] as? NSDictionary
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = billInfo?["number"] as? String
            case 1:
                cell.textLabel?.text = billInfo?["title"] as? String
            case 2:
                cell.textLabel?.text = "View Bill Details"
                cell.accessoryType = UITableViewCell.AccessoryType.detailDisclosureButton
            default:
                cell.textLabel?.text = ""
            }
        case 2:
            let rep = voteInfo?["republican"] as? NSDictionary
            let dem = voteInfo?["democratic"] as? NSDictionary
            let ind = voteInfo?["independent"] as? NSDictionary
            let all = voteInfo?["total"] as? NSDictionary
            
            guard let dem_no = dem?["no"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let dem_yes = dem?["yes"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let dem_p = dem?["present"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let dem_nv = dem?["not_voting"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            
            guard  let ind_no = ind?["no"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let ind_yes = ind?["yes"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let ind_p = ind?["present"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let ind_nv = ind?["not_voting"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            
            guard let rep_no = rep?["no"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let rep_yes = rep?["yes"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let rep_p = rep?["present"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let rep_nv = rep?["not_voting"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            
            guard let all_no = all?["no"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let all_yes = all?["yes"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let all_p = all?["present"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            guard let all_nv = all?["not_voting"] as? Int else { return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) }
            
            switch indexPath.row {
            case 0: do {
            print("voteCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "vote", for: indexPath)
            
            let diagram = cell.viewWithTag(100) as? UIScrollView
            diagram?.contentSize = cell.frame.size
            
            
            var total : Int
            if let no = (all?["no"] as? Int), let not_voting = (all?["not_voting"] as? Int), let present = (all?["present"] as? Int), let yes = (all?["yes"] as? Int) {
                
            
            var results : [UIColor] = []
            var labels : [String] = []
            
            if dem_no > 0 {
            for j in 1...dem_no {
                results.append(UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.4))
                labels.append("N")
                    //print("Added Blue NO: \(j)")
                }
            }
            if dem_yes > 0 {
            for j in 1...dem_yes {
                results.append(UIColor.blue)
                labels.append("Y")
                    //print("Added Blue YES: \(j)")
                }
            }
            if dem_p > 0 {
            for _ in 1...dem_p {
                results.append(UIColor.gray)
                labels.append("")
                }
            }
            if rep_no > 0 {
            for _ in 1...rep_no {
                results.append(UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.4))
                labels.append("N")
                }
            }
            if rep_yes > 0 {
            for _ in 1...rep_yes {
                results.append(UIColor.red)
                labels.append("Y")
                }
            }
            if rep_p > 0 {
            for _ in 1...rep_p {
                results.append(UIColor.gray)
                labels.append("")
                }
            }
            if ind_no > 0 {
            for _ in 1...ind_no {
                results.append(UIColor.init(red: 0.6, green: 0.4, blue: 0.2, alpha: 0.4))
                labels.append("N")
                }
            }
            if ind_yes > 0 {
            for _ in 1...ind_yes {
                results.append(UIColor.brown)
                labels.append("Y")
                }
            }
            if ind_p > 0 {
            for _ in 1...ind_p {
                results.append(UIColor.gray)
                labels.append("")
                }
            }
            if not_voting > 0 {
            for _ in 1...not_voting {
                results.append(UIColor.black)
                labels.append("")
                }
            }
            
                
            total = no + not_voting + present + yes
            print(total)
                let xmax = Int(((cell.frame.width))) - 30
                var y = 0
                var x = 0
                var width: Int
                var height: Int
                if voteInfo?["chamber"] as? String == "Senate" {
                    width = 15
                    height = 15
                } else {
                    width = 7
                    height = 7
                }
                for i in 0...(total - 1) {
                    if (x>xmax) { y = y+width+2; x = 0 }
                    let block = UIView(frame: CGRect(x: x+width, y: y, width: width, height: height))
                    //let lbl = UILabel(frame: CGRect(x: 3, y: 3, width: 10, height: 10))
                    
                    x = x+width+2

                    //print("I: \(i)")
                    //print("Out of: \(results.count)")
                    //lbl.text = labels[i]
                    block.backgroundColor = results[i]
                    //block.addSubview(lbl)
                    diagram?.addSubview(block)
                }
            
            }
            }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = "View Votes"
                cell.accessoryType = UITableViewCell.AccessoryType.detailDisclosureButton
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "party", for: indexPath)
                let yeaLbl = cell.viewWithTag(1) as? UILabel
                let nayLbl = cell.viewWithTag(2) as? UILabel
                let nvLbl = cell.viewWithTag(3) as? UILabel
                let pLbl = cell.viewWithTag(4) as? UILabel
                let headLbl = cell.viewWithTag(5) as? UILabel
                
                headLbl?.text = "Total"
                yeaLbl?.text = String(all_yes)
                nayLbl?.text = String(all_no)
                nvLbl?.text = String(all_nv)
                pLbl?.text = String(all_p)
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "party", for: indexPath)
                let yeaLbl = cell.viewWithTag(1) as? UILabel
                let nayLbl = cell.viewWithTag(2) as? UILabel
                let nvLbl = cell.viewWithTag(3) as? UILabel
                let pLbl = cell.viewWithTag(4) as? UILabel
                let headLbl = cell.viewWithTag(5) as? UILabel
                
                headLbl?.text = "Republican"
                yeaLbl?.text = String(rep_yes)
                nayLbl?.text = String(rep_no)
                nvLbl?.text = String(rep_nv)
                pLbl?.text = String(rep_p)
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "party", for: indexPath)
                let yeaLbl = cell.viewWithTag(1) as? UILabel
                let nayLbl = cell.viewWithTag(2) as? UILabel
                let nvLbl = cell.viewWithTag(3) as? UILabel
                let pLbl = cell.viewWithTag(4) as? UILabel
                let headLbl = cell.viewWithTag(5) as? UILabel
                
                headLbl?.text = "Democrat"
                yeaLbl?.text = String(dem_yes)
                nayLbl?.text = String(dem_no)
                nvLbl?.text = String(dem_nv)
                pLbl?.text = String(dem_p)
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "party", for: indexPath)
                let yeaLbl = cell.viewWithTag(1) as? UILabel
                let nayLbl = cell.viewWithTag(2) as? UILabel
                let nvLbl = cell.viewWithTag(3) as? UILabel
                let pLbl = cell.viewWithTag(4) as? UILabel
                let headLbl = cell.viewWithTag(5) as? UILabel
                
                headLbl?.text = "Independent"
                yeaLbl?.text = String(ind_yes)
                nayLbl?.text = String(ind_no)
                nvLbl?.text = String(ind_nv)
                pLbl?.text = String(ind_p)
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = ""
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = ""
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 2 && indexPath.row == 0) {
            print("height")
            return 150
        }
        if (indexPath.section == 2 && indexPath.row != 0  && indexPath.row != 1) {
            print("height")
            return 200
        }
        return 60
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        tableView?.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.reloadData()
        print(voteInfo)
        //getVoteInfo()
        super.viewDidLoad()
    }
    
    
}
