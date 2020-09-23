//
//  SP_HomeViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 12/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
struct Fixture: Codable {
    let fixture_id: Int
    let league_id: Int
    let league: League
    let event_date: String
    let event_timestamp: Int64
    let firstHalfStart: String?
    let secondHalfStart: String?
    let round: String
    let status: String
    let statusShort: String
    let elapsed: Int
    let venue: String
    let referee: String?
    let homeTeam: Team
    let awayTeam: Team
    let goalsHomeTeam: String?
    let goalsAwayTeam: String?
    //let score: Score?
}

struct League: Codable {
    let name: String
    let country: String
    let logo: String?
    let flag: String?
}

struct Team: Codable {
    let team_id: Int
    let team_name: String
    let logo: String?
}

struct Score {
    let halftime: String?
    let fulltime: String?
    let extratime: String?
    let penalty: String?
}

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
    var fixturesArray: Array<Fixture> = []
    
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
    }
    
    
    func showInstructions() {
        let instructController = SP_InstructionsPopupViewController.newInstance()
        present(instructController, animated: false, completion: nil)
    }
    
    func apiCall() {
        let localTimeZone = TimeZone.current.identifier //getNextFixtures
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getNextFixtures + localTimeZone, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let response = response {
                if let fixturesArray = response["api"]["fixtures"].array {
                    strongSelf.fixturesArray = fixturesArray.compactMap { (json) -> Fixture? in
                        return json.to(type: Fixture.self)
                    }
                    strongSelf.matchTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)

    }
}
extension SP_HomeViewController : UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return fixturesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let matchCell = matchTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MatchTableViewCell
        matchCell.displayFixture(fixtureModel: fixturesArray[indexPath.section])
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
