//
//  MainTableViewController.swift
//  diveDiveApp
//
//  Created by Michiel Everts on 24-10-17.
//  Copyright © 2017 Michiel Everts. All rights reserved.
//

import UIKit
import Firebase


class MainTableViewController: UITableViewController {
    @IBOutlet weak var addName: UITextField!
    @IBOutlet weak var addocean: UITextField!
    @IBOutlet weak var addExperienceReq: UITextField!
    
    @IBOutlet weak var addImage: UITextField!
    
    @IBOutlet var addItemView: UIView!
    
    var diveAppObjects: [DiveAppProperties] = []
    var selectedDiveAppItem: DiveAppProperties?

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(addItemView)
//        self.addItemView.alpha = 0
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainTableViewController.notifyObservers(notification:)),
                                               name: NSNotification.Name(rawValue: notificationIDs.divingID),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainTableViewController.addObserver(notification:)),
                                               name: NSNotification.Name(rawValue: notificationIDs.addDivingID),
                                               object: nil)
        
        diveAppService.sharedInstance.getDiveData()
        diveAppService.sharedInstance.addBserver()
        let divingNib = UINib(nibName: "MainTableViewCell", bundle: nil)
        self.tableView.register(divingNib, forCellReuseIdentifier: tableCellIDs.MainTableViewCell)
    }
    
    @IBAction func openAddView(_ sender: Any) {
//        self.view.addSubview(addItemView)
//        self.addItemView.alpha = 1
        let alert = UIAlertController(title: "new dive site", message: "enter new dive site", preferredStyle: .alert)
        alert.addTextField { (diveNameField) in
            diveNameField.placeholder = "name"
        }
        alert.addTextField { (diveoceanField) in
            diveoceanField.placeholder = "ocean"
        }
        alert.addTextField { (diveExperienceReqField) in
            diveExperienceReqField.placeholder = "experienceReq"
        }
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { [weak alert] (_) in
            if let name = alert?.textFields?[0].text,
            let ocean = alert?.textFields?[1].text,
            let experienceReq = alert?.textFields?[2].text {
                let diveSite = ["name": name,
                                "ocean": ocean,
                                "experienceReq": experienceReq]
                diveAppService.sharedInstance.addDiveSite(dict: diveSite as NSDictionary)
            }


            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addDiveSite(){
        //generating a new key inside artists node
        //and also getting the generated key
        
        //creating artist with the given values
//        let diveSite = ["name": addName.text! as String,
//                        "ocean": addocean.text! as String,
//                        "experienceReq": addExperienceReq.text! as String]
//        diveAppService.sharedInstance.addDiveSite(dict: diveSite as NSDictionary)
        //adding the artist inside the generated unique key
//        self.addItemView.removeFromSuperview()
//        self.addItemView.alpha = 0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @objc func notifyObservers(notification: NSNotification) {
        var diveItemDict = notification.userInfo as! Dictionary<String , AnyObject>
        let status = diveItemDict["status"] as? Bool
        if status == true {
            if let diveSites = diveItemDict[dataKey.divingData] as? [DiveAppProperties] {
                diveAppObjects = diveSites
                self.tableView.reloadData()

            }
        } else {
            let message = diveItemDict["message"] as? String
            let alert = UIAlertController(title: "wel", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "oK", style: .cancel, handler: { (act) in
                //culd write custm cde
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func addObserver(notification: NSNotification) {
        var diveItemDict = notification.userInfo as! Dictionary<String, AnyObject>
        if let oneObject = diveItemDict[dataKey.divingData] as? DiveAppProperties {
            diveAppObjects.append(oneObject)
            self.tableView.reloadData()
        }
    }
    @objc func changedObserver(notification: NSNotification) {
        var diveItemDict = notification.userInfo as! Dictionary<String, AnyObject>
        if let oneObject = diveItemDict[dataKey.divingData] as? DiveAppProperties {
            diveAppObjects.append(oneObject)
            self.tableView.reloadData()
        }
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return diveAppObjects.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIDs.MainTableViewCell, for: indexPath) as! MainTableViewCell
        
        let diveSite = diveAppObjects[indexPath.row]
        cell.mainLabel.text = diveSite.name
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        selectedDiveAppItem = diveAppObjects[indexPath.row]
        performSegue(withIdentifier: seguesIdentifiers.detailTableViewSegue, sender: self)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == seguesIdentifiers.detailTableViewSegue{
            
            let detailView = segue.destination as! DetailTableViewController
            detailView.selectedDivingItem = self.selectedDiveAppItem
            
        }
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            diveAppService.sharedInstance.deleteDiveSite(diveSite: self.diveAppObjects[indexPath.row])
            diveAppObjects.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

