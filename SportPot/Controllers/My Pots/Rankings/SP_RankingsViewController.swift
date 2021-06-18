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
    var userInfo : [AnyHashable : Any]?
    private var joinees = [Joinee]()
    private var fixturesArr = [FixtureModel]()
    private let winnerCellID = String(describing: SP_RankingWinnerTableViewCell.self)
    private let rankingCellID = String(describing: SP_RankingTableViewCell.self)
    private var winner: String = ""
    private var isWinnerDeclared: Bool = false
    private var shouldPopToRoot = true
    var groups = [String]()
    typealias apiCompletionHandler = (_ success: Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RankingsVC Loaded!")
        rankingTableView.register(UINib(nibName: winnerCellID, bundle: nil), forCellReuseIdentifier: winnerCellID)
        rankingTableView.register(UINib(nibName: rankingCellID, bundle: nil), forCellReuseIdentifier: rankingCellID)
        rankingTableView.tableFooterView = UIView()
        self.fetchPotFromDB(potID: pot.id ?? "" ) { (success) in
            if success {
                self.potDateLabel.text = self.pot.name
                if self.userInfo?["type"] as? String ?? "" == "comment" {
                    self.groupChatAction(self)
                    return
                }
                if (self.pot.joinees.filter({$0.isWinner()}).count != 0) {
                    self.isWinnerDeclared = true
                }
                self.getFixturePoints()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldPopToRoot = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldPopToRoot {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func fetchPotFromDB (potID: String, completionHandler:  @escaping (Bool) -> ()) {
        
        self.showHUD()
        Firestore.firestore().collection("pots").document(potID).getDocument { [weak self] (docSnapShot, error) in
            self?.hideHUD()
            guard let self = self, let potJson = docSnapShot?.data(), let pot = potJson.to(type: Pot.self, keyDecodingStartegy: .convertFromSnakeCase) else {
                return
            }
            pot.id = potID
            self.pot = pot
            completionHandler(true)
        }
    }
    
    @IBAction func viewPotAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewPotVC = storyboard.instantiateViewController(identifier: String(describing: SP_PotPreviewViewController.self)) as? SP_PotPreviewViewController else { return }
        viewPotVC.pot = pot
        present(viewPotVC, animated: true, completion: nil)
    }
    
    @IBAction func sharePotAction(_ sender: Any) {
        var baseStr = Constants.kDYNAMIC_LINK_BASE_URL
        baseStr.append("/" + pot.potID)
        let message = "Check out the pot \(pot.name) I just created on Sportpot!"
        let activityVC = UIActivityViewController(activityItems: [message, baseStr], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
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
//                self.getFixturesFrom(round: round)
                self.getCurrentWeekForPoints()
            } else {
                self.joinees.append(contentsOf: self.pot.joinees)
                self.rankingTableView.reloadData()
            }
        }
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
        if fixturesArr.isEmpty {
            self.rankingTableView.restore()
//            refreshControl.beginRefreshing()
        }
        let localTimeZone = TimeZone.current.identifier
        self.showHUD()
        self.fixturesArr.removeAll()
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
                            self?.rankingTableView.setEmptyMessage("No Data Available")
                            return
                        }
                        let fixturesArray = fixtures.toArray(of: FixtureModel.self) ?? []
                        strongSelf.fixturesArr.append(contentsOf: fixturesArray)
                        cnt+=1
                        if cnt == group.count {
                            strongSelf.compareScoresFrom(fixturesArr: strongSelf.fixturesArr)
//                            strongSelf.getFixturesFromLocalDB()
                        }
                    } else {
                        self?.rankingTableView.setEmptyMessage("No Data Available")
                    }
                }
            }
        }
    }
    
    /*
    func getFixturesFrom(round: String) {
        self.showHUD()
        let localTimeZone = TimeZone.current.identifier
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
                            self?.matchTableView.setEmptyMessage("No Data Available")
                            return
                        }
                        let fixturesArray = fixtures.toArray(of: FixtureModel.self) ?? []
                        strongSelf.fixturesArray.append(contentsOf: fixturesArray)
                        cnt+=1
                        if cnt == group.count {
                            strongSelf.getFixturesFromLocalDB()
                            self.compareScoresFrom(fixturesArr: self.fixturesArr)
                        }
                    } else {
                        self?.matchTableView.setEmptyMessage("No Data Available")
                    }
                }
            }
        }
    }
 */
        
