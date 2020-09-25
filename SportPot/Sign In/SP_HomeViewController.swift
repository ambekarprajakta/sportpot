//
//  SP_HomeViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 12/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import CoreData

//struct Fixture: NSManagedObject {
//    let fixture_id: Int
//    let league_id: Int
//    let league: League
//    let event_date: String
//    let event_timestamp: Int64
//    let firstHalfStart: String?
//    let secondHalfStart: String?
//    let round: String
//    let status: String
//    let statusShort: String
//    let elapsed: Int
//    let venue: String
//    let referee: String?
//    let homeTeam: Team
//    let awayTeam: Team
//    let goalsHomeTeam: String?
//    let goalsAwayTeam: String?
////    let score: Score
//}
//
//struct League: Codable {
//    let name: String
//    let country: String
//    let logo: String?
//    let flag: String?
//}
//
//struct Team: Codable {
//    let team_id: Int
//    let team_name: String
//    let logo: String?
//}
//
//struct Score {
//    let halftime: String
//    let fulltime: String
//    let extratime: String?
//    let penalty: String?
//}

class SP_HomeViewController: UIViewController {
    /*
     {
     "fixture_id": 592152,
     "league_id": 2790,
     "league": {
     "name": "Premier League",
     "country": "England",
     "logo": "https://media.api-sports.io/football/leagues/39.png",
     "flag": "https://media.api-sports.io/flags/gb.svg"
     },
     "event_date": "2020-09-21T18:00:00+01:00",
     "event_timestamp": 1600707600,
     "firstHalfStart": null,
     "secondHalfStart": null,
     "round": "Regular Season - 2",
     "status": "Not Started",
     "statusShort": "NS",
     "elapsed": 0,
     "venue": "Villa Park",
     "referee": "G. Scott",
     "homeTeam": {
     "team_id": 66,
     "team_name": "Aston Villa",
     "logo": "https://media.api-sports.io/football/teams/66.png"
     },
     "awayTeam": {
     "team_id": 62,
     "team_name": "Sheffield Utd",
     "logo": "https://media.api-sports.io/football/teams/62.png"
     },
     "goalsHomeTeam": null,
     "goalsAwayTeam": null,
     "score": {
     "halftime": null,
     "fulltime": null,
     "extratime": null,
     "penalty": null
     }
     */
    
    let cellID = "SP_MatchTableViewCell"
    
    @IBOutlet weak var matchTableView: UITableView!
    
