//
//  SP_RankingsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_RankingsViewController: UIViewController {
    @IBOutlet var rankingTableView: UITableView!
    @IBOutlet weak var potDateLabel: UILabel!
    
    var potDetail: [String: Any] = [:]
    var joineesArr : [String] = []
    
    private let winnerCellID = "SP_RankingWinnerTableViewCell"
    private let rankingCellID = "SP_RankingTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rankingTableView.register(UINib(nibName: winnerCellID, bundle: nil), forCellReuseIdentifier: winnerCellID)
        rankingTableView.register(UINib(nibName: rankingCellID, bundle: nil), forCellReuseIdentifier: rankingCellID)
        //TODO:- Add date, joinees
        guard let dateTimeStampStr = Int(potDetail["createdOn"] as! String) else { return  }
        let myTimeInterval = TimeInterval(dateTimeStampStr)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
        potDateLabel.text = time.dateAndTimetoString()
        joineesArr = potDetail["joinees"] as! [String]
        
        //Check round number - call API with round and league ID
        guard let roundNoStr = potDetail["round"] as? String else { return }
        //If currentRound == pot round, skip it
        getFixturesFrom(round: roundNoStr)
        
        //Check if match finished
        //Compare match scores
        //Compute 3 columns
    }
    
    func getFixturesFrom(round: String) {
        let localTimeZone = TimeZone.current.identifier //getNextFixtures
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getFixturesfromLeague + round + Constants.kTimeZone + localTimeZone,
                                     method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let response = response {
                if let fixturesArray = response["api"]["fixtures"].array, !fixturesArray.isEmpty {
                    
                }
            }
        }
    }
}
extension SP_RankingsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let winnerCell = tableView.dequeueReusableCell(withIdentifier: winnerCellID, for: indexPath) as! SP_RankingWinnerTableViewCell
            winnerCell.displayCell(data: potDetail, indexPath: indexPath)
            return winnerCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: rankingCellID, for: indexPath) as! SP_RankingTableViewCell
        cell.displayCell(data: potDetail, indexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joineesArr.count
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        }
        return UITableView.automaticDimension
    }
}
