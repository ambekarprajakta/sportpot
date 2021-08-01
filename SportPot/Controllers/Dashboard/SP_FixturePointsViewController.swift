//
//  SP_FixturePointsViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 27/02/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SP_FixturePointsViewController: UIViewController {
    
    var fixturesArray = Array<FixtureModel>()
    var fixturePoints = Array<FixturePoints>()
    var fixtureIds = [Int]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func getCurrentPointsFrom(season: String) {
        self.showHUD()
        fixturePoints.removeAll()
        db.collection("fixturePoints").document(season).getDocument { (docSnapShot, error) in
            self.hideHUD()
            if let response = docSnapShot?.data() {
                let fixturePointsArray = response["0"] as? [[String: Any]]
                self.fixturePoints = fixturePointsArray?.toArray(of: FixturePoints.self) ?? Array<FixturePoints>()
                print(self.fixturePoints)
            } else {
                print("No Data available")
                self.getFixturePoints(bookMakerId: Constants.kBookMakerID)
            }
            NotificationCenter.default.post(name: Notification.Name("refreshFixtures"), object: nil)
        }
    }

    private func getFixturePoints(bookMakerId: String) {
        if let fixtureId = self.fixtureIds.popLast() {
            let url = "https://api-football-v1.p.rapidapi.com/v2/odds/fixture/\(fixtureId)/bookmaker/\(bookMakerId)"
            self.showHUD()
            SP_APIHelper.getResponseFrom(url: url, method: .get, headers: Constants.RAPID_HEADER_ARRAY) { (response, error) in
                self.hideHUD()
                if let bookmakersArray = response?["api"]["odds"].array?.first?["bookmakers"].arrayObject as? [[String: Any]] {
                    let bookmakersList = bookmakersArray.toArray(of: BookMaker.self, keyDecodingStartegy: .convertFromSnakeCase)
                    if let bookmaker = bookmakersList?.first {
                        if let bet = bookmaker.bets.filter({ (bet) -> Bool in
                            return bet.labelName == "Match Winner"
                        }).first {
                            if let values = bet.values {
                                var red = values.reduce([String: Int]()) { (result, valueObj) -> [String: Int] in
                                    var result = result
                                    result[valueObj.value.lowercased()] = valueObj.odd
                                    return result
                                } as JSONObject
                                red["fixtureId"] = fixtureId
                                if let points = red.to(type: FixturePoints.self) {
                                    self.fixturePoints.append(points)
                                    self.getFixturePoints(bookMakerId: bookMakerId)
                                }
                            }
                        }
                    }
                } else {
                    let points = FixturePoints.init(home: Int.random(in: 1..<5), away: Int.random(in: 1..<5), draw: Int.random(in: 1..<5), fixtureId: fixtureId)
                    self.fixturePoints.append(points)
                    self.getFixturePoints(bookMakerId: bookMakerId)
                }
            }
        } else if !fixturePoints.isEmpty && fixturePoints.count == fixturesArray.count {
            savePointsToDB(fixturePoints: fixturePoints)
        }
    }
    
    private func savePointsToDB(fixturePoints: [FixturePoints]) {
        
        guard let data =  try? JSONEncoder().encode(fixturePoints),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
            return
        }
        print("JSON Array: \(jsonArray)")
        let round = UserDefaults.standard.object(forKey: UserDefaultsConstants.currentRoundKey)
        let potsRef =
            db.collection("fixturePoints").document(round as? String ?? "")
        
        potsRef.setData(["0": jsonArray]) { (err) in
            self.hideHUD()
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                NotificationCenter.default.post(name: Notification.Name("refreshFixtures"), object: nil)
            }
        }
    }
}
