//
//  SP_Pot_Invitee_ViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 02/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreData

protocol SP_Pot_Invitee_ViewControllerDelegate {
    func didJoinPot()
}

class SP_Pot_Invitee_ViewController: UIViewController {

    @IBOutlet private weak var ownerInviteLabel: UILabel!
    @IBOutlet private weak var participantsLabel: UILabel!
    @IBOutlet private weak var potTableView: UITableView!
    @IBOutlet private weak var infoButton: UIButton!
    private var totalPoints : Int = 0
    
    private var fixturePoints = Array<FixturePoints>()
    private let cellID = String(describing: SP_MatchTableViewCell.self)
    public var ownerStr : String = ""
    public var potIDStr : String = ""
    private let db = Firestore.firestore()
    private var fixturesArray = Array<FixtureMO>()
    private var matchesDiscarded = Array<FixtureMO>()

    private let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""

    var delegate: SP_Pot_Invitee_ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ownerInviteLabel.text = "\(ownerStr) invited you to the Pot"
        setupTableView()
        getFixturesFromServer()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshTableView),
            name: NSNotification.Name(rawValue: "refreshFixtures"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshFixtures"), object: nil)
    }
    private func setupTableView() {
        potTableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        potTableView.dataSource = self
        potTableView.delegate = self
        potTableView.reloadData()
    }
    
    @objc func refreshTableView(notification: Notification) {
        self.potTableView.reloadData()
    }