    var todayDate = ""
    var fixturesArray: Array<FixtureMO> = [] //
    var fixtureData: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "logo-sport-pot.png")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        matchTableView.register(UINib(nibName: "SP_MatchTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YY"
        todayDate = formatter.string(from: date)
        
        let instructController = SP_InstructionsPopupViewController.newInstance(title: "Oops!", message: "You must place bets on all 10 matches")
        present(instructController, animated: false, completion: nil)
        apiCall()
        //        fetchSavedData()
    }
    
    
    func showInstructions() {
        let instructController = SP_InstructionsPopupViewController.newInstance()
        present(instructController, animated: false, completion: nil)
    }
    
    func apiCall() {
        let localTimeZone = TimeZone.current.identifier //getNextFixtures
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getNextFixtures + localTimeZone, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
//
                        if let response = response {
                            if let fixturesArray = response["api"]["fixtures"].array {
//                                strongSelf.fixturesArray = fixturesArray.compactMap { (json) -> FixtureMO? in
//                                    for dict in strongSelf.fixturesArray {
                                var dict : [String: AnyObject]
                                for dict in fixturesArray {
                                    saveInCoreDataWith(array: dict)

                                }
//                                    }
//                                }
                            }
            }
//                                    return nil
//            //                        return json.to(type: FixtureMO.self)
//                                }
            strongSelf.matchTableView.reloadData()
                            
//                        }
        }
    }
    private func createFixtureEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context =   CoreDataManager.sharedManager.persistentContainer.viewContext
        if let fixtureModel = NSEntityDescription.insertNewObject(forEntityName: "Fixture", into: context) as? FixtureMO {
            fixtureModel.fixture_id = dictionary["fixture_id"] as! Int64
            fixtureModel.league_id = dictionary["league_id"] as! Int64
            fixtureModel.league?.name = dictionary["name"] as? String
            fixtureModel.league?.country = dictionary["country"] as? String
            fixtureModel.league?.logo = dictionary["logo"] as? String
            fixtureModel.league?.flag = dictionary["flag"] as? String
            
            fixtureModel.event_date = dictionary["event_date"] as? String
            fixtureModel.event_timestamp = dictionary["event_timestamp"] as! Int64
            fixtureModel.firstHalfStart = dictionary["firstHalfStart"] as! Int64
            fixtureModel.secondHalfStart = dictionary["secondHalfStart"] as! Int64
            
            fixtureModel.round = dictionary["round"] as? String
            fixtureModel.status = dictionary["status"] as? String
            fixtureModel.statusShort = dictionary["statusShort"] as? String
            fixtureModel.elapsed = dictionary["elapsed"] as! Int64
            fixtureModel.venue = dictionary["venue"] as? String
            fixtureModel.referee = dictionary["referee"] as? String
                        
            fixtureModel.homeTeam?.team_id = dictionary["team_id"] as! Int64
            fixtureModel.homeTeam?.team_name = dictionary["team_name"] as? String
            fixtureModel.homeTeam?.logo = dictionary["logo"] as? String
            
            fixtureModel.awayTeam?.team_id = dictionary["team_id"] as! Int64
            fixtureModel.awayTeam?.team_name = dictionary["team_name"] as? String
            fixtureModel.awayTeam?.logo = dictionary["logo"] as? String

            fixtureModel.goalsHomeTeam = dictionary["goalsHomeTeam"] as! Int64
            fixtureModel.goalsAwayTeam = dictionary["goalsAwayTeam"] as! Int64
            
            fixtureModel.league = dictionary["league"] as? LeagueMO
            fixtureModel.homeTeam = dictionary["league"] as? HomeTeamMO
            fixtureModel.awayTeam = dictionary["league"] as? AwayTeamMO
            
            return fixtureModel
        }
        return nil
    }
    private func saveInCoreDataWith(array: [String: AnyObject]) {
        _ = array.map{self.createFixtureEntityFrom(dictionary: $0)}
        do {
            try CoreDataManager.sharedManager.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    func saveData(response:Array<FixtureMO>) {
        //1
        let person = CoreDataManager.sharedManager.insertFixture(response: response)
        //2
        if person != nil {
            fixtureData.append(person!)//3
            matchTableView.reloadData()//4
        }
    }
    
    func fetchSavedData() {
        //1
        
        let managedContext =
            CoreDataManager.sharedManager.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Fixture")
        
        //3
        do {
            fixtureData = try managedContext.fetch(fetchRequest)
            print(fixtureData)
            matchTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        
    }
}

extension SP_HomeViewController  : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /*This delegate method will be called first.As the name of this method "controllerWillChangeContent" suggets write some logic for table view to initiate insert row or delete row or update row process. After beginUpdates method the next call will be for :
         
         - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
         
         */
        matchTableView.beginUpdates()
    }
    
    /*This delegate method will be called second. This method will give information about what operation exactly started taking place a insert, a update, a delete or a move. The enum NSFetchedResultsChangeType will provide the change types.
     
     
     public enum NSFetchedResultsChangeType : UInt {
     
     case insert
     
     case delete
     
     case move
     
     case update
     }
     
     */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                matchTableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                matchTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = matchTableView.cellForRow(at: indexPath) {
                //        configureCell(cell, at: indexPath)
            }
            break;
            
        case .move:
            if let indexPath = indexPath {
                matchTableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                matchTableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
            
        }
    }
    
    /*The last delegate call*/
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /*finally balance beginUpdates with endupdates*/
        matchTableView.endUpdates()
    }
}


extension SP_HomeViewController : UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return fixtureData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let matchCell = matchTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MatchTableViewCell
        if fixtureData.count > 0{
            matchCell.displayFixture(fixtureModel: fixtureData[indexPath.section] as! FixtureMO)
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
