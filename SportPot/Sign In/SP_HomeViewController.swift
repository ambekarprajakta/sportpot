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
import Branch

class SP_HomeViewController: UIViewController {
    
    @IBOutlet private weak var matchTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var todayDate = ""
    private var fixturesArray = Array<FixtureMO>()
    private let cellID = "SP_MatchTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupDate()
        let currentCount = UserDefaults.standard.integer(forKey: "launchCount")
        if currentCount < 3 {
            self.showInstructions()
        }
        
        //        showFixtures() // Initially show fixtures from local db
        getFixturesFromServer() // Get latest fixtures from api
//        createDeepLink()
        //Branch Setup
//        Branch.getInstance().validateSDKIntegration()
//        Branch.getInstance().setIdentity("salim123") //Testing
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
    
    private func showInstructions() {
        let instructController = SP_InstructionsPopupViewController.newInstance(contentType: .Instruction)
        present(instructController, animated: false, completion: nil)
    }
    
    private func getFixturesFromServer() {
        if fixturesArray.isEmpty {
            refreshControl.beginRefreshing()
        }
        let localTimeZone = TimeZone.current.identifier //getNextFixtures
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getNextFixtures + localTimeZone, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
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
                }
            }
            strongSelf.showFixtures()
        }
    }
    
    private func showFixtures() {
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
        
        
//        let queryItemUsername = URLQueryItem(name: "username", value: "salim123")
//        let queryItemTimeStamp = URLQueryItem(name: "timestamp", value: "1601857005")
//        components.queryItems = [queryItemUsername,queryItemTimeStamp]
        guard let urlComponent = components.url else { return  }
        guard let longShareLink = DynamicLinkComponents.init(link: urlComponent, domainURIPrefix: dynamicLinksDomainURIPrefix) else { return }

        //        guard let link = URL(string: "https://sportpot.page.link/pot1?username=salim123&timestamp=1601857005") else { return }
        //        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        //        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.sportpot.Sportpot")
        //        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.example.android")
        //
        guard let longDynamicLink = longShareLink.url else {
            print ("Couldn't create FDL Components")
            return
        }
        print("The long URL is: \(longDynamicLink)")
        //        linkBuilder?.options = DynamicLinkComponentsOptions()
        //        linkBuilder?.options?.pathLength = .short
        
        DynamicLinkComponents.shortenURL( longDynamicLink, options: nil) { [weak self] url, warnings, error in
            guard let url = url, error == nil else { return }
            print("The short URL is: \(url)")
            self?.showShareSheet(url: url)
        }
        if let bundleID = Bundle.main.bundleIdentifier {
            longShareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
            longShareLink.iOSParameters?.appStoreID = "AppStoreID"
            longShareLink.iOSParameters?.minimumAppVersion = "1.0"
        }
    }
    func showShareSheet(url: URL) {
        let message = "Check out the pot I just created on Sportpot!"
        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        Branch.getInstance().logout()
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
        if !fixturesArray.isEmpty {
            matchCell.displayFixture(fixtureModel: fixturesArray[indexPath.section])
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
