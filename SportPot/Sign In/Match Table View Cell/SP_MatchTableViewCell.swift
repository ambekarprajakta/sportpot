//
//  SP_MatchTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 12/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit

class SP_MatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var homeTeamLogo: UIImageView!
    @IBOutlet weak var awayTeamLogo: UIImageView!
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamScoreLabel: UILabel!
    
    @IBOutlet weak var homePointsBtn: UIButton!
    @IBOutlet weak var awayTeamScoreLabel: UILabel!
    @IBOutlet weak var drawPointsBtn: UIButton!
    @IBOutlet weak var awayPointsBtn: UIButton!
    @IBOutlet weak var doublePointsBtn: UIButton!
    @IBOutlet weak var goalsView: UIView!
    @IBOutlet weak var teamNameView: UIView!
    @IBOutlet weak var teamNameViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var liveMinuteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func displayFixture(fixtureModel: FixtureMO) {
        //        Date().description(with: .current)  //  Tuesday, February 5, 2019 at 10:35:01 PM Brasilia Summer Time"
        //        let dateString = Date().iso8601withFractionalSeconds   //  "2019-02-06T00:35:01.746Z"
        //
        //        if let date = dateString.iso8601withFractionalSeconds {
        //            date.description(with: .current) // "Tuesday, February 5, 2019 at 10:35:01 PM Brasilia Summer Time"
        //            print(date.iso8601withFractionalSeconds)           //  "2019-02-06T00:35:01.746Z\n"
        //        }
        
        //Match Time
        let timeDiff = Date.currentTimeStamp .distance(to: fixtureModel.event_timestamp)
        if timeDiff <= 0{ //Always <
            //TODO: Check other statuses to handle the cases
            if fixtureModel.statusShort != "NS" { //Always !=NS
                matchTimeLabel.isHidden = true
                liveView.isHidden = false
                goalsView.isHidden = false
                teamNameViewLeadingConstraint.constant = 0
                liveMinuteLabel.text = String(fixtureModel.elapsed)+"'"
            }
        }else {
            liveView.isHidden = true
            goalsView.isHidden = true
            teamNameViewLeadingConstraint.constant = -goalsView.frame.width + 8
            let timestamp = fixtureModel.event_timestamp
            let myTimeInterval = TimeInterval(timestamp)
            let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
            matchTimeLabel.text = time.dateAndTimetoString()
        }
        
        //Logo
        //        homeTeamLogo.image = fixtureModel.homeTeam.logo
        //        awayTeamLogo.image = fixtureModel.awayTeam.logo
        
        
        //Teams
        homeTeamNameLabel.text = fixtureModel.homeTeam?.team_name
        awayTeamNameLabel.text = fixtureModel.awayTeam?.team_name
        
        //Goals
        if fixtureModel.goalsHomeTeam != nil {
            homeTeamScoreLabel.text = String(fixtureModel.goalsHomeTeam)
            goalsView.isHidden = false
            teamNameViewLeadingConstraint.constant = 0
        }else {
            homeTeamScoreLabel.text = "-"
            goalsView.isHidden = true
            teamNameViewLeadingConstraint.constant = -goalsView.frame.width + 8
        }
        
        if fixtureModel.goalsAwayTeam != nil {
            goalsView.isHidden = false
            awayTeamScoreLabel.text = String(fixtureModel.goalsAwayTeam)
            teamNameViewLeadingConstraint.constant = 0
            
        }else {
            awayTeamScoreLabel.text = "-"
            goalsView.isHidden = true
            teamNameViewLeadingConstraint.constant = -goalsView.frame.width + 8
        }
        
        
        /*
         if indexPath.section % 2 == 0 {
         matchCell.matchLabel.text = todayDate
         }else if indexPath.section % 3 == 0{
         matchCell.matchLabel.text = "20:30"
         }else{
         matchCell.matchLabel.text = "LIVE | 49'"
         }
         */
    }
    
    @IBAction func homePointsAction(_ sender: Any) {
        print("homePointsAction Button Selected")
    }
    
    @IBAction func drawPointsAction(_ sender: Any) {
        print("drawPointsAction Button Selected")
    }
    @IBAction func awayPointsAction(_ sender: Any) {
        print("awayPointsAction Button Selected")
    }
    @IBAction func doublePointsAction(_ sender: Any) {
        print("doublePointsAction Button Selected")
    }
}
