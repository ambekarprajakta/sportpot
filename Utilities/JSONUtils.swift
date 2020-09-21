//
//  JSONUtils.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/09/2020.
//  Copyright © 2020 Prajakta Ambekar. All rights reserved.
//

import Foundation
import SwiftyJSON

// Type definitions
typealias JSONObject = Dictionary<String, Any>
typealias JSONArray = Array<JSONObject>

extension JSONArray  {
    /// Convert JSONArray to your Array of custom models.
    /// - Parameters:
    ///     - type: Model class.
    ///     - dateDecodingStrategy: DateDecodingStrategy.
    ///     - keyDecodingStrategy: KeyDecodingStrategy.
    
    func toArray<T:Decodable>(of type: T.Type, dateDecodingStartegy: JSONDecoder.DateDecodingStrategy? = nil, keyDecodingStartegy: JSONDecoder.KeyDecodingStrategy? = nil) -> [T]? {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            let decoder = JSONDecoder()
            if let dateStrategy = dateDecodingStartegy {
                decoder.dateDecodingStrategy = dateStrategy
            }
            
            if let keyStrategy = keyDecodingStartegy {
                decoder.keyDecodingStrategy = keyStrategy
            }
            return try decoder.decode([T].self, from: data)
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
extension JSON {
    
    func to<T: Decodable>(type: T.Type, dateDecodingStartegy: JSONDecoder.DateDecodingStrategy? = nil, keyDecodingStartegy: JSONDecoder.KeyDecodingStrategy? = nil) -> T? {
        return dictionaryObject?.to(type: type, dateDecodingStartegy: dateDecodingStartegy, keyDecodingStartegy: keyDecodingStartegy)
    }
}
extension JSONObject {
    
    /// Covert JSONObject to your model.
    /// - Parameters:
    ///     - type: Model class.
    ///     - dateDecodingStrategy: DateDecodingStrategy.
    ///     - keyDecodingStrategy: KeyDecodingStrategy.

    func to<T:Decodable>(type: T.Type, dateDecodingStartegy: JSONDecoder.DateDecodingStrategy? = nil, keyDecodingStartegy: JSONDecoder.KeyDecodingStrategy? = nil) -> T? {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            let decoder = JSONDecoder()
            if let dateStrategy = dateDecodingStartegy {
                decoder.dateDecodingStrategy = dateStrategy
            }
            
            if let keyStrategy = keyDecodingStartegy {
                decoder.keyDecodingStrategy = keyStrategy
            }
            return try decoder.decode(type, from: data)
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}

extension Data {
    
    func toJSON() -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    func toJSONObject() -> JSONObject? {
        return toJSON() as? JSONObject
    }

    func toJSONArray() -> JSONArray? {
        return toJSON() as? JSONArray
    }
}

extension String {

    /// Convert to json element
    func toJson() -> Any? {
        
        let stringData = data(using: .utf8)!
        do {
            return try JSONSerialization.jsonObject(with: stringData, options : .allowFragments)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
}
