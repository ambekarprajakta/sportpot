//
//  SP_PotPreviewViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 24/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import CoreData
import FirebaseFirestore

class SP_PotPreviewViewController: UIViewController {

    @IBOutlet weak var potTableView: UITableView!
    @IBOutlet weak var totalPointsLabel: UILabel!
    
    var fixturesArray = Array<FixtureModel>()
    var predictedFixtures = [Prediction]()
    var fixturePoints = Array<FixturePoints>()
    var pot : Pot!
    let cellID = "SP_MatchTableViewCell"
    var groups = [String]()
    let currentUser = UserDefaults.standard.string(forKey: UserDefaultsConstants.currentUserKey) ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        potTableView.delegate = self
        potTableView.dataSource = self
        potTableView.register(UINib(nibName: "SP_MatchTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        setupNavigationBar()
//        getFixturesFromServer(with: groups)
        getCurrentWeekForPoints()
    }
    private func setupNavigationBar() {
        let logo = UIImage(named: "logo-sport-pot.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    fileprivate func getCurrentWeekForPoints() {
        self.showHUD()
        Firestore.firestore().collection("currentWeekForPoints").document("currentWeek").getDocument { (docSnapShot, error) in
            self.hideHUD()
            if error == nil {
                guard let currentWeekStr = docSnapShot?.data() else { return }
                guard let round = self.pot.round else {return}
                guard let weekNums = currentWeekStr["currentRound"] as? [String:[String]] else {return}
                self.groups = weekNums[round] ?? [String]()
                self.getFixturesFromServer(with: self.groups)
            }
        }
    }

    private func getFixturesFromServer(with group: [String]) {
        
        if fixturesArray.isEmpty {
            self.potTableView.restore()
//            refreshControl.beginRefreshing()
        }
        let localTimeZone = TimeZone.current.identifier
        self.showHUD()
        
        self.fixturesArray.removeAll()
        var cnt = 0
        for round in group {
            SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getFixturesfromLeague +
                                            round + Constants.kTimeZone + localTimeZone,
                                         method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
                guard let strongSelf = self else { return }
                strongSelf.hideHUD()
                if let response = response {
                    
                    if let fixtures = response["api"]["fixtures"].arrayObject as? JSONArray {
                        if fixtures.count == 0 {
                            self?.potTableView.setEmptyMessage("No Data Available")
                            return
                        }
                        let fixturesArray = fixtures.toArray(of: FixtureModel.self) ?? []
                        strongSelf.fixturesArray.append(contentsOf: fixturesArray)
                        cnt+=1
                        if cnt == group.count {
                            strongSelf.getFixturesFromLocalDB()
                        }
                    } else {
                        self?.potTableView.setEmptyMessage("No Data Available")
                    }
                }
            }
        }
        
    }

    private func getFixturesFromLocalDB() {
        Firestore.firestore().collection("fixturePoints").document(pot.round ?? "").getDocument { (docSnapShot, error) in
            self.hideHUD()
            if error == nil {
                if let response = docSnapShot?.data() {
                    let fixturePointsArray = response["0"] as? [[String: Any]]
                    self.fixturePoints = fixturePointsArray?.toArray(of: FixturePoints.self) ?? Array<FixturePoints>()
                    print(self.fixturePoints)
                    self.getPredictions()
                }
            } else {
                print("No Data available")
            }
        }
    }
    
    func getPredictions(){
        pot.joinees.forEach { (joineeObj) in
            if joineeObj.joinee == currentUser {
                predictedFixtures = joineeObj.predictions
            }
        }
        mapFixturePredictions()
    }
    
    private func mapFixturePredictions() {
        for i in 0..<fixturesArray.count {
            if let predObj = predictedFixtures.first(where: {$0.fixtureId == fixturesArray[i].fixture_id}) {
                fixturesArray[i].predictionType = PredictionType(rawValue: predObj.selection)
                fixturesArray[i].isDoubleDown = predObj.isDoubleDown
                if let points = fixturePoints.first(where: {$0.fixtureId == fixturesArray[i].fixture_id}) {
                    switch fixturesArray[i].predictionType {
                    case .home:
                        fixturesArray[i].selectedPoints = points.home
                    case .away:
                        fixturesArray[i].selectedPoints = points.away
                    case .draw:
                        fixturesArray[i].selectedPoints = points.draw
                    default:
                        break
                    }
                }
            }
        }
        fixturesArray = fixturesArray.filter({$0.predictionType != nil})
        updatePoints()
        potTableView.reloadData()
    }
    
    func updatePoints() {
        var totalPoints = 0
        var selectedPoints = 0
        for fObj in fixturesArray {
            if fObj.isDoubleDown ?? false {
                selectedPoints = (fObj.selectedPoints ?? 0) * 2
            } else {
                selectedPoints = fObj.selectedPoints ?? 0
            }
            
            totalPoints += selectedPoints
        }
        print("TOTAL POINTS => \(totalPoints)")
        totalPointsLabel.text = String(format: "%d",totalPoints)
    }
    
    @IBAction func letsGoAction(_ sender: Any) {
        
    }
}
extension SP_PotPreviewViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return fixturesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MatchTableViewCell
        if let points = fixturePoints.first(where: {$0.fixtureId == fixturesArray[indexPath.section].fixture_id}){
            matchCell.displayFixture(fixtureModel: fixturesArray[indexPath.section], points: points, isPotPreview: true)
            matchCell.updateSelection(fixture: fixturesArray[indexPath.section])
        }
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
