//
//  SP_RankingsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SP_RankingsViewController: UIViewController {

    @IBOutlet private weak var rankingTableView: UITableView!
    @IBOutlet private weak var potDateLabel: UILabel!
    @IBOutlet private weak var lastUpdatedLabel: UILabel!
//    private var fixturesPointsArray = Array<[String]>()
    var fixturePoints = Array<FixturePoints>()

    var pot: Pot!
    private var joinees = [Joinee]()
    private var fixturesArr = [FixtureModel]()
    private let winnerCellID = String(describing: SP_RankingWinnerTableViewCell.self)
    private let rankingCellID = String(describing: SP_RankingTableViewCell.self)
    private var winner: String = ""
    private var isWinnerDeclared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rankingTableView.register(UINib(nibName: winnerCellID, bundle: nil), forCellReuseIdentifier: winnerCellID)
        rankingTableView.register(UINib(nibName: rankingCellID, bundle: nil), forCellReuseIdentifier: rankingCellID)
        rankingTableView.tableFooterView = UIView()
        
        let dateTimeStampStr = Double(pot.createdOn) ?? 0
        let myTimeInterval = TimeInterval(dateTimeStampStr)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
        potDateLabel.text = pot.name //time.dateAndTimetoString()
        if (pot.joinees.filter({$0.isWinner()}).count != 0) {
            isWinnerDeclared = true
        }

        getFixturePoints()
        //Check round number - call API with round and league ID
