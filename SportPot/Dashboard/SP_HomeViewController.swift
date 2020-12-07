//
//  SP_HomeViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 12/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDynamicLinks
import FirebaseFirestore

class SP_HomeViewController: UIViewController {
    
    @IBOutlet private weak var matchTableView: UITableView!
    @IBOutlet weak var totalPointsLabel: UILabel!
    private let refreshControl = UIRefreshControl()
    private var todayDate = ""
    private var fixturesArray = Array<FixtureMO>()
    private var fixturesPointsArray = Array<[String]>()
    private let cellID = "SP_MatchTableViewCell"
    private var currentSeasonStr : String = ""
    private var totalPoints : Double = 0.0
    
    let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""
    var currentTimeStamp : Int64 = Date.currentTimeStamp
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(joinPotAction(notification:)), name: NSNotification.Name(rawValue: "joinPotNotification"), object: nil)
        
        setupNavigationBar()
        setupTableView()
        setupDate()
        //        if !isKeyPresentInUserDefaults(key: UserDefaultsConstants.currentRoundKey) {
        checkCurrentRoundForSeason()
        //        }
        
        let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsConstants.launchCountKey)
        if currentCount < 3 {
            self.showInstructions()
        }
        //        getFixturesFromServer() // Get latest fixtures from api
        getCurrentWeekForPoints()        
    }
    
    private func setupNavigationBar() {
        let logo = UIImage(named: "logo-sport-pot.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    private func setupTableView() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        matchTableView.refreshControl = refreshControl
        matchTableView.register(UINib(nibName: "SP_MatchTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    @objc private func refreshControlAction() {
        getFixturesFromServer()
    }
    
    private func setupDate() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YY"
        todayDate = formatter.string(from: date)
    }
    
    fileprivate func checkCurrentRoundForSeason() {
        //https://api-football-v1.p.rapidapi.com/v2/fixtures/rounds/2790/current
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getCurrentRound, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let response = response {
                if let fixturesArray = response["api"]["fixtures"].arrayObject, !fixturesArray.isEmpty {
                    strongSelf.currentSeasonStr = fixturesArray[0] as! String
                    let isKeyPresent = strongSelf.isKeyPresentInUserDefaults(key: UserDefaultsConstants.currentRoundKey)
//                    if isKeyPresent {
//                        if UserDefaults.standard.value(forKey: UserDefaultsConstants.currentRoundKey) as! String == strongSelf.currentSeasonStr {
//                            strongSelf.showFixturesFromLocalDB() // If round is same, show fixtures from local db
//                        }
//                    } else {
                        ///Set the current Round
                        UserDefaults.standard.set(strongSelf.currentSeasonStr , forKey: UserDefaultsConstants.currentRoundKey)
//                        strongSelf.getFixturesFromServer()
//                    }
                    
                }
            }
        }
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    private func showInstructions(type: PopupType.ContentType = .Instruction) {
        let instructController = SP_InstructionsPopupViewController.newInstance(contentType: type)
        present(instructController, animated: false, completion: nil)
    }
    func getCurrentWeekForPoints() {
        Firestore.firestore().collection("currentWeekForPoints").document("currentWeek").getDocument { (docSnapShot, error) in
            guard let currentWeekStr = docSnapShot?.data() else { return }
            guard let weekNumStr = currentWeekStr["weekNo"] else { return }
            self.getFixturePointsForWeek(week: weekNumStr as! String)
        }
    }
    private func getFixturesFromServer() {
        if fixturesArray.isEmpty {
            self.matchTableView.restore()
            refreshControl.beginRefreshing()
        }
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
                            self?.matchTableView.restore()
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
                }else{
                    self?.matchTableView.setEmptyMessage("No Data Available")
                }
            }
            strongSelf.showFixturesFromLocalDB()
        }
    }
    
    private func showFixturesFromLocalDB() {
        getFixturesFromLocalDB()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        matchTableView.reloadData()
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
    
    private func getFixturesFromLocalDB() {
        let managedObjectContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FixtureMO> = FixtureMO.fetchRequest()
        do {
            fixturesArray = try managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Error fetching fixtures from local db")
        }
        matchTableView.reloadData()
    }
    
    func createDeepLink() {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "sportpot.eu"
        components.path = "/"
        let dynamicLinksDomainURIPrefix = "https://sportpot.page.link"
        
        let userDataStr = currentUser + "&" + String(currentTimeStamp)
        print("Original string: \"\(userDataStr)\"")
        
        if let base64Str = userDataStr.base64Encoded() {
            print("Base64 encoded string: \"\(base64Str)\"")
            
            let queryItemUsername = URLQueryItem(name: "owner", value: base64Str)
            let queryItemAction = URLQueryItem(name: "action", value: "joinPot")
            currentTimeStamp = Date.currentTimeStamp
            let queryItemTimeStamp = URLQueryItem(name: "timestamp", value: String(currentTimeStamp))
            components.queryItems = [queryItemUsername,queryItemTimeStamp,queryItemAction]
            guard let urlComponent = components.url else { return }
            guard let longShareLink = DynamicLinkComponents.init(link: urlComponent, domainURIPrefix: dynamicLinksDomainURIPrefix) else { return}
            guard let longDynamicLink = longShareLink.url else {
                print ("Couldn't create FDL Components")
                return
            }
            print("The long URL is: \(longDynamicLink)")
            DynamicLinkComponents.shortenURL( longDynamicLink, options: nil) { [weak self] url, warnings, error in
                guard let shortURL = url, error == nil else { return }
                print("The short URL is: \(shortURL)")
                self?.savePotToDB(shareLink: shortURL.absoluteString, potID: base64Str)
            }
            
            if let bundleID = Bundle.main.bundleIdentifier {
                longShareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
                longShareLink.iOSParameters?.appStoreID = "AppStoreID"
                longShareLink.iOSParameters?.minimumAppVersion = "1.0"
            }
        }
    }
    @IBAction func openNewPotAction(_ sender: Any) {
        if validateOpenPotSelection() {
            createDeepLink()
        }
    }
    func savePotToDB(shareLink: String, potID: String) {
        let urlParams = shareLink.split(separator: "/")
        
        // Create user's pot
        var predictions = [[String:Any]]()
        fixturesArray.forEach { (fixture) in
            var predictionBody = [String:Any]()
            predictionBody["fixture_id"] = fixture.fixture_id
            predictionBody["selection"] = fixture.predictionType.rawValue
            predictionBody["is_double_down"] = fixture.isDoubleDown
            predictions.append(predictionBody)
        }

        let pointsStr = totalPointsLabel.text?.split(separator: "\n")
        let joineeDict : [String:Any] = ["predictions" : predictions,
                                         "points": Double(pointsStr?[0] ?? "0.0") as Any,
                                         "joinee": currentUser]

        var potBody = [String:Any]()
        potBody["potID"] = String(urlParams[2])
        potBody["createdOn"] = String(currentTimeStamp)
        potBody["joinees"] = [joineeDict]
        potBody["owner"] = currentUser
        //Add current season (Round)
        potBody["round"] = UserDefaults.standard.object(forKey: UserDefaultsConstants.currentRoundKey)
        print("User's Pot:\n\(potBody)")
        
        let potsRef =
            db.collection("pots").document(potID)
        potsRef.setData(potBody) { (err) in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                ///Write PotID to respective User
                let addJoinedPotsRef = self.db.collection("user").document(self.currentUser)
                addJoinedPotsRef.updateData([
                    "joinedPots": FieldValue.arrayUnion([potID])
                ])
                ///Share this link
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let sharePotViewController = storyboard.instantiateViewController(identifier: "SP_SharePotViewController") as SP_SharePotViewController
                sharePotViewController.linkString = shareLink
                self.present(sharePotViewController, animated: true, completion: nil)
            }
        }
    }
    @objc func joinPotAction(notification: NSNotification) {
        
        //t7Vw7YLfdeTKeNY7A
        if let notificationDict = notification.userInfo {
            let base64Str = notificationDict["owner"] as! String
            if let decodedStr = base64Str.base64Decoded() {
                print("Base64 decoded string: \"\(decodedStr)\"")
                //Extract user and timestamp from decodedStr
                let dataArr = decodedStr.split(separator: "&")
                let owner = String(dataArr[0])
                //                    let timestamp = dataArr[1]
                
                //                let timestamp = notificationDict["timestamp"] as! String
                //Change: currentUser to the senderUserName and link too
                //SP_Pot_Invitee_ViewController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let potInviteeViewController = storyboard.instantiateViewController(identifier: "SP_Pot_Invitee_ViewController") as SP_Pot_Invitee_ViewController
                potInviteeViewController.ownerStr = owner
                potInviteeViewController.potIDStr = base64Str
                self.present(potInviteeViewController, animated: true, completion: nil)
            }
        }
    }
    
    ///Logout
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set(nil, forKey: "currentUser")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
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
    
    func getFixturePointsForWeek(week:String) {
        db.collection("fixturePoints").document(week).getDocument { (docSnapShot, error) in
            guard let pointsSnapshot = docSnapShot else {
                print("Error retreiving documents \(error!)")
                return
            }
            pointsSnapshot.data()?.forEach { (key, fixturePoints) in
                self.fixturesPointsArray.append(fixturePoints as! [String])
            }
            print("Fixture points:\n \(self.fixturesPointsArray)")
            self.matchTableView.reloadData()
        }
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
        totalPointsLabel.text = String(format: "%.1f\n points",totalPoints)
    }
}

