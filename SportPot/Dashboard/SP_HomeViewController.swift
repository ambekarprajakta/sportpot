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
import UXCam

class SP_HomeViewController: SP_FixturePointsViewController {
    
    @IBOutlet private weak var matchTableView: UITableView!
    @IBOutlet weak var totalPointsLabel: UILabel!
    private let refreshControl = UIRefreshControl()
    private var todayDate = ""
    private var remainingFixturesArray = Array<FixtureMO>()
//    private var fixturesArray = Array<FixtureMO>()
//    var fixturePoints = Array<FixturePoints>()
//    var fixtureIds = [Int]()
    
    private var fixturesPointsArray = Array<[String]>()
    private var matchesDiscarded = Array<FixtureMO>()

    private let cellID = "SP_MatchTableViewCell"
    private var currentSeasonStr : String = ""
    private var totalPoints : Int = 0
    private var potName : String = ""
    let currentUser = UserDefaults.standard.string(forKey: "currentUser") ?? ""
    var currentTimeStamp : Int64 = Date.currentTimeStamp
//    let db = Firestore.firestore()
    
    //MARK:- Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        let username = UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? ""
        UXCam.setUserIdentity(username)
        UXCam.setUserProperty("username",value: username)
        UXCam.setUserProperty("email",value: currentUser)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshTableView),
            name: NSNotification.Name(rawValue: "refreshFixtures"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(joinPotAction(notification:)), name: NSNotification.Name(rawValue: "joinPotNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToMyPots), name: NSNotification.navigateToMyPots, object: nil)
        setupNavigationBar()
        setupTableView()
        setupDate()
        checkCurrentRoundForSeason()
        
        let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsConstants.launchCountKey)
        if currentCount < 3 {
            self.showInstructions()
        }

        func viewWillAppear(_ animated: Bool) {
        }
        
        func viewWillDisappear(_ animated: Bool) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshFixtures"), object: nil)
        }

        if !isKeyPresentInUserDefaults(key: UserDefaultsConstants.notificationsBadgeCount){
            UserDefaults.standard.setValue(0, forKey: UserDefaultsConstants.notificationsBadgeCount)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNotificationsCount()
    }
    
    @objc func refreshTableView(notification: Notification) {
        self.matchTableView.reloadData()
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
    
    //MARK:- API Calls

    fileprivate func checkCurrentRoundForSeason() {
        self.showHUD()
        //https://api-football-v1.p.rapidapi.com/v2/fixtures/rounds/2790/current
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getCurrentRound, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            strongSelf.hideHUD()
            if let response = response {
                if let fixturesArray = response["api"]["fixtures"].arrayObject, !fixturesArray.isEmpty {
                    strongSelf.currentSeasonStr = fixturesArray[0] as! String
                    let isKeyPresent = strongSelf.isKeyPresentInUserDefaults(key: UserDefaultsConstants.currentRoundKey)
                    if isKeyPresent {
                        if UserDefaults.standard.value(forKey: UserDefaultsConstants.currentRoundKey) as! String == strongSelf.currentSeasonStr {
//                            strongSelf.showFixturesFromLocalDB() // If round is same, show fixtures from local db
                            
                        }
                    }
                    ///Set the current Round
                    strongSelf.setCurrentRound(round: strongSelf.currentSeasonStr)                    
                }
            }
        }
        
    }
    
    func setCurrentRound(round: String) {
        self.getFixturesFromServer()
        UserDefaults.standard.set(round, forKey: UserDefaultsConstants.currentRoundKey)
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func getNotificationsCount() {
        Firestore.firestore().collection("user").document(currentUser).getDocument { (docSnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                guard let response = docSnapshot?.data() else { return }
                guard let notificationsArr = response["notifications"] as? JSONArray else { return }
                guard let notifications = notificationsArr.toArray(of: NotificationObject.self) else { return }
                let unReadNotifications =  notifications.filter({ (notifObj) -> Bool in
                    return !notifObj.isRead
                })
                print(unReadNotifications)
                self.updateNotificationBadge(count: unReadNotifications.count)
            }
        }
    }
    
    func updateNotificationBadge(count: Int) {
        guard let tabItems = self.tabBarController?.tabBar.items else { return }
        let tabItem = tabItems[2]
        
        if count != UserDefaults.standard.integer(forKey: UserDefaultsConstants.notificationsBadgeCount) {
            tabItem.badgeValue = String(count)
        } else {
            tabItem.badgeValue = nil
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: .badge)
        { (granted, error) in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = Int(tabItem.badgeValue ?? "") ?? 0
                }
            }
        }
    }
    
