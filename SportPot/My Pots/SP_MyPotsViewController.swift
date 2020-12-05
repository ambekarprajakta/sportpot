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

    var pots = [Pot]()
    
    let cellID = String(describing: SP_MyPotsTableViewCell.self)
    var currentUser = UserDefaults.standard.string(forKey: UserDefaultsConstants.currentUserKey) ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = UIColor.sp_mustard
        setupTable()
        getPotDataFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    private func setupTable() {
        potTableView.register(UINib(nibName: "SP_MyPotsTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        potTableView.rowHeight = 60
    }

    // MARK: - Fetch Pot Data

    func getPotDataFromServer() {
        let db = Firestore.firestore()
        self.potTableView.restore()
        db.collection("user").document(currentUser).getDocument { (docSnapShot, error) in
            guard let snapshot = docSnapShot else {
                print("Error retreiving documents \(error!)")
                return
            }
            guard let joinedPotsArr = snapshot.data()?["joinedPots"] as? Array<String> else {
                self.potTableView.setEmptyMessage("No Data Available")
                return
            }
            for potID in joinedPotsArr {
                db.collection("pots").document(potID).getDocument { [weak self] (docSnapShot, error) in
                    guard let self = self, let potJson = docSnapShot?.data(), let pot = potJson.to(type: Pot.self, keyDecodingStartegy: .convertFromSnakeCase) else { return }
                    pot.id = potID
                    self.pots.append(pot)
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
        return pots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SP_MyPotsTableViewCell {
            matchCell.display(pot: pots[indexPath.section])
            return matchCell
        }
        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rvc = storyboard.instantiateViewController(identifier: String(describing: SP_RankingsViewController.self)) as SP_RankingsViewController
        rvc.pot = pots[indexPath.section]
        self.navigationController?.pushViewController(rvc, animated: true)
    }

}
