//
//  SP_MyPotsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 07/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore
struct PotModel {
    let fixturePredictionsArr : Array<Any>
    let createdOn : String
    let joinees : String
    let points : Int
}

class SP_MyPotsViewController: UIViewController {
    @IBOutlet weak var potTableView: UITableView!
    
    let cellID = "SP_MyPotsTableViewCell"
    var currentUser : String = UserDefaults.standard.string(forKey: UserDefaultsConstants.currentUserKey) ?? ""
    var myPotsArray : Array<Any> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.sp_mustard
        potTableView.register(UINib(nibName: "SP_MyPotsTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        getPotDataFromServer()
    }
    //MARK:- Fetch Pot Data

    func getPotDataFromServer() {
        let db = Firestore.firestore()
//        var potDetailDict : [String: Any] = [:]
        db.collection("user").document(currentUser).getDocument { (docSnapShot, error) in
            guard let snapshot = docSnapShot else {
                print("Error retreiving documents \(error!)")
                return
            }
            let joinedPotsArr = snapshot.data()?["joinedPots"] as! Array<String>
            for potID in joinedPotsArr {
                db.collection("pots").document(potID).getDocument { (docSnapShot, error) in
                    guard let potSnapshot = docSnapShot else {
                        print("Error retreiving documents \(error!)")
                        return
                    }
                    // Add each Pot details - createdOn and joinees in myPotsArray
//                    let createdOnStr = potSnapshot.data()?["createdOn"] as! String
//                    let joineesArr = potSnapshot.data()?["joinees"] as! Array <String>
//                    potDetailDict = ["createdOn": createdOnStr,
//                                     "joinees": joineesArr]
                    self.myPotsArray.append(potSnapshot.data() as Any)
                    self.potTableView.reloadData()
                }
            }
        }
    }
}


// MARK: - Table View

extension SP_MyPotsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return myPotsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MyPotsTableViewCell
        matchCell.displayCell(potDetails: myPotsArray[indexPath.section] as! [String : Any])
        return matchCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //SP_RankingsViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rvc = storyboard.instantiateViewController(identifier: "SP_RankingsViewController") as SP_RankingsViewController
        rvc.potDetail = myPotsArray[indexPath.section] as! [String: Any]
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80//UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
