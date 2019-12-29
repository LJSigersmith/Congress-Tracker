//
//  MemberViewContoller.swift
//  Congress 2
//
//  Created by Lance Sigersmith on 4/16/19.
//  Copyright © 2019 Lance Sigersmith. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MemberViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var name : UILabel?
    @IBOutlet var party : UILabel?
    @IBOutlet var image : UIImageView?
    @IBOutlet var switchControl : UISegmentedControl?
    
    var memberID : String = ""
    var voteURI : String = ""
    var recieved : [String:String] = [:]
    var member : NSDictionary = [:]
    var roles : NSArray = []
    var currentRole : NSDictionary = [:]
    var selectedIndex : Int = 0
    //var combinedCommittees : NSMutableArray = []
    var committees : NSArray = []
    var subcommittees : NSArray = []
    
    var mapView : MKMapView = MKMapView()
    
    @IBAction func back(sender: Any) {
        if (voteURI == "From Member") {
        let listVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MemberList") as UIViewController
            self.present(listVC, animated: true) {}
        } else {
        self.performSegue(withIdentifier: "back", sender: voteURI)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "back") {
            let votesViewControllerVar = segue.destination as! VotesViewController
            let stringS = sender as! String
            votesViewControllerVar.vote_uri = stringS
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch selectedIndex {
        case 0:
            return 2
        case 1:
            return 4
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedIndex {
        case 0:
            if (section == 0) {
                return 4
            } else {
                return 3
            }
        case 1:
            return 1
        case 2:
            switch section {
            case 0:
                return committees.count
            case 1:
                return subcommittees.count
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch selectedIndex {
        case 0:
            if (section == 0) {
                return "Bio"
            } else {
                return "Contact"
            }
        case 1:
            switch section {
            case 0:
                return "Twitter"
            case 1:
                return "YouTube"
            case 2:
                return "Facebook"
            case 3:
                return "Website"
            default:
                return ""
            }
        case 2:
            if section == 0 {
                return "Committees"
            } else {
                return "Subcommittees"
            }
        default:
            return "--"
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedIndex {
        case 0:
            if (indexPath.section == 1 && indexPath.row == 0) {
                return 200
            } else {
                return 44
            }
        case 2:
            return 60
        default:
            return 44
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Coordinates")
        let coordinates = view.annotation?.coordinate
        //URL: http://maps.apple.com/?ll=50.894967,4.341626
        let str = "http://maps.apple.com/?ll=\(coordinates?.latitude ?? 0.0),\(coordinates?.longitude ?? 0.0)&z=100"
        print(str)
        guard let url = URL(string: str) else { return }
        UIApplication.shared.open(url, options: [:]) { (true) in }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch selectedIndex {
        case 0:
            switch indexPath.section {
            case 1:
                switch indexPath.row {
                case 1:
                    print("Selected Address:")
                    let cell = tableView.cellForRow(at: indexPath)
                    var address = cell?.textLabel?.text
                    address = address?.replacingOccurrences(of: " ", with: "+")
                    let str = "http://maps.apple.com/?q=\(address ?? "")"
                    guard let url = URL(string: str) else { print("Address Cell Error"); return }
                    UIApplication.shared.open(url, options: [:]) { (true) in }
                default:
                    break
                }
            default:
                break
            }
        case 1:
            switch indexPath.section {
            case 0:
                print("Twitter select")
                let str = "twitter://user?screen_name=\(cell?.textLabel?.text ?? "")"
                guard let url = URL(string: str) else { return }
                if UIApplication.shared.canOpenURL(url) == true {
                UIApplication.shared.open(url, options: [:]) { (true) in }
                } else {
                guard let _url = URL(string: "https://twitter.com/\(cell?.textLabel?.text ?? "")") else { return }
                UIApplication.shared.open(_url, options: [:]) { (true) in }
                print("cant open twitter")
                }
            case 1:
                print("YT select")
                let str = "youtube://user?screen_name=\(cell?.textLabel?.text ?? "")"
                guard let url = URL(string: str) else { return }
                if UIApplication.shared.canOpenURL(url) == true {
                    UIApplication.shared.open(url, options: [:]) { (true) in }
                } else {
                    guard let _url = URL(string: "https://youtube.com/user/\(cell?.textLabel?.text ?? "")") else { return }
                    UIApplication.shared.open(_url, options: [:]) { (true) in }
                    print("cant open YT")
                }
            case 2:
                print("FB select")
                let str = "fb://profile?id=\(cell?.textLabel?.text ?? "")"
                guard let url = URL(string: str) else { return }
                if UIApplication.shared.canOpenURL(url) == true {
                    UIApplication.shared.open(url, options: [:]) { (true) in }
                } else {
                    guard let _url = URL(string: "https://facebook.com/\(cell?.textLabel?.text ?? "")") else { return }
                    UIApplication.shared.open(_url, options: [:]) { (true) in }
                    print("cant open FB")
                }
            case 3:
                print("URL select")
                    guard let _url = URL(string: cell?.textLabel?.text ?? "") else { return }
                    UIApplication.shared.open(_url, options: [:]) { (true) in }
                
            default:
                break
            }
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch selectedIndex {
        case 0:
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = currentRole["title"] as? String ?? ""
                case 1:
                    if (currentRole["chamber"] as? String == "House") {
                    cell.textLabel?.text = "District \(currentRole["district"] as? String ?? "")"
                    } else {
                        let rank = currentRole["state_rank"] as? String ?? ""
                        cell.textLabel?.text = "\(rank.capitalized(with: NSLocale.current)) Senator from \(currentRole["state"] ?? "")"
                    }
                case 2:
                    cell.textLabel?.text = "Sworn in \(currentRole["start_date"] as? String ?? "")"
                case 3:
                    cell.textLabel?.text = "Ending \(currentRole["end_date"] as? String ?? "")"
                default:
                    cell.textLabel?.text = ""
                }
            case 1:
                switch indexPath.row {
                case 0:
                    print("rendering mapview")
                    print(selectedIndex)
                    let mapView = MKMapView()
                    mapView.delegate = self
                    mapView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
                    mapView.mapType = MKMapType.hybrid
                    mapView.isScrollEnabled = true
                    mapView.isZoomEnabled = true
                    mapView.tag = 500
                    
                    guard var address = currentRole["office"] as? String else { return cell }
                    address = address + ", Washington, DC 20500"
                    let first = address.components(separatedBy: " ").first
                    
                    let range = first?.rangeOfCharacter(from: CharacterSet.decimalDigits)
                    if (range != nil) {
                        address = address.replacingOccurrences(of: first ?? "", with: "")
                    }
                    
                    print(address)
                    
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                        if((error) != nil){
                            print("Error", error ?? "")
                        }
                        if let placemark = placemarks?.first {
                            let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                            mapView.setCenter(coordinates, animated: true)
                            mapView.setRegion(MKCoordinateRegion(center: coordinates, latitudinalMeters: 100.0, longitudinalMeters: 100.0), animated: true)
                            let annot = MKPointAnnotation()
                            annot.coordinate = coordinates
                            annot.title = address
                            mapView.addAnnotation(annot)
                            print("Lat: \(coordinates.latitude) -- Long: \(coordinates.longitude)")
                        }
                    })
                    
                    
                    cell.addSubview(mapView)
                    
                case 1:
                    cell.textLabel?.text = currentRole["office"] as? String ?? ""
                case 2:
                    cell.textLabel?.text = currentRole["phone"] as? String ?? ""
                default:
                    cell.textLabel?.text = ""
                }
            default:
                cell.textLabel?.text = ""
            }
        case 1:
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = member["twitter_account"] as? String
            case 1:
                cell.textLabel?.text = member["facebook_account"] as? String
            case 2:
                cell.textLabel?.text = member["youtube_account"] as? String
            case 3:
                cell.textLabel?.text = member["url"] as? String
            default:
                break
            }
        case 2:
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            if indexPath.section == 0{
               let currentCommittee = committees[indexPath.row] as? NSDictionary
                let name = currentCommittee?["name"] as? String
                let title = currentCommittee?["title"] as? String
                cell.textLabel?.text = name
                cell.detailTextLabel?.text = title
            } else {
                let currentCommittee = subcommittees[indexPath.row] as? NSDictionary
                let name = currentCommittee?["name"] as? String
                let title = currentCommittee?["title"] as? String
                cell.textLabel?.text = name
                cell.detailTextLabel?.text = title
            }
            
            if let weirdMapViewThatWontGoAway = cell.viewWithTag(500) {
                print("got one boys")
                weirdMapViewThatWontGoAway.removeFromSuperview()
            }
        default:
            break
        }
        return cell
    }
    
    func getMemberInfo() {
        
        let url = "https://api.propublica.org/congress/v1/members/\(memberID).json"
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("ejwe2qYUPHfjSZMADpAuBCHqIkN75KJ0UYSKqbtS", forHTTPHeaderField: "X-API-Key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return }
            do {
                var dictionary : NSDictionary?
                
                dictionary = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String:AnyObject] as NSDictionary?
                
                let results = dictionary?["results"] as? NSArray
                self.member = results?[0] as? NSDictionary ?? [:]
                self.roles = self.member["roles"] as! NSArray
                self.currentRole = self.roles[0] as! NSDictionary
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                    let title = self.currentRole["short_title"] as? String
                    let fname = self.member["first_name"] as? String
                    let lname = self.member["last_name"] as? String
                    
                    let partyS = self.currentRole["party"] as? String
                    let stateS = self.currentRole["state"] as? String
                    
                    self.name?.text = "\(title ?? "") \(fname ?? "") \(lname ?? "")"
                    self.party?.text = "(\(partyS ?? "")) - \(stateS ?? "")"
                    
                    let prefix = self.memberID.prefix(1)
                    let imageUrl = "http://bioguide.congress.gov/bioguide/photo/\(String(describing: prefix))/\(self.memberID).jpg"
                    
                    self.image?.image = UIImage(named: "person_placeholder.png")
                    self.image?.contentMode = UIView.ContentMode.scaleAspectFit
                    self.image?.downloadImageFrom(link: imageUrl, contentMode: UIView.ContentMode.scaleAspectFit, backup: "person_placeholder.png")
                    
                    print(self.currentRole)
                    print("C")
                    print(self.currentRole["committees"])

                    print("S")
                    print(self.currentRole["subcommittees"])

                    let committeesT = self.currentRole["committees"] as! NSArray
                    let subcommitteesT = self.currentRole["subcommittees"] as! NSArray
                    self.committees = committeesT
                    self.subcommittees = subcommitteesT
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    @objc func handleSwitch () {
        switch switchControl?.selectedSegmentIndex {
        case 0:
            selectedIndex = 0
            tableView?.reloadData()
        case 1:
            selectedIndex = 1
            tableView?.reloadData()
        case 2:
            selectedIndex = 2
            mapView.removeFromSuperview()
            tableView?.reloadData()
        default:
            break
        }
        
    }
    
    override func viewDidLoad() {
        print(recieved)
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        memberID = recieved["member_id"] ?? ""
        voteURI = recieved["vote_uri"] ?? ""
        
        switchControl?.addTarget(self, action: #selector(self.handleSwitch), for: UIControl.Event.valueChanged)
        
        getMemberInfo()
        
        super.viewDidLoad()
    }
    
}