//    private func getFixturePoints(bookMakerId: Int) {
//        if let fixtureId = self.fixtureIds.popLast() {
//            let url = "https://api-football-v1.p.rapidapi.com/v2/odds/fixture/\(fixtureId)/bookmaker/\(bookMakerId)"
//            self.showHUD()
//            SP_APIHelper.getResponseFrom(url: url, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { (response, error) in
//                self.hideHUD()
//                if let bookmakersArray = response?["api"]["odds"].array?.first?["bookmakers"].arrayObject as? [[String: Any]] {
//                    let bookmakersList = bookmakersArray.toArray(of: BookMaker.self, keyDecodingStartegy: .convertFromSnakeCase)
//                    if let bookmaker = bookmakersList?.first {
//                        if let bet = bookmaker.bets.filter({ (bet) -> Bool in
//                            return bet.labelName == "Match Winner"
//                        }).first {
//                            if let values = bet.values {
//                                var red = values.reduce([String: Int]()) { (result, valueObj) -> [String: Int] in
//                                    var result = result
//                                    result[valueObj.value.lowercased()] = valueObj.odd
//                                    return result
//                                } as JSONObject
//                                red["fixtureId"] = fixtureId
//                                if let points = red.to(type: FixturePoints.self) {
//                                    print("===\n\(String(describing: points))\n===")
//                                    self.fixturePoints.append(points)
//                                    self.getFixturePoints(bookMakerId: bookMakerId)
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    let points = FixturePoints.init(home: Int.random(in: 0..<5), away: Int.random(in: 0..<5), draw: Int.random(in: 0..<5), fixtureId: fixtureId)
//                    self.fixturePoints.append(points)
//                    print("===\n\(String(describing: points))\n===")
//                    self.getFixturePoints(bookMakerId: bookMakerId)
//                }
//            }
//        } else if !fixturePoints.isEmpty && fixturePoints.count == fixturesArray.count {
//            savePointsToDB(fixturePoints: fixturePoints)
//        }
//    }
    
    private func getFixturesFromServer() {
        
        if fixturesArray.isEmpty {
            self.matchTableView.restore()
            refreshControl.beginRefreshing()
        }
        let localTimeZone = TimeZone.current.identifier
        self.showHUD()
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
//            strongSelf.getFixturePoints(bookMakerId: 6)
            
        }
    }
    
    private func showFixturesFromLocalDB() {
        getFixturesFromLocalDB()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
//        matchTableView.reloadData()
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
        fixtureIds.removeAll()
        fixturesArray.removeAll()
        let managedObjectContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FixtureMO> = FixtureMO.fetchRequest()
        do {
            fixturesArray = try managedObjectContext.fetch(fetchRequest)
            fixturesArray = fixturesArray.sorted(by: { $0.event_timestamp < $1.event_timestamp })
            remainingFixturesArray = fixturesArray.filter({ (fixObj) -> Bool in
                !fixObj.isMatchOnGoing()
            }).sorted(by: { $0.event_timestamp < $1.event_timestamp })
            fixtureIds = fixturesArray.map {Int($0.fixture_id)}
            getCurrentPointsFrom(season: self.currentSeasonStr)
        } catch {
            print("Error fetching fixtures from local db")
        }
//        matchTableView.reloadData()
    }
    