//    private func getCurrentWeekForPoints() {
//        self.showHUD()
//        Firestore.firestore().collection("currentWeekForPoints").document("currentWeek").getDocument { (docSnapShot, error) in
//            self.hideHUD()
//            if error == nil {
//                guard let currentWeekStr = docSnapShot?.data() else { return }
//                guard let weekNumStr = currentWeekStr["weekNo"] else { return }
//                self.getFixturePointsForWeek(week: weekNumStr as! String)
//            }
//        }
//    }
    
    func getCurrentPointsFrom(season: String) {
        self.showHUD()
        fixturePoints.removeAll()
        db.collection("fixturePoints").document(season).getDocument { (docSnapShot, error) in
            self.hideHUD()
            if let response = docSnapShot?.data() {
                let fixturePointsArray = response["0"] as? [[String: Any]]
                self.fixturePoints = fixturePointsArray?.toArray(of: FixturePoints.self) ?? Array<FixturePoints>()
                print(self.fixturePoints)
            } else {
                print("No Data available")
//                self.getFixturePoints(bookMakerId: 6)
            }
            self.potTableView.reloadData()
        }
    }

    private func getFixturesFromServer() {
        self.showHUD()
        let localTimeZone = TimeZone.current.identifier //getNextFixtures
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getFixturesfromLeague + Constants.kCurrentRound + Constants.kTimeZone + localTimeZone,
                                     method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            strongSelf.hideHUD()
            if let response = response {
                if let fixturesArray = response["api"]["fixtures"].array, !fixturesArray.isEmpty {
                    // Delete all the exisiting fixtures as we want to store the latest data for fixtures
                    strongSelf.deleteAllFixturesFromLocalDB()
                    
                    // Save new fixtures to core data
                    let managedObjectContext = CoreDataManager.sharedManager.persistentContainer.viewContext
                    
                    for fixtureObject in fixturesArray {
                        guard let fixtureDictionary = fixtureObject.dictionaryObject else { continue }
                        do {
                            //self?.matchTableView.restore()
                            let fixtureData = try JSONSerialization.data(withJSONObject: fixtureDictionary, options: [])
                            
                            guard let codingUserInfoKeyContext = CodingUserInfoKey.context else { continue }
                            let decoder = JSONDecoder()
                            decoder.userInfo[codingUserInfoKeyContext] = managedObjectContext
                            
                            let _ = try decoder.decode(FixtureMO.self, from: fixtureData)
                            try managedObjectContext.save()
                            
                        } catch {
                            print("Error saving fixture: \(error)")
                        }
                    }

                    DispatchQueue.main.async { [weak self] in
                        self?.getFixturesFromLocalDB()
                    }

                } else {
//                    self?.matchTableView.setEmptyMessage("No Data Available")
                }
            }
        }
        print(fixturesArray)
    }

    private func getFixturesFromLocalDB() {
        let managedObjectContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FixtureMO> = FixtureMO.fetchRequest()
        do {
            fixturesArray = try managedObjectContext.fetch(fetchRequest)
            fixturesArray = fixturesArray.sorted(by: { $0.event_timestamp < $1.event_timestamp })
//            fixtureIds = fixturesArray.map {Int($0.fixture_id)}
            getCurrentPointsFrom(season: UserDefaults.standard.string(forKey: UserDefaultsConstants.currentRoundKey) ?? "")
            
        } catch {
            print("Error fetching fixtures from local db")
        }
//        potTableView.reloadData()
    }

    private func deleteAllFixturesFromLocalDB() {
        let managedObjectContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FixtureMO> = FixtureMO.fetchRequest()
        do {
            let fixtures = try managedObjectContext.fetch(fetchRequest)
            for fixture in fixtures {
                managedObjectContext.delete(fixture)
            }
            try managedObjectContext.save()
        } catch {
            print("Error deleting fixtures from local db")
        }
    }

    @IBAction func infoButtonAction(_ sender: Any) {
    }
    
    @IBAction func joinPotAction(sender : UIButton) {
        guard !ownerStr.isEmpty else {
            return
        }
        if validateOpenPotSelection() {
            joinPotWithDetails()
        }
    }
    func joinPotWithDetails() {
        ///Write PotID to respective User
        ///Add to User
        let addJoinedPotsRef = self.db.collection("user").document(self.currentUser)
        addJoinedPotsRef.updateData([
            "joinedPots": FieldValue.arrayUnion([self.potIDStr])
        ])
        
        
        var predictions = [[String:Any]]()
        fixturesArray.forEach { (fixture) in
            var predictionBody = [String:Any]()
            predictionBody["fixture_id"] = fixture.fixture_id
            predictionBody["selection"] = fixture.predictionType.rawValue
            predictionBody["is_double_down"] = fixture.isDoubleDown
            predictions.append(predictionBody)
        }
        
        let joineeDict : [String:Any] = ["predictions" : predictions,
                                         "points": totalPoints,
                                         "joinee": currentUser,
                                         "displayName": UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? ""]
        
//        let potData : [[String:Any]] = [["predictions" : predictions], ["points": totalPoints]]
//        let userPredictions : [String:Any] = [currentUser: potData]
        
        ///Add to Pots
        let addFixturesRef = self.db.collection("pots").document(potIDStr)
        addFixturesRef.updateData([
            "joinees": FieldValue.arrayUnion([joineeDict])
        ])
        ///Notify other user's that current user has joined the pot
        addNotificationToOtherPlayers()

    }
    
    func addNotificationToOtherPlayers() {
        self.showHUD()
        
        db.collection("pots").document(potIDStr).getDocument { (docSnapshot, error) in
            self.hideHUD()
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                guard let response = docSnapshot?.data() else { return }
                guard let potName = response["name"] as? String else { return }
                guard let joineesArr = response["joinees"] as? JSONArray else { return }
                if let joinees = joineesArr.toArray(of: Joinee.self, keyDecodingStartegy: .convertFromSnakeCase)?.compactMap({ (joinee) -> String? in
                    return joinee.joinee
                }){
                    print(joinees)
                    let joinNotifyDict : [String:Any] = [ "author" : UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? "",
                                                         "isRead" : false,
                                                         "notificationType" :  NotificationObjectType.join.rawValue,
                                                         "potId": self.potIDStr,
                                                         "potName": potName,
                                                         "timeStamp":  Int(NSDate().timeIntervalSince1970)]
                    for joinee in joinees {
                        let notifRef = self.db.collection("user").document(joinee)
                        notifRef.updateData([
                            "notifications": FieldValue.arrayUnion([joinNotifyDict])
                        ])
                    }
                }
                self.dismiss(animated: false) {
                    self.delegate?.didJoinPot()
                }
            }
        }
    }
    
    func validateOpenPotSelection() -> Bool {
        // Check if user has done the selection for all the matches
        let discardedMatches = matchesDiscarded.count
        
        let pendingSelections = fixturesArray.filter { $0.predictionType == .none }.count
        if pendingSelections > discardedMatches {
            showInstructions(type: .BetTenMatches)
            return false
        }
        
        // Check if user has selected double down for 3 matches
        let totalDoubleDowns = fixturesArray.filter { $0.isDoubleDown }.count
        if totalDoubleDowns != 3 {
            showInstructions(type: .SelectAtleastThreeDoubleDown)
            return false
        }
        return true
    }
    
    private func showInstructions(type: PopupType.ContentType = .Instruction) {
        let instructController = SP_InstructionsPopupViewController.newInstance(contentType: type)
        present(instructController, animated: false, completion: nil)
    }

    func updatePoints(fixture: FixtureMO) {
        totalPoints = 0
        var selectedPoints = 0
        for fObj in fixturesArray {
            var fixTemp : FixtureMO = fObj
            if fObj.fixture_id == fixture.fixture_id {
                fixTemp = fObj
            }
            if fixTemp.isDoubleDown {
                selectedPoints = fixTemp.selectedPoints * 2
            } else {
                selectedPoints = fixTemp.selectedPoints
            }
            
            totalPoints += selectedPoints
        }
        print("TOTAL POINTS => \(totalPoints)")
        //totalPointsLabel.text = String(format: "%.1f\n points",totalPoints)
    }

}
extension SP_Pot_Invitee_ViewController : SP_MatchTableViewCellDelegate {
    
