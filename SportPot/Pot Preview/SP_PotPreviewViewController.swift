//
//  SP_PotPreviewViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 24/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_PotPreviewViewController: UIViewController {

    @IBOutlet weak var potTableView: UITableView!
    var potsArray: Array<FixtureMO> = []
    let cellID = "SP_MatchTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func letsGoAction(_ sender: Any) {
        
    }
}
extension SP_PotPreviewViewController : UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return potsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MatchTableViewCell
        matchCell.displayFixture(fixtureModel: potsArray[indexPath.section])
        return matchCell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
