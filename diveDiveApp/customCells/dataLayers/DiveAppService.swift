//
//  diveAppService.swift
//  diveDiveApp
//
//  Created by Michiel Everts on 24-10-17.
//  Copyright © 2017 Michiel Everts. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseDatabase

class diveAppService {

public static let sharedInstance = diveAppService()  // Singleton: https://en.wikipedia.org/wiki/Singleton_pattern

private init() { // Singleton: https://en.wikipedia.org/wiki/Singleton_pattern
}

var ref: DatabaseReference!
    
    public func getDiveData() {
        ref = Database.database().reference()
        ref.observeSingleEvent(of: .value , with: { (snapshot) in
            if let data = snapshot.value as? NSDictionary,
                let status = data["status"] as? Bool,
                let message = data["message"] as? String,
                //            let timeStamp = data["date"] as? Int,
                let divingData = data["data"] as? [String : Any] {
                if status == true {
                    var itemArray:[DiveAppProperties] = []
                    for (key, diveSiteDict) in divingData {
                        if var divebjct = self.dictToDiveAppobj(dict: diveSiteDict as! NSDictionary) {
                            divebjct.id = key
                            itemArray.append(divebjct)
                        }

                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIDs.divingID),
                                                    object: self,
                                                    userInfo: [dataKey.divingData : itemArray, "status":status])
                } else {
                    print(message)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIDs.divingID),
                                                    object: self,
                                                    userInfo: ["status":status,"message":message])
                }
                
            }
        })
        
    }
    
    func addBserver() {
        self.ref.child("data").observe(.childAdded, with: { (snapshot) in
            if let data = snapshot.value as? NSDictionary,
                let itemObject = self.dictToDiveAppobj(dict: data) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationIDs.addDivingID),
                                                object: self,
                                                userInfo: [dataKey.divingData : itemObject, "status": true])
            }
        })
    }
    func removeBserver() {
        self.ref.child("data").observe(.childRemoved, with: { (snapshot) in
            if let data = snapshot.value as? NSDictionary,
                let itemObject = self.dictToDiveAppobj(dict: data) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationIDs.removeDivingID),
                                                object: self,
                                                userInfo: [dataKey.divingData : itemObject, "status": true])
            }
        })
    }

    
    func getValue(itemDict: NSDictionary) -> DiveAppProperties? {
        let decoder = JSONDecoder()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: itemDict, options: .prettyPrinted)
            let item = try decoder.decode(DiveAppProperties.self, from: jsonData)
            return item
        } catch {
            return nil
        }
    }
    
    func addDiveSite(dict: NSDictionary) {
        let key = ref.child("data").childByAutoId().key
        ref.child("data").child(key).setValue(dict)

    }
    func deleteDiveSite(diveSite: DiveAppProperties){
        ref.child("data").child(diveSite.id).removeValue()
    }
    func changeDiveSite(diveSite: DiveAppProperties){
        let diveDict = objectToDict(diveSite: diveSite)
        ref.child("data").child(diveSite.id).updateChildValues(diveDict!)
    }
    func dictToDiveAppobj(dict: NSDictionary) -> DiveAppProperties? {
        if let name = dict["name"] as? String,
            let ocean = dict["ocean"] as? String,
            let experienceReq = dict["experienceReq"] as? String {
        
            let imageURLS = dict["imageURLS"] as? [String] ?? []
            let diveSiteProperties = DiveAppProperties.init(name: name,
                                                            ocean: ocean,
                                                            experienceReq: experienceReq,
                                                            imageURLS: imageURLS,
                                                            id: "")
            return diveSiteProperties
        }
        return nil
    }
    
    func objectToDict(diveSite: DiveAppProperties) -> Dictionary<String, Any>? {
        var dictData: [String : Any] = [:]
        dictData["name"] = diveSite.name
        dictData["ocean"] = diveSite.ocean
        dictData["experienceReq"] = diveSite.experienceReq
        
        return dictData
    }
}
