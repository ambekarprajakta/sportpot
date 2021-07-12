//
//  SPAnalyticsManager.swift
//  SportPot
//
//  Created by Arun on 12/07/21.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import FirebaseAnalytics

class SPAnalyticsManager: NSObject {
    
    func logEventToFirebase(name:String, parameters : [String:Any]?)  {
        Analytics.logEvent(name, parameters: parameters)
    }
    
}
