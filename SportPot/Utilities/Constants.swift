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
    static let UXCAM_API_KEY = "ykxmufzpt5l6ak9"
    
    static let RAPID_HEADER_ARRAY = [   "x-rapidapi-host": RAPID_API_HOST,
                                        "x-rapidapi-key": RAPID_API_KEY]
    static let API_DOMAIN_URL = "https://api-football-v1.p.rapidapi.com/"
    static let EPL_LEAGUE_ID_20_21 = "2790/"
    static let kDYNAMIC_LINK_BASE_URL = "https://sportpot.page.link"
    static let kCurrentRound = "\(UserDefaults.standard.object(forKey: UserDefaultsConstants.currentRoundKey) ?? "")"
    static let kTimeZone = "?timezone="
    static let kMaxMatchesRemaining = 3
    static let kBookMakerID = 6 //BWin
}
struct ErrorMessages {
    static let passwordError = "Please enter a password"
    static let emailPhoneError = "Please enter registered email address or phone number"
    static let userNameExistsError = "Username already exists! Please try another one!"
}
//https://api-football-v1.p.rapidapi.com/v2/fixtures/league/2790/Regular_Season_-_8
struct APIEndPoints {
    static let getCurrentRound = "v2/fixtures/rounds/" + Constants.EPL_LEAGUE_ID_20_21 + "/current"
    static let getFixturesfromLeague = "v2/fixtures/league/" + Constants.EPL_LEAGUE_ID_20_21
    static let getLastFixtures = "v2/fixtures/league/" + Constants.EPL_LEAGUE_ID_20_21 + "/last/10?timezone=" //Testing purposes only
}

struct PopupType {
    enum ContentType {
        case Instruction
        case BetTenMatches
        case SelectAtleastThreeDoubleDown
        case AlreadySelectedThreeDoubleDown
    }
}
struct UserDefaultsConstants {
    static let currentRoundKey = "currentRound"
    static let launchCountKey = "launchCount"
    static let currentUserKey = "currentUser"
    static let displayNameKey = "displayName"
    //Notification Badge
    static let notificationsBadgeCount = "notificationsBadgeCount"
    static let notificationToken = "notificationToken"
    
}
