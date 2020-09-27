//
//  SP_HomeViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 12/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import CoreData

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
        //        showFixtures() // Initially show fixtures from local db
        getFixturesFromServer() // Get latest fixtures from api
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
        let currentCount = UserDefaults.standard.integer(forKey: "launchCount")
        if currentCount < 3 {
            self.showInstructions()
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
    
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
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
