//
//  Constants.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 20/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation

struct Constants {
    static let RAPID_API_HOST = "api-football-v1.p.rapidapi.com"
    static let RAPID_API_KEY = "2655d66b0emsh6d813b20b21c893p1378b0jsn2a6961a15808"
    
    static let RAPID_HEADER_ARRAY = [   "x-rapidapi-host": RAPID_API_HOST,
                                        "x-rapidapi-key": RAPID_API_KEY]
    static let API_DOMAIN_URL = "https://api-football-v1.p.rapidapi.com/"
    static let EPL_LEAGUE_ID_20_21 = "2790"
}
struct ErrorMessages {
    static let passwordError = "Please enter a password"
    static let emailPhoneError = "Please enter registered email address or phone number"
}
struct APIEndPoints {
    static let getNextFixtures = "v2/fixtures/league/" + Constants.EPL_LEAGUE_ID_20_21 + "/next/10?timezone="
    static let getLastFixtures = "v2/fixtures/league/" + Constants.EPL_LEAGUE_ID_20_21 + "/last/10?timezone=" //Testing purposes only
}

struct PopupType {
    enum ContentType {
        case Instruction
        case BetTenMatches
        case SelectAtleastThreeDoubleDown
        case AlreadySelectedThreeDoubleDown
    }
    static let getTimeZone = ""
    static let getNextFixtures = "https://api-football-v1.p.rapidapi.com/v2/fixtures/league/2790/next/10?timezone=Europe/London"
}