//        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getFixturesfromLeague + round + Constants.kTimeZone + localTimeZone, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
//            self?.hideHUD()
//            guard let self = self else { return }
//            if let response = response {
//                if let fixtures = response["api"]["fixtures"].arrayObject as? JSONArray {
//                    let fixturesArray = fixtures.toArray(of: FixtureModel.self) ?? [] //, keyDecodingStartegy: .convertFromSnakeCase) ?? []
//                    self.fixturesArr = fixturesArray
//                    self.compareScoresFrom(fixturesArr: self.fixturesArr)
//                }
//            }
//        }
    
    
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
                    
                    if fixture.fixture_id == prediction.fixtureId {
                        guard let points = fixturePoints.filter({ $0.fixtureId == fixture.fixture_id }).first else { return }
                        let homePoints = points.home
                        let drawPoints = points.draw
                        let awayPoints = points.away
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
                
        // Winner logic
        self.pot.joinees.removeAll()
        self.pot.joinees = allJoinees
        joinees = allJoinees
        
        self.pot.joinees.sort { (lhs, rhs) -> Bool in
            return (lhs.accuracy ?? 0, lhs.pointsScored ?? 0, lhs.doubleDown ?? 0) > (rhs.accuracy ?? 0, rhs.pointsScored ?? 0, rhs.doubleDown ?? 0)
        }
        

        var winners = [Joinee]()    // To hold all the unique winners
        var winnerNames = [String]()
        
        let highestAccuracy = self.pot.joinees.first?.accuracy
        let highestPoints = self.pot.joinees.first?.pointsScored
        let highestDD = self.pot.joinees.first?.doubleDown
        
        winners = self.pot.joinees.filter { (jObj) -> Bool in
            jObj.accuracy == highestAccuracy && jObj.pointsScored == highestPoints && jObj.doubleDown == highestDD
        }
        var shouldSendNotification = false
        if self.allMatchesPlayed(fixturesArr: self.fixturesArr) {
            self.pot.joinees.forEach { (joinee) in
                if joinee.winner == nil { //Never computed once
                    joinee.winner = winners.contains(joinee)
                    if joinee.winner == true && !winnerNames.contains(joinee.displayName!) {
                        winnerNames.append(joinee.displayName ?? "")
                        shouldSendNotification = true
                    }
                } else if joinee.winner == true {
                    winnerNames.append(joinee.displayName ?? "")
                }
            }
            
            if winners.count > 1 {
                winner = winnerString(from: winnerNames)
            } else {
                winner = winnerNames.first ?? ""
            }
        }
        
        if shouldSendNotification {
            addNotificationToAllPlayers(winners: winners)
        }
        if !isWinnerDeclared {
            updatePotToFirebase()
        }
        rankingTableView.reloadData()
    }
    
    func winnerString(from winnerArray: [String]) -> String {
        return winnerArray.sentence
    }
    
    private func updatePotToFirebase() {
        let jsonEncoder = JSONEncoder()
        guard let potId = pot.id else { return }
        guard let joineesData = try? jsonEncoder.encode(self.pot.joinees) else { return }
        guard let joineesJsonArray = try? JSONSerialization.jsonObject(with: joineesData, options: .allowFragments) as? JSONArray else { return }
        print("Params: \(joineesJsonArray)")
        let joineesRef = Firestore.firestore().collection("pots").document(potId)
        joineesRef.updateData([
            "joinees": joineesJsonArray
        ])
    }
    
    func sendPushNotification(from user: String, with potName: String) {
        let sender = PushNotificationSender()
        Firestore.firestore().collection("notificationTokens").document(user).getDocument { (docSnapshot, error) in
            self.hideHUD()
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                guard let response = docSnapshot?.data() else { return }
                guard let token = response["fcmToken"] as? String else { return }
                
                let title = "Pot Winner"
                var body = "Checkout who won \(potName) pot! 🤩"
                if user == UserDefaults.standard.value(forKey: UserDefaultsConstants.currentUserKey) as? String ?? ""{
                    body = "Woop woop you got this one right in \(potName) pot 🥳🤩"
                }
                
                let params: [String : Any] = ["content-available": true,
                                              "to" : token,
                                              "notification" : ["title" : title,
                                                                "body" : body],
                                              "data" : ["type" : "wonPot",
                                                        "potID" : self.pot.id,
                                                        "sound": "default"]]
                sender.sendPushNotification(with: params)
            }
        }
    }

    private func addNotificationToAllPlayers(winners: [Joinee]) {
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
                if let joineeEmails = joineesArr.toArray(of: Joinee.self)?.compactMap({ (joinee) -> String? in
                    return joinee.joinee
                }){
                    print(joineeEmails)
                    for joineeEmail in joineeEmails {
                        let notifRef = Firestore.firestore().collection("user").document(joineeEmail)
                        notifRef.updateData([
                            "notifications": FieldValue.arrayUnion([wonNotifyDict])
                        ]) { (error) in
                            if error == nil {
                                //Send Push Notification
//                                for winner in winners {
                                    self.sendPushNotification(from: joineeEmail, with: self.pot.name)
//                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK:- Chat
    
    @IBAction func groupChatAction(_ sender: Any) {
        shouldPopToRoot = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(identifier: String(describing: SP_ChatViewController.self)) as SP_ChatViewController
        chatVC.pot = pot
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}

//MARK:- Extensions

extension SP_RankingsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let joinee = self.pot.joinees[indexPath.row]
        if joinee.winner == true {
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
        return self.pot.joinees.count
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
