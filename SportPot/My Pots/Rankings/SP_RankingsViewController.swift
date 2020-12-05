//
//  SP_RankingsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SP_RankingsViewController: UIViewController {

    @IBOutlet private weak var rankingTableView: UITableView!
    @IBOutlet private weak var potDateLabel: UILabel!
    @IBOutlet private weak var lastUpdatedLabel: UILabel!

    var pot: Pot!
    private var joinees = [Joinee]()

    private let winnerCellID = String(describing: SP_RankingWinnerTableViewCell.self)
    private let rankingCellID = String(describing: SP_RankingTableViewCell.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        rankingTableView.register(UINib(nibName: winnerCellID, bundle: nil), forCellReuseIdentifier: winnerCellID)
        rankingTableView.register(UINib(nibName: rankingCellID, bundle: nil), forCellReuseIdentifier: rankingCellID)

        let dateTimeStampStr = Double(pot.createdOn) ?? 0
        let myTimeInterval = TimeInterval(dateTimeStampStr)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
        potDateLabel.text = time.dateAndTimetoString()
        
        //Check round number - call API with round and league ID
//        guard let roundNoStr = potDetail["round"] as? String else { return }
        //If currentRound == pot round, skip it
        if let round = pot.round, shouldComputeWinner() {
            getFixturesFrom(round: round)
        } else {
            joinees.append(contentsOf: pot.joinees)
        }
    }
    
    func getFixturesFrom(round: String) {
        let localTimeZone = TimeZone.current.identifier
        SP_APIHelper.getResponseFrom(url: Constants.API_DOMAIN_URL + APIEndPoints.getFixturesfromLeague + round + Constants.kTimeZone + localTimeZone, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { [weak self] (response, error) in
            guard let self = self else { return }
            if let response = response {
                if let fixturesArray = response["api"]["fixtures"].array, !fixturesArray.isEmpty {
                    let fixtures = fixturesArray.compactMap { (fixtureObject) -> FixtureMO? in
                        guard let fixtureDictionary = fixtureObject.dictionaryObject else { return nil }
                        do {
                            let fixtureData = try JSONSerialization.data(withJSONObject: fixtureDictionary, options: [])

                            guard let codingUserInfoKeyContext = CodingUserInfoKey.context else { return nil }
                            let decoder = JSONDecoder()
                            decoder.userInfo[codingUserInfoKeyContext] = nil // Pass nil as we don't want to save in core data

                            return try decoder.decode(FixtureMO.self, from: fixtureData)

                        } catch {
                            return nil
                        }
                    }
                    self.compareScoresFrom(fixturesArr: fixtures)
                }
            }
        }
    }
    
    func compareScoresFrom(fixturesArr: [FixtureMO]) {
        var allJoinees = [Joinee]()

        // Score calculation logic
        let homePoints: Double = 3.5
        let drawPoints: Double = 2.5
        let awayPoints: Double = 4

        pot.joinees.forEach { (joinee) in
            var accuracy: Double = 0
            var doubleDown: Double = 0
            var pointsScored: Double = 0
            joinee.predictions.forEach { (prediction) in
                for fixture in fixturesArr {
                    if fixture.fixture_id == prediction.fixtureId {
                        if fixture.isMatchFinished() {
                            if fixture.goalsAwayTeam == fixture.goalsHomeTeam {
                                // Draw
                                if prediction.selection == 2 {
                                    accuracy+=1
                                    if prediction.isDoubleDown {
                                        doubleDown+=1
                                        pointsScored+=(drawPoints*2)
                                    } else {
                                        pointsScored+=drawPoints
                                    }
                                }
                            } else if fixture.goalsAwayTeam > fixture.goalsHomeTeam {
                                // Away team won
                                if prediction.selection == 3 {
                                    accuracy+=1
                                    if prediction.isDoubleDown {
                                        doubleDown+=1
                                        pointsScored+=(awayPoints*2)
                                    } else {
                                        pointsScored+=awayPoints
                                    }
                                }
                            } else {
                                // Home team won
                                if prediction.selection == 1 {
                                    accuracy+=1
                                    if prediction.isDoubleDown {
                                        doubleDown+=1
                                        pointsScored+=(homePoints*2)
                                    } else {
                                        pointsScored+=homePoints
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }

            let joineeCopy = joinee.copy()
            joineeCopy.accuracy = accuracy
            joineeCopy.doubleDown = doubleDown
            joineeCopy.pointsScored = pointsScored
            allJoinees.append(joineeCopy)
        }

        // Winner logic
        var winners = [Joinee]()    // To hold all the unique winners

        // Check winner based on highest accuracy
        let joineesSortedByHighestAccuracy = allJoinees.sorted(by: { (j1, j2) -> Bool in
            return j1.accuracy ?? 0 > j2.accuracy ?? 0
        })

        // Check if there are multiple winners
        let highestAccuracy = joineesSortedByHighestAccuracy[0].accuracy
        let highestAccuracyWinners = joineesSortedByHighestAccuracy.filter({$0.accuracy == highestAccuracy})
        if highestAccuracyWinners.count > 1 {

            // We have multiple winners
            // Check for highest double down among the winners only
            let joineesSortedByHighestDoubleDown = highestAccuracyWinners.sorted(by: { (j1, j2) -> Bool in
                return j1.doubleDown ?? 0 > j2.doubleDown ?? 0
            })

            let highestDoubleDown = joineesSortedByHighestDoubleDown[0].doubleDown ?? 0
            if highestDoubleDown > 0 {
                let highestDoubleDownWinners = joineesSortedByHighestDoubleDown.filter({$0.doubleDown == highestDoubleDown})

                /// `highestDoubleDownWinners` will contain at least one joinee
                /// If it contains more than 1 joinee, still all are winners
                /// Add all the double down winners
                winners.append(contentsOf: highestDoubleDownWinners)
            } else {
                // Since double down is 0 for all the winners with highest accuracy, they are the only winners
                winners.append(contentsOf: highestAccuracyWinners)
            }

        } else {
            /// `highestAccuracyWinners` will contain only contain one joinee at this point
            winners.append(contentsOf: highestAccuracyWinners)
        }

        // Clear all the joinees if any
        joinees.removeAll()
        allJoinees.forEach { (joinee) in
            let copyJoinee = joinee.copy()
            copyJoinee.winner = winners.contains(joinee)
            joinees.append(copyJoinee)
        }

        // Winners computed, sort the joinees so that it shows winners at the top
        joinees.sort(by: { $0.isWinner() && !$1.isWinner() })

        rankingTableView.reloadData()
        updatePotWinnerToFirebase()
    }

    private func shouldComputeWinner() -> Bool {
        /// If the winner data is available, the `winner` property will never be nil.
        for joinee in joinees {
            /// If the `winner` property is nil for any joinee it means winner data is not available on Firebase.
            if joinee.winner == nil {
                return true
            }
        }
        return false
    }

    private func updatePotWinnerToFirebase() {
        let jsonEncoder = JSONEncoder()
        guard let potId = pot.id else { return }
        guard let joineesData = try? jsonEncoder.encode(joinees) else { return }
        guard let joineesJsonArray = try? JSONSerialization.jsonObject(with: joineesData, options: .allowFragments) as? JSONArray else { return }
        print("Params: \(joineesJsonArray)")
        let joineesRef = Firestore.firestore().collection("pots").document(potId)
        joineesRef.updateData([
            "joinees": joineesJsonArray
        ])
    }
}

extension SP_RankingsViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let joinee = joinees[indexPath.row]
        if joinee.isWinner() {
            let winnerCell = tableView.dequeueReusableCell(withIdentifier: winnerCellID, for: indexPath) as! SP_RankingWinnerTableViewCell
            winnerCell.display(joinee: joinee)
            return winnerCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: rankingCellID, for: indexPath) as! SP_RankingTableViewCell
        cell.display(joinee: joinee)
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinees.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        }
        return UITableView.automaticDimension
    }

}
