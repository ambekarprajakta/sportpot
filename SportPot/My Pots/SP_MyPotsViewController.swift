//
//  SP_MyPotsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 07/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SP_MyPotsViewController: UIViewController {
    @IBOutlet weak var potTableView: UITableView!
    
    let cellID = "SP_MyPotsTableViewCell"
    let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.sp_mustard
        potTableView.register(UINib(nibName: "SP_MyPotsTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        getPotDataFromServer()
    }
}

//MARK:- Fetch Pot Data

func getPotDataFromServer() {
    let db = Firestore.firestore()
//    let addFixturesRef = db.collection("pots").document(currentUser)
}

// MARK: - Table View

extension SP_MyPotsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3//potsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MyPotsTableViewCell
//        matchCell.displayFixture(fixtureModel: potsArray[indexPath.section])
        return matchCell
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
