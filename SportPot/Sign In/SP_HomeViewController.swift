//
//  SP_HomeViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 12/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    struct Fixtures: Codable {
        let fixture_id : Int
        let league_id : Int
//        let league : Dictionary<String, Any>
        let event_date : String
        let event_timestamp : Int
        let firstHalfStart : String?
        let secondHalfStart : String?
        let round : String
        let status : String
        let statusShort : String
        let elapsed : String
        let venue : String
        let referee : String
//        let homeTeam : Dictionary<String, Any>
//        let awayTeam : Dictionary<String, Any>
        let goalsHomeTeam : String
        let goalsAwayTeam : String
//        let score : Dictionary<String, Any>
    }
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
    var fixturesArray: Array<Any> = []
    
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
//        let instructions = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instructController = storyboard.instantiateViewController(identifier: "SP_InstructionsPopupViewController") as SP_InstructionsPopupViewController

        // MARK: - Add logic for instructions - Only 3 times per login
//        if instructions == false {
//            showInstructions()
//        }else {
//            instructController.showPopupfor(viewcontroller: self, type: .BetTenMatches)
//        }
//        let content = .BetTenMatches as PopupType.ContentType
//        if content == PopupType.ContentType.BetTenMatches {
//            instructController.popupTitleLabel.text = "Oops!"
//            instructController.popupDetailTextLabel.text = "only 10 allowed!"
//
//        }
        instructController.modalPresentationStyle = .overCurrentContext
        self.present(instructController, animated: false, completion: nil)

        apiCall()
    }
    
    
    func showInstructions() {
        //SP_InstructionsPopupViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instructController = storyboard.instantiateViewController(identifier: "SP_InstructionsPopupViewController")
        instructController.modalPresentationStyle = .overCurrentContext
        self.present(instructController, animated: false, completion: nil)
    }
    
    func apiCall() {
//        let headers = [
//            "x-rapidapi-host": "api-football-v1.p.rapidapi.com",
//            "x-rapidapi-key": "2655d66b0emsh6d813b20b21c893p1378b0jsn2a6961a15808"
//        ]
        
        
//        let endPoint = "https://api-football-v1.p.rapidapi.com/v2/predictions/157462"
        SP_APIHelper.getResponseFrom(url: APIEndPoints.getNextFixtures, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { (response, error) in
            
            
//            self.fixturesArray = response?["api"]["fixtures"]
//            if let response = response {
                
//                if let fixturesArray = response["api"]["fixtures"].array {
//                    fixturesArray = fixturesArray.compactMap { (json) -> Fixtures? in
//                        return response.to(type: Fixtures.self)
//                    }
//                }
//            }
        }
    }
        
//        SP_APIHelper.getResponseFrom(url: endPoint, method: .get, params: nil, headers: headers) { (response, error) in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            //["api.results.predictions"]
//
//        }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let matchCell = matchTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SP_MatchTableViewCell
        if indexPath.section % 2 == 0 {
            matchCell.matchLabel.text = todayDate
        }else if indexPath.section % 3 == 0{
            matchCell.matchLabel.text = "20:30"
        }else{
            matchCell.matchLabel.text = "LIVE | 49'"
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
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SP_GetStartedViewController")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)

    }

    
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
*/
}
