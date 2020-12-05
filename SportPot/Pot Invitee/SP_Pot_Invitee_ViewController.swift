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

class SP_Pot_Invitee_ViewController: UIViewController {

    @IBOutlet weak var ownerInviteLabel: UILabel!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var potTableView: UITableView!
    @IBOutlet weak var infoButton: UIButton!
    private var totalPoints : Double = 0.0
    
    private var fixturesPointsArray = Array<[String]>()
    private let cellID = "SP_MatchTableViewCell"
    public var ownerStr : String = ""
    public var potIDStr : String = ""
    let db = Firestore.firestore()
    private var fixturesArray = Array<FixtureMO>()
    let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        potTableView.register(UINib(nibName: "SP_MatchTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        ownerInviteLabel.text = "\(ownerStr) invited you to the Pot"
        getFixturesFromServer()
        getFixturePoints()
    }
    func getFixturePoints() {
        db.collection("fixturePoints").document("week44").getDocument { (docSnapShot, error) in
            guard let pointsSnapshot = docSnapShot else {
                print("Error retreiving documents \(error!)")
                return
            }
            pointsSnapshot.data()?.forEach { (key, fixturePoints) in
                self.fixturesPointsArray.append(fixturePoints as! [String])
            }
            print("Fixture points:\n \(self.fixturesPointsArray)")
                self.potTableView.reloadData()
        }
    }

    private func getFixturesFromServer() {
        let localTimeZone = TimeZone.current.identifier //getNextFixtures
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getFixturesfromLeague + Constants.kCurrentRound + Constants.kTimeZone + localTimeZone,
                                     method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let response = response {
                if let fixturesArray = response["api"]["fixtures"].array, !fixturesArray.isEmpty {
                    // Delete all the exisiting fixtures as we want to store the latest data for fixtures
                    strongSelf.deleteAllFixturesFromLocalDB()
                    
                    // Save new fixtures to core data
                    let managedObjectContext = CoreDataManager.sharedManager.persistentContainer.viewContext
                    
                    for fixtureObject in fixturesArray {
                        guard let fixtureDictionary = fixtureObject.dictionaryObject else { continue }
                        do {
//                            self?.matchTableView.restore()
                            let fixtureData = try JSONSerialization.data(withJSONObject: fixtureDictionary, options: [])
                            
                            guard let codingUserInfoKeyContext = CodingUserInfoKey.context else { continue }
                            let decoder = JSONDecoder()
                            decoder.userInfo[codingUserInfoKeyContext] = managedObjectContext
                            
                            let _ = try decoder.decode(FixtureMO.self, from: fixtureData)
                            try managedObjectContext.save()
                            strongSelf.getFixturesFromLocalDB()
                            
                        } catch {
                            print("Error saving fixture: \(error)")
                        }
                    }
                }else{
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
        
        let addFixturesRef = self.db.collection("pots").document(potIDStr)
        addFixturesRef.updateData([
            "joinees": FieldValue.arrayUnion([joineeDict])
        ])
        db.collection("pots").document(potIDStr).getDocument { (docSnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                //Pot Joined Successfully!
                print("Pot Joined Successfully!\n \(String(describing: docSnapshot?.documentID)) => \(String(describing: docSnapshot?.data()))")
                ///Write PotID to respective User
                let addJoinedPotsRef = self.db.collection("user").document(self.currentUser)
                addJoinedPotsRef.updateData([
                    "joinedPots": FieldValue.arrayUnion([self.potIDStr])
                ])

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let goodLuckViewController = storyboard.instantiateViewController(identifier: "SP_GoodLuckViewController") as SP_GoodLuckViewController
                self.present(goodLuckViewController, animated: true, completion: nil)
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
//        totalPointsLabel.text = String(format: "%.1f\n points",totalPoints)
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
                //TODO: Put this func in Utils
//                showInstructions(type: .AlreadySelectedThreeDoubleDown)
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
        let matchCell = potTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MatchTableViewCell
        if !fixturesArray.isEmpty && !fixturesPointsArray.isEmpty{
            matchCell.displayFixture(fixtureModel: fixturesArray[indexPath.section], points:fixturesPointsArray[indexPath.section], delegate: self)
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