    func didChangeSelectionFor(cell: SP_MatchTableViewCell, predictionType: PredictionType) {
        guard let indexPath = potTableView.indexPath(for: cell) else { return }
        
        let fixture = fixturesArray[indexPath.section]
        fixture.predictionType = predictionType
        
        var predictionPoints = 0

        if let points = fixturePoints.first(where: { $0.fixtureId == fixture.fixture_id }) {
            switch predictionType {
            case .home:
                predictionPoints = points.home
                break
            case .away:
                predictionPoints = points.away
                break
            case .draw:
                predictionPoints = points.draw
                break
            case .none:
                break
            }
            print(points)
        }
        
        fixture.selectedPoints = predictionPoints
        print(predictionPoints)
        
        cell.updateSelection(fixture: fixture)
        updatePoints(fixture: fixture)
    }

    
    func didTapDoubleDownOn(cell: SP_MatchTableViewCell) {
        guard let indexPath = potTableView.indexPath(for: cell) else {
            return
        }
        let fixture = fixturesArray[indexPath.section]
        if !fixture.isDoubleDown {
            // Chek if user has already done 3 double downs
            if fixturesArray.filter({ $0.isDoubleDown }).count == 3 {
                // TODO: - Put this func in Utils
                showInstructions(type: .AlreadySelectedThreeDoubleDown)
                return
            }
        }
        fixture.isDoubleDown = !fixture.isDoubleDown
        cell.updateSelection(fixture: fixture)
        updatePoints(fixture: fixture)

    }
}

extension SP_Pot_Invitee_ViewController : UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return fixturesArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SP_MatchTableViewCell {
            
            if (fixturesArray.count != 0) && (fixturePoints.count != 0) {
                let fixPointsObj = fixturePoints.filter {$0.fixtureId == fixturesArray[indexPath.section].fixture_id}
                matchCell.displayFixture(fixtureModel: fixturesArray[indexPath.section],
                                         points:fixPointsObj.first ?? FixturePoints.init(home: 0, away: 0, draw: 0, fixtureId: 0),
                                         delegate: self)
                if fixturesArray[indexPath.section].isMatchOnGoing() {
                    matchesDiscarded.append(fixturesArray[indexPath.section])
                }
            }
            return matchCell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
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
