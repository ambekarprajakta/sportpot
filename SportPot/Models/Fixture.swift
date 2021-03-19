//
//  Fixture.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 02/11/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Fixture
class Fixture: Codable {
    let fixtureID, leagueID: Int
    let league: League
    let eventDate: Date
    let eventTimestamp: Int
    let firstHalfStart, secondHalfStart: JSONNull?
    let round, status, statusShort: String
    let elapsed: Int
    let venue: String
    let referee: JSONNull?
    let homeTeam, awayTeam: Team
    let goalsHomeTeam, goalsAwayTeam: JSONNull?
    let score: Score

    enum CodingKeys: String, CodingKey {
        case fixtureID = "fixture_id"
        case leagueID = "league_id"
        case league
        case eventDate = "event_date"
        case eventTimestamp = "event_timestamp"
        case firstHalfStart, secondHalfStart, round, status, statusShort, elapsed, venue, referee, homeTeam, awayTeam, goalsHomeTeam, goalsAwayTeam, score
    }

    init(fixtureID: Int, leagueID: Int, league: League, eventDate: Date, eventTimestamp: Int, firstHalfStart: JSONNull?, secondHalfStart: JSONNull?, round: String, status: String, statusShort: String, elapsed: Int, venue: String, referee: JSONNull?, homeTeam: Team, awayTeam: Team, goalsHomeTeam: JSONNull?, goalsAwayTeam: JSONNull?, score: Score) {
        self.fixtureID = fixtureID
        self.leagueID = leagueID
        self.league = league
        self.eventDate = eventDate
        self.eventTimestamp = eventTimestamp
        self.firstHalfStart = firstHalfStart
        self.secondHalfStart = secondHalfStart
        self.round = round
        self.status = status
        self.statusShort = statusShort
        self.elapsed = elapsed
        self.venue = venue
        self.referee = referee
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.goalsHomeTeam = goalsHomeTeam
        self.goalsAwayTeam = goalsAwayTeam
        self.score = score
    }
}

// MARK: - Team
class Team: Codable {
    let teamID: Int
    let teamName: String
    let logo: String

    enum CodingKeys: String, CodingKey {
        case teamID = "team_id"
        case teamName = "team_name"
        case logo
    }

    init(teamID: Int, teamName: String, logo: String) {
        self.teamID = teamID
        self.teamName = teamName
        self.logo = logo
    }
}

// MARK: - League
class League: Codable {
    let name, country: String
    let logo: String
    let flag: String

    init(name: String, country: String, logo: String, flag: String) {
        self.name = name
        self.country = country
        self.logo = logo
        self.flag = flag
    }
}

// MARK: - Score
class Score: Codable {
    let halftime, fulltime, extratime, penalty: JSONNull?

    init(halftime: JSONNull?, fulltime: JSONNull?, extratime: JSONNull?, penalty: JSONNull?) {
        self.halftime = halftime
        self.fulltime = fulltime
        self.extratime = extratime
        self.penalty = penalty
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
