//
//  AbstractPBXObject.swift
//  XcodeProject
//
//  Created by Yudai Hirose on 2019/07/10.
//

import Foundation

extension PBX {
    public typealias Object = PBX.AbstractObject
    
    open class AbstractObject {
        public let id: String
        public let dictionary: PBXPair
        public let isa: ObjectType
        public let allPBX: Context
        
        // FIXME:
        open var objectDictionary: PBXPair {
            return dictionary
        }
        
        public required init(
            id: String,
            dictionary: PBXPair,
            isa: String,
            allPBX: Context
            ) {
            self.id = id
            self.dictionary = dictionary
            self.isa = ObjectType(for: isa)
            self.allPBX = allPBX
        }
        
        final func extractStringIfExists(for key: String) -> String? {
            return dictionary[key] as? String
        }
        
        final func extractString(for key: String) -> String {
            guard let value = extractStringIfExists(for: key) else {
                fatalError(assertionMessage(description: "wrong format is type: \(type(of: self)), key: \(key), id: \(id)"))
            }
            return value
        }
        
        final func extractStrings(for key: String) -> [String] {
            guard let value = dictionary[key] as? [String] else {
                fatalError(assertionMessage(description: "wrong format is type: \(type(of: self)), key: \(key), id: \(id)"))
            }
            return value
        }
        
        final func extractBool(for key: String) -> Bool {
            let boolString: String = extractString(for: key)
            
            switch boolString {
            case "0":
                return false
            case "1":
                return true
            default:
                fatalError(assertionMessage(description: "unknown bool string: \(boolString)"))
                
            }
        }
        
        final func extractObject<T: PBX.Object>(for key: String) -> T {
            let objectKey = extractString(for: key)
            return allPBX.object(for: objectKey)
        }
        
        final func extractObjects<T: PBX.Object>(for key: String) -> [T] {
            let objectKeys = extractStrings(for: key)
            return objectKeys.map(allPBX.object)
        }
        
        final func extractPair(for key: String) -> PBXPair {
            return dictionary[key] as! PBXPair
        }
    }
}
