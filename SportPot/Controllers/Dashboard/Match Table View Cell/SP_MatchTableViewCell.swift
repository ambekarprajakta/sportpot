//
//  SP_MatchTableViewCell.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 12/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
enum PredictionType: Int, Codable {
    case home = 1
    case draw = 2
    case away = 3
    case none = 0
}

protocol SP_MatchTableViewCellDelegate {
    func didChangeSelectionFor(cell: SP_MatchTableViewCell, predictionType: PredictionType)
    func didTapDoubleDownOn(cell: SP_MatchTableViewCell)
}

class SP_MatchTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var homeTeamLogo: UIImageView!
    @IBOutlet private weak var awayTeamLogo: UIImageView!
    @IBOutlet private weak var matchTimeLabel: UILabel!
    @IBOutlet private weak var homeTeamNameLabel: UILabel!
    @IBOutlet private weak var awayTeamNameLabel: UILabel!
    @IBOutlet private weak var homeTeamScoreLabel: UILabel!
    
    @IBOutlet private weak var homePointsBtn: UIButton!
    @IBOutlet private weak var awayTeamScoreLabel: UILabel!
    @IBOutlet private weak var drawPointsBtn: UIButton!
    @IBOutlet private weak var awayPointsBtn: UIButton!
    @IBOutlet private weak var doublePointsBtn: UIButton!
    @IBOutlet private weak var goalsView: UIView!
    @IBOutlet private weak var teamNameView: UIView!
    @IBOutlet private weak var matchFinishedView: UIView!
    @IBOutlet private weak var teamNameViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var matchStatusLabel: UILabel!
    @IBOutlet private weak var liveView: UIView!
    @IBOutlet private weak var liveMinuteLabel: UILabel!
    @IBOutlet private var selectionButtons: [UIButton]!

    private var delegate: SP_MatchTableViewCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
    
    func isMatchOn(fixtureModel: FixtureModel) -> Bool {
        if fixtureModel.statusShort == "1H" || fixtureModel.statusShort == "2H" || fixtureModel.statusShort == "HT" || fixtureModel.statusShort == "FT" {
            return true
        }
        return false
    }
    
    func displayFixture(fixtureModel: FixtureModel, points: FixturePoints, delegate: SP_MatchTableViewCellDelegate? = nil) {

        if fixtureModel.isMatchOnGoing(){
            layerView.isHidden = false
            layerView.backgroundColor = .lightGray
            layerView.alpha = 0.5
            self.isUserInteractionEnabled = false
        } else {
            layerView.isHidden = true
            layerView.backgroundColor = .clear
            layerView.alpha = 1
            self.isUserInteractionEnabled = true
        }

        self.delegate = delegate
        updateSelection(fixture: fixtureModel)
        
        if points.fixtureId == fixtureModel.fixture_id {
            homePointsBtn.setTitle(String(points.home), for: .normal)
            drawPointsBtn.setTitle(String(points.draw), for: .normal)
            awayPointsBtn.setTitle(String(points.away), for: .normal)
        }
        
        // Match Time
        let timeDiff = Date.currentTimeStamp.distance(to: fixtureModel.event_timestamp)
        if timeDiff < 0 { // Always <
            // TODO: - Check other statuses to handle the cases
            if fixtureModel.statusShort == "FT" {
                matchStatusLabel.text = fixtureModel.status?.uppercased()
                matchFinishedView.isHidden = false
                liveView.isHidden = true
                goalsView.isHidden = false
                matchTimeLabel.isHidden = true
                teamNameViewLeadingConstraint.constant = 0
            } else if fixtureModel.statusShort == "PST" {
                matchStatusLabel.text = fixtureModel.status?.uppercased()
                matchFinishedView.isHidden = false
                matchTimeLabel.isHidden = true
                liveView.isHidden = true
                goalsView.isHidden = true
//                teamNameViewLeadingConstraint.constant = 0
            } else if fixtureModel.statusShort != "NS" { // Always != NS
                matchTimeLabel.isHidden = true
                liveView.isHidden = false
                goalsView.isHidden = false
                teamNameViewLeadingConstraint.constant = 0
                liveMinuteLabel.text = String(fixtureModel.elapsed ?? 0)+"'"
            }

        } else {
            liveView.isHidden = true
            matchTimeLabel.isHidden = false
            matchFinishedView.isHidden = true
            goalsView.isHidden = true
            teamNameViewLeadingConstraint.constant = -goalsView.frame.width + 8
            let timestamp = fixtureModel.event_timestamp
            let myTimeInterval = TimeInterval(timestamp)
            let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
            matchTimeLabel.text = time.dateAndTimetoString()
        }
        
        // Logo
        homeTeamLogo.image = UIImage(named: "placeholder-team-logo")
        awayTeamLogo.image = UIImage(named: "placeholder-team-logo")
        if let homeTeamImageUrl = fixtureModel.homeTeam?.logo, let imageUrl = URL(string: homeTeamImageUrl) {
            downloadLogo(url: imageUrl, forImageView: homeTeamLogo)
        }
        if let homeTeamImageUrl = fixtureModel.awayTeam?.logo, let imageUrl = URL(string: homeTeamImageUrl) {
            downloadLogo(url: imageUrl, forImageView: awayTeamLogo)
        }
        
        // Teams
        print(fixtureModel.fixture_id)
        print(fixtureModel.homeTeam?.team_name, fixtureModel.awayTeam?.team_name)
        homeTeamNameLabel.text = fixtureModel.homeTeam?.team_name
        awayTeamNameLabel.text = fixtureModel.awayTeam?.team_name
        
        // Goals        
        if (NSNumber(value: fixtureModel.goalsHomeTeam ?? 0).intValue >= 0 && isMatchOn(fixtureModel: fixtureModel)) {
            homeTeamScoreLabel.text = String(fixtureModel.goalsHomeTeam ?? 0)
            goalsView.isHidden = false
            teamNameViewLeadingConstraint.constant = 0
        } else {
            homeTeamScoreLabel.text = "-"
            goalsView.isHidden = true
            teamNameViewLeadingConstraint.constant = -goalsView.frame.width + 8
        }
        
        if (NSNumber(value: fixtureModel.goalsAwayTeam ?? 0).intValue >= 0 && isMatchOn(fixtureModel: fixtureModel)) {
            goalsView.isHidden = false
            awayTeamScoreLabel.text = String(fixtureModel.goalsAwayTeam ?? 0)
            teamNameViewLeadingConstraint.constant = 0
            
        } else {
            awayTeamScoreLabel.text = "-"
            goalsView.isHidden = true
            teamNameViewLeadingConstraint.constant = -goalsView.frame.width + 8
        }
    }

    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    private func downloadLogo(url: URL, forImageView: UIImageView) {
        getData(from: url) { [weak self] data, response, error in
            guard let _ = self, let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                guard let _ = self else { return }
                forImageView.image = UIImage(data: data)
            }
        }
    }

    private func roundOff(value: Double) -> String {
        let roundedValue = Double(value < 0.5 ? 0.5 : floor(value * 2) / 2)
        return String(format: "%.1f", roundedValue)
    }
    
    // MARK: - IBAction

    @IBAction private func homePointsAction(_ sender: UIButton) {
        delegate?.didChangeSelectionFor(cell: self, predictionType: .home)
    }
    
    @IBAction private func drawPointsAction(_ sender: UIButton) {
        delegate?.didChangeSelectionFor(cell: self, predictionType: .draw)
    }

    @IBAction private func awayPointsAction(_ sender: UIButton) {
        delegate?.didChangeSelectionFor(cell: self, predictionType: .away)
    }

    @IBAction private func doublePointsAction(_ sender: UIButton) {
        delegate?.didTapDoubleDownOn(cell: self)
    }

    func updateSelection(fixture: FixtureModel) {
        doublePointsBtn.isSelected = fixture.isDoubleDown ?? false
        for button in selectionButtons {
            if button.tag == fixture.predictionType?.rawValue {
                button.backgroundColor = fixture.isDoubleDown ?? false ? .sp_purple : .sp_mustard
                button.setTitleColor(fixture.isDoubleDown ?? false ? .white : .black, for: .normal)
            } else {
                button.backgroundColor = .sp_gray
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
}
