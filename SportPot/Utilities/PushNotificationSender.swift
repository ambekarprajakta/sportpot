//
//  PushNotificationSender.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 22/04/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(with params:[String : Any]) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
//        let paramString: [String : Any] = ["to" : token,
//                                           "notification" : ["title" : title, "body" : body],
//                                           "data" : ["user" : "test_id"]]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:params, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAXnP1K3g:APA91bHFkBrsKRN6-wwi8viNDp0VgKGzHFjXvNwIzVyH3gWoSN6xHfiTfKGYyuBe2JKVwvAvRoKMxDDWVsZnCAb5Xq-6wPm4ZxL6jdtq1Ld3vUM_SaoMnsd1-5C9Pl-O7mXpj5-FFokz", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
