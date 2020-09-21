//
//  SP_APIHelper.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import SwiftyJSON
import Alamofire_SwiftyJSON
import Alamofire

typealias APIResponse = (_ result: JSON?, _ error: Error?) -> Void

class SP_APIHelper {

    class func getResponseFrom(url: String, method: HTTPMethod,
                               params: Dictionary<String, Any>? = nil,
                               headers: Dictionary<String, Any>? = nil, response: APIResponse?) {
        Alamofire.request(url, method: method, parameters: params, headers: headers as? HTTPHeaders)
            .responseSwiftyJSON { dataResponse in
                response?(dataResponse.value, dataResponse.error)
            }
    }
}