//        guard let roundNoStr = potDetail["round"] as? String else { return }
        //If currentRound == pot round, skip it
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    @IBAction func sharePotAction(_ sender: Any) {
        var baseStr = Constants.kDYNAMIC_LINK_BASE_URL
        baseStr.append("/" + pot.potID)
        let message = "Check out the pot I just created on Sportpot!"
        let activityVC = UIActivityViewController(activityItems: [message, baseStr], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
//    func getCurrentWeekForPoints() {
//        self.showHUD()
//        Firestore.firestore().collection("currentWeekForPoints").document("currentWeek").getDocument { (docSnapShot, error) in
//            self.hideHUD()
//            guard let currentWeekStr = docSnapShot?.data() else { return }
//            guard let weekNumStr = currentWeekStr["weekNo"] else { return }
//            self.getFixturePointsForWeek(week: weekNumStr as! String)
//        }
//    }
    
    func getFixturePoints(){
        self.showHUD()
        Firestore.firestore().collection("fixturePoints").document(pot.round ?? "").getDocument { (docSnapShot, error) in
            self.hideHUD()
            if let response = docSnapShot?.data() {
                let fixturePointsArray = response["0"] as? [[String: Any]]
                self.fixturePoints = fixturePointsArray?.toArray(of: FixturePoints.self) ?? Array<FixturePoints>()
                print(self.fixturePoints)
            } else {
                
            }
            if let round = self.pot.round{
                self.getFixturesFrom(round: round)
            } else {
                self.joinees.append(contentsOf: self.pot.joinees)
                self.rankingTableView.reloadData()
            }
        }
    }
    
    func getFixturesFrom(round: String) {
        self.showHUD()
        let localTimeZone = TimeZone.current.identifier
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getFixturesfromLeague + round + Constants.kTimeZone + localTimeZone, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            self?.hideHUD()
            guard let self = self else { return }
            if let response = response {
                if let fixtures = response["api"]["fixtures"].arrayObject as? JSONArray {
                    let fixturesArray = fixtures.toArray(of: FixtureModel.self) ?? [] //, keyDecodingStartegy: .convertFromSnakeCase) ?? []
                    self.fixturesArr = fixturesArray
                    self.compareScoresFrom(fixturesArr: self.fixturesArr)
                }
            }
        }
    }
    
    func allMatchesPlayed(fixturesArr : [FixtureModel]) -> Bool {
        var allPlayed = false
        for fixture in fixturesArr {
            if fixture.statusShort == "FT" {
                allPlayed = true
            } else {
                allPlayed = false
            }
        }
        return allPlayed
    }
    
    func compareScoresFrom(fixturesArr: [FixtureModel]) {
        if pot.joinees.isEmpty { return }
        
        var allJoinees = [Joinee]()
        
        // Score calculation logic
        pot.joinees.forEach { (joinee) in
            var accuracy: Int = 0
            var doubleDown: Int = 0
            var pointsScored: Int = 0
            var i = 0
            joinee.predictions.forEach { (prediction) in
                
                for fixture in fixturesArr {
                    let points = fixturePoints[i]
                    let homePoints = points.home
                    let drawPoints = points.draw
                    let awayPoints = points.away
                    
                    if fixture.fixture_id == prediction.fixtureId {
                        if fixture.isMatchOnGoing() {
                            i+=1
                            if fixture.goalsAwayTeam == fixture.goalsHomeTeam {
                                // Draw
                                if prediction.selection == 2 {
                                    accuracy+=1
                                    if prediction.getIsDoubleDown() {
                                        doubleDown+=1
                                        pointsScored+=(drawPoints*2)
                                    } else {
                                        pointsScored+=drawPoints
                                    }
                                }
                            } else if fixture.goalsAwayTeam ?? 0 > fixture.goalsHomeTeam ?? 0 {
                                // Away team won
                                if prediction.selection == 3 {
                                    accuracy+=1
                                    if prediction.getIsDoubleDown() {
                                        doubleDown+=1
                                        pointsScored+=(awayPoints*2)
                                    } else {
                                        pointsScored+=awayPoints
                                    }
                                }
                            } else {
                                // Home team won
                                if prediction.selection == 1 {
                                    accuracy+=1
                                    if prediction.getIsDoubleDown() {
                                        doubleDown+=1
                                        pointsScored+=(homePoints*2)
                                    } else {
                                        pointsScored+=homePoints
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }

            let joineeCopy = joinee.copy()
            var actualAccuracy : Double = Double(accuracy) / Double(joineeCopy.predictions.count)
            actualAccuracy = actualAccuracy * 100
            joineeCopy.accuracy = Int(actualAccuracy)
            joineeCopy.doubleDown = doubleDown
            joineeCopy.pointsScored = pointsScored
            allJoinees.append(joineeCopy)
        }
        
        enum SortBy {
            case accuracy
            case doubleDown
        }
        var sortBy: SortBy = .accuracy
        
        // Winner logic
        var winners = [Joinee]()    // To hold all the unique winners

        // Check winner based on highest accuracy
        let joineesSortedByHighestAccuracy = allJoinees.sorted(by: { (j1, j2) -> Bool in
            return j1.accuracy ?? 0 > j2.accuracy ?? 0
        })

        // Check if there are multiple winners
        let highestAccuracy = joineesSortedByHighestAccuracy[0].accuracy
        let highestAccuracyWinners = joineesSortedByHighestAccuracy.filter({$0.accuracy == highestAccuracy})
        if highestAccuracyWinners.count > 0 {

            // We have multiple winners
            // Check for highest double down among the winners only
            let joineesSortedByHighestDoubleDown = highestAccuracyWinners.sorted(by: { (j1, j2) -> Bool in
                return j1.doubleDown ?? 0 > j2.doubleDown ?? 0
            })

            let highestDoubleDown = joineesSortedByHighestDoubleDown[0].doubleDown ?? 0
            let highestDoubleDownWinners = joineesSortedByHighestDoubleDown.filter({$0.doubleDown == highestDoubleDown})
            if highestDoubleDownWinners.count > 0 {

                /// `highestDoubleDownWinners` will contain at least one joinee
                /// If it contains more than 1 joinee, still all are winners
                /// Add all the double down winners
                winners.append(contentsOf: highestDoubleDownWinners)
                if highestAccuracyWinners.count <  highestDoubleDownWinners.count{
                    sortBy = .doubleDown
                }
            } else {
                // Since double down is 0 for all the winners with highest accuracy, they are the only winners
                winners.append(contentsOf: highestAccuracyWinners)
            }

        } else {
            /// `highestAccuracyWinners` will contain only contain one joinee at this point
            winners.append(contentsOf: highestAccuracyWinners)
        }

            // Clear all the joinees if any
        joinees.removeAll()
        
        allJoinees.forEach { (joinee) in
            let copyJoinee = joinee.copy()
                if self.allMatchesPlayed(fixturesArr: self.fixturesArr) {
                    if self.shouldComputeWinner(joinees: pot.joinees) {
                    copyJoinee.winner = false
                    //Declare winner and add notification to all the players
                    if copyJoinee.accuracy ?? 0 > 0 {
                        copyJoinee.winner = winners.contains(joinee)
//                        joinee.winner = winners.contains(joinee)
                    }
                }
            }
            joinees.append(copyJoinee)
        }
        

        if allMatchesPlayed(fixturesArr: self.fixturesArr) {
            // Winners computed, sort the joinees so that it shows winners at the top
            joinees.sort(by: { $0.isWinner() && !$1.isWinner() })
        } else {
            joinees.sort { (lhs, rhs) -> Bool in
                if sortBy == .accuracy {
                    return (lhs.accuracy ?? 0) > (rhs.accuracy ?? 0)
                } else {
                    return (lhs.doubleDown ?? 0) > (rhs.doubleDown ?? 0)
                }
            }
        }

        updatePotToFirebase()
        if self.allMatchesPlayed(fixturesArr: self.fixturesArr) {
            if !isWinnerDeclared && !shouldComputeWinner(joinees: joinees){ //winner declared
                self.addNotificationToAllPlayers()
            }
        }
        rankingTableView.reloadData()
    }

//    private func shouldComputeWinner() -> Bool {
//        /// If the winner data is available, the `winner` property will never be nil.
//        var winners = [String]()
//        for joinee in pot.joinees {
//            /// If the `winner` property is nil for any joinee it means winner data is not available on Firebase.
//            if joinee.winner == nil {
//                return true
//            } else if joinee.winner == true {
//                winners.append(joinee.displayName ?? "")
//            }
//        }
//        if winners.count > 0 {
//            winner = winnerString(from: winners)
//        }
//        return false
//    }

    private func shouldComputeWinner(joinees: [Joinee]) -> Bool {
        /// If the winner data is available, the `winner` property will never be nil.
        var winners = [String]()
        for joinee in joinees {
            /// If the `winner` property is nil for any joinee it means winner data is not available on Firebase.
            if joinee.winner == nil {
                return true
            } else if joinee.winner == true {
                winners.append(joinee.displayName ?? "")
            }
        }
        if winners.count > 1 {
            winner = winnerString(from: winners)
        } else {
            winner = winners.first ?? ""
        }
        return false
    }

    func winnerString(from winnerArray: [String]) -> String {
        return winnerArray.sentence
    }
    
    private func updatePotToFirebase() {
        let jsonEncoder = JSONEncoder()
        guard let potId = pot.id else { return }
        guard let joineesData = try? jsonEncoder.encode(joinees) else { return }
        guard let joineesJsonArray = try? JSONSerialization.jsonObject(with: joineesData, options: .allowFragments) as? JSONArray else { return }
        print("Params: \(joineesJsonArray)")
        let joineesRef = Firestore.firestore().collection("pots").document(potId)
        joineesRef.updateData([
            "joinees": joineesJsonArray
        ])
    }
    
    private func addNotificationToAllPlayers() {
        guard let potID = pot.id else { return }
        let wonNotifyDict : [String:Any] = ["author" : winner,
                                             "isRead" : false,
                                             "notificationType" : NotificationObjectType.won.rawValue,
                                             "potId": pot.id ?? "",
                                             "potName": pot.name,
                                             "timeStamp":  Int(NSDate().timeIntervalSince1970)]
        
        Firestore.firestore().collection("pots").document(potID).getDocument { (docSnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                guard let response = docSnapshot?.data() else { return }
                guard let joineesArr = response["joinees"] as? JSONArray else { return }
                if let joinees = joineesArr.toArray(of: Joinee.self)?.compactMap({ (joinee) -> String? in
                    return joinee.joinee
                }){
                    print(joinees)
                    for joinee in joinees {
                        let notifRef = Firestore.firestore().collection("user").document(joinee)
                        notifRef.updateData([
                            "notifications": FieldValue.arrayUnion([wonNotifyDict])
                        ])
                    }
                }
            }
        }
    }

}

extension SP_RankingsViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let joinee = joinees[indexPath.row]
        if joinee.isWinner() {
            let winnerCell = tableView.dequeueReusableCell(withIdentifier: winnerCellID, for: indexPath) as! SP_RankingWinnerTableViewCell
            winnerCell.display(joinee: joinee, index: indexPath.row + 1)
            return winnerCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: rankingCellID, for: indexPath) as! SP_RankingTableViewCell
        cell.display(joinee: joinee, index: indexPath.row + 1)
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinees.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
            return 60
//        }
//        return UITableView.automaticDimension
    }

}
extension BidirectionalCollection where Element: StringProtocol {
    var sentence: String {
        count <= 2 ?
            joined(separator: " and ") :
            dropLast().joined(separator: ", ") + ", and " + last!
    }
}
