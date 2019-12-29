//
//  MemberListViewController.swift
//  Congress 2
//
//  Created by Lance Sigersmith on 4/18/19.
//  Copyright © 2019 Lance Sigersmith. All rights reserved.
//

import UIKit

class MemberListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

@IBOutlet var switchChamber : UISegmentedControl?
@IBOutlet var pickState : UIPickerView?
@IBOutlet var tableView : UITableView?

    var district : Int = 1
    var chamber : String = "senate"
    var members_url : String = "https://api.propublica.org/congress/v1/members/senate/AK/current.json"
    var members : NSArray = []
    var abbrev : String = "AK"
    let states = [ "AK - Alaska","AL - Alabama","AR - Arkansas","AS - American Samoa","AZ - Arizona","CA - California","CO - Colorado","CT - Connecticut","DC - District of Columbia","DE - Delaware","FL - Florida","GA - Georgia","GU - Guam","HI - Hawaii","IA - Iowa","ID - Idaho","IL - Illinois","IN - Indiana","KS - Kansas","KY - Kentucky","LA - Louisiana","MA - Massachusetts","MD - Maryland","ME - Maine","MI - Michigan","MN - Minnesota","MO - Missouri","MS - Mississippi","MT - Montana","NC - North Carolina","ND - North Dakota","NE - Nebraska","NH - New Hampshire","NJ - New Jersey","NM - New Mexico","NV - Nevada","NY - New York","OH - Ohio","OK - Oklahoma","OR - Oregon","PA - Pennsylvania","PR - Puerto Rico","RI - Rhode Island","SC - South Carolina","SD - South Dakota","TN - Tennessee","TX - Texas","UT - Utah","VA - Virginia","VI - Virgin Islands","VT - Vermont","WA - Washington","WI - Wisconsin","WV - West Virginia","WY - Wyoming"]
    let stateAbbrev = [ "AK","AL","AR","AS","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","UT","VA","VI","VT","WA","WI","WV","WY"]
    
    func getNumberOfDistricts(_ stateAbbrev: String) -> Int {

        var districtArray : NSMutableArray = []
        let group = DispatchGroup()

        // Loop through the urls array, in parallel
        DispatchQueue.concurrentPerform(iterations: 55) { i in
            group.enter()
            
            let url = "https://api.propublica.org/congress/v1/members/house/\(stateAbbrev)/\(i)/current.json"
            //print("URL: \(url)")
            var request = URLRequest(url: URL(string: url)!)
            request.addValue("ejwe2qYUPHfjSZMADpAuBCHqIkN75KJ0UYSKqbtS", forHTTPHeaderField: "X-API-Key")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Do your thing....
                guard let dataResponse = data, error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return
                }
                do {
                    var dictionary : NSDictionary?
                    
                    dictionary = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String:AnyObject] as NSDictionary?
                    
                    let statusReturn = dictionary?["status"] as? String ?? ""
                    //print("STATUS: \(statusReturn)")
                    if statusReturn == "ERROR" {
                       
                    } else {
                        districtArray.add(i)
                    }
                } catch let error as NSError {
                    print(error)
                }
                // Tell GCD you are done with a task
                group.leave()
                }.resume()
            
        }
        
        // Wait for all tasks to complete. Avoid calling this from the main thread!!!
        //dispatch_group_wait(group, dispatch_time_t(DISPATCH_TIME_FOREVER))
        group.wait(timeout: DispatchTime.distantFuture)
        
        // Now all your tasks have finished
        var high = 0
        for j in districtArray as! [Int] {
            if j > high { high = j }
        }
        print("Highest: \(high)")
        print(districtArray)
    return high
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let state = states[row]
        abbrev = String(state.prefix(2))
        if chamber == "house" {
        district = getNumberOfDistricts(abbrev)
        print("Districts: \(district)")
        }
        if chamber == "senate" {
            members_url = "https://api.propublica.org/congress/v1/members/\(chamber)/\(abbrev)/current.json"
            getMembers(reload: true)
        } else {
            var tempMembers : Array<Any> = []
            for i in 1...district {
                members_url = "https://api.propublica.org/congress/v1/members/\(chamber)/\(abbrev)/\(i)/current.json"
                getMembers(reload: false)
                tempMembers.append(contentsOf: members)
            }
            print(tempMembers)
            
        }
        print(members_url)
        tableView?.reloadData()
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nameLbl = cell.viewWithTag(10) as? UILabel
        let partyLbl = cell.viewWithTag(20) as? UILabel
        let image = cell.viewWithTag(40) as? UIImageView
        
        let member = members[indexPath.row] as? NSDictionary
        
        nameLbl?.text = "\(member?["first_name"] as? String ?? "") \(member?["last_name"] as? String ?? "")"
        
        let partyStr = member?["party"] as? String ?? "P"
        let stateStr = abbrev
        
        var fullStr : String = ""
        if chamber == "senate" {
            fullStr = "(\(partyStr))" + " - " + "\(stateStr)"
        } else {
            fullStr = "(\(partyStr))" + " - " + "\(stateStr)-\(district)"
        }
        partyLbl?.text = fullStr
        
        let memberID = member?["id"] as? String ?? ""
        let prefix = memberID.prefix(1)
        let imageUrl = "http://bioguide.congress.gov/bioguide/photo/\(String(describing: prefix))/\(memberID).jpg"
        
        image?.image = UIImage(named: "person_placeholder.png")
        image?.contentMode = UIView.ContentMode.scaleAspectFit
        print(nameLbl?.text)
        print(imageUrl)
        image?.downloadImageFrom(link: imageUrl, contentMode: UIView.ContentMode.scaleAspectFit, backup: "person_placeholder.png")
        
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = members[indexPath.row] as? NSDictionary
        let memberID = member?["id"] as? String ?? ""
        self.performSegue(withIdentifier: "member", sender: memberID)
        
        
    }
    func getMembers(reload: Bool) {
        var request = URLRequest(url: URL(string: members_url)!)
        request.addValue("ejwe2qYUPHfjSZMADpAuBCHqIkN75KJ0UYSKqbtS", forHTTPHeaderField: "X-API-Key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
            return
            }
            do {
                var dictionary : NSDictionary?
                
                dictionary = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String:AnyObject] as NSDictionary?
                
                let results = dictionary?["results"] as? NSArray
                self.members = []
                self.members = results ?? []
                //let result = results?[0] as? NSDictionary
                //self.members = []
                //self.members = result?["members"] as? NSArray ?? []
                print(self.members)
                if reload == true {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "member") {
            let memberViewControllerVar = segue.destination as! MemberViewController
            let memberID = sender as! String
            let dictionary = ["vote_uri":"From Member", "member_id":memberID]
            memberViewControllerVar.recieved = dictionary
        }
    }
    
    @objc func handleSwitch() {
        if switchChamber?.selectedSegmentIndex == 0{
            chamber = "house"
            district = getNumberOfDistricts(abbrev)
        } else {
            chamber = "senate"
        }
        tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        
        getMembers(reload: true)
        tableView?.delegate = self
        tableView?.dataSource = self
        
        pickState?.delegate = self
        pickState?.dataSource = self
        
        switchChamber?.addTarget(self, action: #selector(self.handleSwitch), for: UIControl.Event.valueChanged)
        
        super.viewDidLoad()
    }

}
