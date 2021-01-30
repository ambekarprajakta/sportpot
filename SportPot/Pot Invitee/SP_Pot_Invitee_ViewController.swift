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
    private var totalPoints : Double = 0.0
    
    private var fixturesPointsArray = Array<[String]>()
    private let cellID = String(describing: SP_MatchTableViewCell.self)
    public var ownerStr : String = ""
    public var potIDStr : String = ""
    private let db = Firestore.firestore()
    private var fixturesArray = Array<FixtureMO>()
    private let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""

    var delegate: SP_Pot_Invitee_ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ownerInviteLabel.text = "\(ownerStr) invited you to the Pot"
        setupTableView()
        getCurrentWeekForPoints()
    }

    private func setupTableView() {
        potTableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        potTableView.dataSource = self
        potTableView.delegate = self
        potTableView.reloadData()
    }
    
    private func getCurrentWeekForPoints() {
        self.showHUD()
        Firestore.firestore().collection("currentWeekForPoints").document("currentWeek").getDocument { (docSnapShot, error) in
            self.hideHUD()
            if error == nil {
                guard let currentWeekStr = docSnapShot?.data() else { return }
                guard let weekNumStr = currentWeekStr["weekNo"] else { return }
                self.getFixturePointsForWeek(week: weekNumStr as! String)
            }
        }
    }
    
    private func getFixturePointsForWeek(week:String) {
        self.showHUD()
        db.collection("fixturePoints").document(week).getDocument { [weak self] (docSnapShot, error) in
            self?.hideHUD()
            guard let self = self, let pointsSnapshot = docSnapShot else {
                print("Error retreiving documents \(error!)")
                return
            }
            pointsSnapshot.data()?.forEach { (key, fixturePoints) in
                self.fixturesPointsArray.append(fixturePoints as! [String])
            }
            print("Fixture points:\n \(self.fixturesPointsArray)")
            
            self.getFixturesFromServer()
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
        } catch {
            print("Error fetching fixtures from local db")
        }
        potTableView.reloadData()
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
    func joinPotWithDetails(){
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
                                         "joinee": currentUser]
        
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
        let joinNotifyDict : [String:Any] = ["author" : self.currentUser,
                                             "isRead" : false,
                                             "notificationType" :  NotificationObjectType.join.rawValue,
                                             "potId": self.potIDStr,
                                             "timeStamp":  Int(NSDate().timeIntervalSince1970)]
        
        db.collection("pots").document(potIDStr).getDocument { (docSnapshot, error) in
            self.hideHUD()
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                guard let response = docSnapshot?.data() else { return }
                guard let joineesArr = response["joinees"] as? JSONArray else { return }
                if let joinees = joineesArr.toArray(of: Joinee.self, keyDecodingStartegy: .convertFromSnakeCase)?.compactMap({ (joinee) -> String? in
                    return joinee.joinee
                }){
                    print(joinees)
                    
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
        let pendingSelections = fixturesArray.filter { $0.predictionType == .none }.count
        if pendingSelections > 0 {
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
        totalPoints = 0.0
        var selectedPoints = 0.0
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
        guard let indexPath = potTableView.indexPath(for: cell) else {
            return
        }
        let fixture = fixturesArray[indexPath.section]
        fixture.predictionType = predictionType
        fixture.selectedPoints = Double(fixturesPointsArray[indexPath.section][predictionType.rawValue - 1]) ?? 0.0
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
                //showInstructions(type: .AlreadySelectedThreeDoubleDown)
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
            if (fixturesArray.count != 0) && (fixturesPointsArray.count != 0) {
                matchCell.displayFixture(fixtureModel: fixturesArray[indexPath.section], points: fixturesPointsArray[indexPath.section], delegate: self)
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