extension SP_HomeViewController : SP_MatchTableViewCellDelegate {
    
    func didChangeSelectionFor(cell: SP_MatchTableViewCell, predictionType: PredictionType) {
        guard let indexPath = matchTableView.indexPath(for: cell) else {
            return
        }
        let fixture = fixturesArray[indexPath.section]
        fixture.predictionType = predictionType
        fixture.selectedPoints = Double(fixturesPointsArray[indexPath.section][predictionType.rawValue - 1]) ?? 0.0
        cell.updateSelection(fixture: fixture)
        updatePoints(fixture: fixture)
    }
    
    func didTapDoubleDownOn(cell: SP_MatchTableViewCell) {
        guard let indexPath = matchTableView.indexPath(for: cell) else {
            return
        }
        let fixture = fixturesArray[indexPath.section]
        if !fixture.isDoubleDown {
            // Chek if user has already done 3 double downs
            if fixturesArray.filter({ $0.isDoubleDown }).count == 3 {
                showInstructions(type: .AlreadySelectedThreeDoubleDown)
                return
            }
        }
        fixture.isDoubleDown = !fixture.isDoubleDown
        cell.updateSelection(fixture: fixture)
        updatePoints(fixture: fixture)
    }
    
    
}

extension SP_HomeViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fixturesArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matchCell = matchTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MatchTableViewCell
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