//    private func savePointsToDB(fixturePoints: [FixturePoints]) {
//
//        guard let data =  try? JSONEncoder().encode(fixturePoints),
//              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
//            return
//        }
//        print("JSON Array: \(jsonArray)")
//        let round = UserDefaults.standard.object(forKey: UserDefaultsConstants.currentRoundKey)
//        let potsRef =
//            db.collection("fixturePoints").document(round as? String ?? "")
//
//        potsRef.setData(["0": jsonArray]) { (err) in
//            self.hideHUD()
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                print("Document successfully written!")
//                self.matchTableView.reloadData()
//            }
//        }
//    }
    
    func createDeepLink() {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "sportpot.eu"
        components.path = "/"
        let dynamicLinksDomainURIPrefix = Constants.kDYNAMIC_LINK_BASE_URL
        currentTimeStamp = Date.currentTimeStamp
        let displayName = UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? ""
        
        let potStr = displayName + "&" + String(currentTimeStamp)
        if let base64Str = potStr.base64Encoded() {
            print("Base64 encoded string: \"\(base64Str)\"")
            
            let queryItemUsername = URLQueryItem(name: "owner", value: base64Str)
            let queryItemAction = URLQueryItem(name: "action", value: "joinPot")
            let queryItemFixtureCount = URLQueryItem(name: "fixtureCount", value: String(remainingFixturesArray.count))
            
            let eventTimestamp = remainingFixturesArray.first?.event_timestamp ?? 0
            let queryItemTimeStamp = URLQueryItem(name: "timestamp", value: String(eventTimestamp))
            components.queryItems = [queryItemUsername, queryItemTimeStamp, queryItemAction, queryItemFixtureCount]
            
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
            addPotName()
        }
    }
    
    
    
    func savePotToDB(shareLink: String, potID: String) {
        self.showHUD()
        let urlParams = shareLink.split(separator: "/")
        
        // Create user's pot
        var predictions = [[String:Any]]()

        remainingFixturesArray.forEach { (fixture) in
            var predictionBody = [String:Any]()
            predictionBody["fixture_id"] = fixture.fixture_id
            predictionBody["selection"] = fixture.predictionType.rawValue
            predictionBody["is_double_down"] = fixture.isDoubleDown
            predictions.append(predictionBody)
        }
        
        let pointsStr = totalPointsLabel.text?.split(separator: "\n")
        let joineeDict : [String:Any] = ["predictions" : predictions,
                                         "points": Double(pointsStr?[0] ?? "0.0") as Any,
                                         "joinee": currentUser,
                                         "displayName": UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? ""]
        
        var potBody = [String:Any]()
        potBody["potID"] = String(urlParams[2])
        potBody["createdOn"] = String(currentTimeStamp)
        potBody["joinees"] = [joineeDict]
        potBody["owner"] = currentUser
        potBody["name"] = potName
        
        //Add current season (Round)
        potBody["round"] = UserDefaults.standard.object(forKey: UserDefaultsConstants.currentRoundKey)
        print("User's Pot:\n\(potBody)")
        
        let potsRef =
            db.collection("pots").document(potID)
        potsRef.setData(potBody) { (err) in
            self.hideHUD()
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
        self.showHUD()
        
        if let notificationDict = notification.userInfo {
            guard let potIDStr = notificationDict["owner"] as? String else { return }
            guard let fixtureCount = notificationDict["fixtureCount"] as? String else { return }
            guard let timestamp = notificationDict["timestamp"] as? String else { return }
            
            if let decodedStr = potIDStr.base64Decoded() {
                print("Base64 decoded string: \"\(decodedStr)\"")
                //Extract user and timestamp from decodedStr
                let dataArr = decodedStr.split(separator: "&")
                let owner = String(dataArr[0])
                
                db.collection("user").document(currentUser).getDocument { (docSnapShot, error) in
                    self.hideHUD()
                    if let userData = docSnapShot?.data() {
                        if let pots = userData["joinedPots"] as? [String] {
                            if pots.contains(potIDStr) {
                                // User has already joined the pot
                                self.popupAlert(title: nil, message: "You’ve already placed your bets for this pot", actionTitles: ["Okay"], actions: [{action in}])
                                return
                            }
                        }
                    }
                    // Allow user to join the pot
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let potInviteeViewController = storyboard.instantiateViewController(identifier: "SP_Pot_Invitee_ViewController") as SP_Pot_Invitee_ViewController
                    potInviteeViewController.ownerStr = owner
                    potInviteeViewController.potIDStr = potIDStr
                    potInviteeViewController.remainingTime = timestamp
                    potInviteeViewController.fixtureCount = fixtureCount
                    potInviteeViewController.delegate = self
                    self.present(potInviteeViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func navigateToMyPots() {
        tabBarController?.selectedIndex = 1
    }
    
    
    func validateOpenPotSelection() -> Bool {
        let discardedMatches = fixturesArray.count - remainingFixturesArray.count
        
        if discardedMatches > fixturesArray.count - Constants.kMaxMatchesRemaining {
            
            self.popupAlert(title: nil, message: "Unfortunately not possible to open pot with only 5 or less matches left in pot.\nNext pot opens up on Monday", actionTitles: ["Okay"], actions: [{action in}])
            return false
        }
        
        let pendingSelections = fixturesArray.filter { $0.predictionType == .none }.count
        if pendingSelections > discardedMatches {
            showInstructions(type: .BetTenMatches)
            return false
        }
        
        // Check if user has selected double down for 3 matches
        let totalDoubleDowns = fixturesArray.filter { $0.isDoubleDown }.count
        if totalDoubleDowns != 3 {//&& discardedMatches > Constants.kMaxMatchesRemaining {
            showInstructions(type: .SelectAtleastThreeDoubleDown)
            return false
        }
        return true
    }
    
//    func getCurrentPointsFrom(season: String) {
//        self.showHUD()
//        fixturePoints.removeAll()
//        db.collection("fixturePoints").document(season).getDocument { (docSnapShot, error) in
//            self.hideHUD()
//            if let response = docSnapShot?.data() {
//                let fixturePointsArray = response["0"] as? [[String: Any]]
//                self.fixturePoints = fixturePointsArray?.toArray(of: FixturePoints.self) ?? Array<FixturePoints>()
//                print(self.fixturePoints)
//            } else {
//                print("No Data available")
//                self.getFixturePoints(bookMakerId: 6)
//            }
//            self.matchTableView.reloadData()
//        }
//    }
    
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
        totalPointsLabel.text = String(format: "%d\n points",totalPoints)
    }
    
    //MARK:- Pop-ups

    private func showInstructions(type: PopupType.ContentType = .Instruction) {
        let instructController = SP_InstructionsPopupViewController.newInstance(contentType: type)
        present(instructController, animated: false, completion: nil)
    }
    
    func addPotName() {
        let alertController = UIAlertController(title: "Pot Name", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Pot Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            self.potName = firstTextField.text ?? ""
            self.createDeepLink()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    //MARK:- Logout

    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set(nil, forKey: "currentUser")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
}

extension SP_HomeViewController : SP_MatchTableViewCellDelegate {
    
    func didChangeSelectionFor(cell: SP_MatchTableViewCell, predictionType: PredictionType) {
        guard let indexPath = matchTableView.indexPath(for: cell) else { return }
        
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
        
        if !fixturesArray.isEmpty && !fixturePoints.isEmpty{
//            let fixObj = fixturesArray.filter {$0.fixture_id == fixturePoints[indexPath.section].fixtureId}
//            matchCell.displayFixture(fixtureModel: fixObj.first ?? FixtureMO.init(), points:fixturePoints[indexPath.section], delegate: self)
            let fixPointsObj = fixturePoints.filter {$0.fixtureId == fixturesArray[indexPath.section].fixture_id}

            matchCell.displayFixture(fixtureModel: fixturesArray[indexPath.section], points:fixPointsObj.first ?? FixturePoints.init(home: 0, away: 0, draw: 0, fixtureId: 0), delegate: self)
            
//            if fixturesArray[indexPath.section].isMatchOnGoing() {
//                matchesDiscarded.append(fixturesArray[indexPath.section])
//            }

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

extension SP_HomeViewController: SP_Pot_Invitee_ViewControllerDelegate {
    func didJoinPot() {
        navigateToMyPots()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let goodLuckViewController = storyboard.instantiateViewController(identifier: "SP_GoodLuckViewController") as SP_GoodLuckViewController
        self.present(goodLuckViewController, animated: true, completion: nil)
    }
}
