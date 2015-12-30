//
//  FilterGen.swift
//  LightRoom
//
//  Created by Muukii on 9/28/15.
//  Copyright © 2015 muukii. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum FilterJSONConvertErrorType: ErrorType {
    
    case MissingRequiredParameter(requiredParameterName: String)
    case CanNotConvertJSON(filterGen: FilterGen)
}

public protocol FilterJSONConvertible {
    
    var json: JSON { get }
    init(json: JSON) throws
}

public protocol FilterGen {
    
    var filterName: String { get }
    var filter: Filter { get }
}

public func CreateFilterGen(json json: JSON) throws -> [FilterGen] {
    
    var filterGens: [FilterGen] = []
    
    for json in json["filters"].arrayValue {
        
        guard let filterName = json[LightRoomJSONKeys.FilterName].string else {
            throw FilterJSONConvertErrorType.MissingRequiredParameter(requiredParameterName: LightRoomJSONKeys.FilterName)
        }
        
        /*
        switch filterName {
        case "CIBoxBlur":
            if #available(iOS 9.0, *) {
                filterGens.append(try LightRoom.Blur.BoxBlur(json: json))
            }
            
            // TODO:
            
        default:
            break
        }
        */
        
        if filterName.hasPrefix("CI") {
            
            let gen = try CIFilterGen(json: json)
            filterGens.append(gen)
        } else {
            
            if let gen = try LightRoom.configuration?.filterGen(filterName, json: json) {
                filterGens.append(gen)
            }
        }
    }
    
    return filterGens
}

public func ExportFilterGen(filterGens filterGens: [FilterGen]) throws -> JSON {
    
    var jsons: [JSON] = []
    
    for filterGen in filterGens {
        
        guard let _filterGen = filterGen as? FilterJSONConvertible else {
            throw FilterJSONConvertErrorType.CanNotConvertJSON(filterGen: filterGen)
        }
        
        jsons.append(_filterGen.json)
    }
    
    let json = JSON(["filters" : JSON(jsons)])
    
    return json
}


public enum LightRoomJSONKeys {
    public static let FilterName = "filterName"
    public static let Parameters = "Parameters"
}

public class CIFilterGen: FilterGen {
    
    // Deprecated
    public convenience init(json: JSON) throws {
        
        guard let filterName = json[LightRoomJSONKeys.FilterName].string else {
            throw FilterJSONConvertErrorType.MissingRequiredParameter(requiredParameterName: LightRoomJSONKeys.FilterName)
        }
        
        guard let parameters = json[LightRoomJSONKeys.Parameters].dictionaryObject else {
            throw FilterJSONConvertErrorType.MissingRequiredParameter(requiredParameterName: LightRoomJSONKeys.Parameters)
        }
        
        let objectParameters = StringParametersToCIFilterParameters(parameters)
        self.init(filterName: filterName, parameters: objectParameters)
    }
    
    public let filterName: String
    public let parameters: [String: AnyObject]
    
    init(filterName: String, parameters: [String: AnyObject]) {
        
        self.filterName = filterName
        self.parameters = parameters
    }
    
    public var filter: Filter {
        
        return LightRoom.createFilter(CIFilterName: filterName, parameters: parameters)
    }
}

public extension FilterJSONConvertible where Self: CIFilterGen {
    
    public var json: JSON {
        
        var rawJSON: [String: AnyObject] = [ : ]
        
        rawJSON[LightRoomJSONKeys.FilterName] = self.filterName
        rawJSON[LightRoomJSONKeys.Parameters] = CIFilterParametersToStringParameters(self.parameters)
        
        return JSON(rawJSON)
    }
    
    public init(json: JSON) throws {
        
        guard let filterName = json[LightRoomJSONKeys.FilterName].string else {
            throw FilterJSONConvertErrorType.MissingRequiredParameter(requiredParameterName: LightRoomJSONKeys.FilterName)
        }
        
        guard let parameters = json[LightRoomJSONKeys.Parameters].dictionaryObject else {
            throw FilterJSONConvertErrorType.MissingRequiredParameter(requiredParameterName: LightRoomJSONKeys.Parameters)
        }
        
        let objectParameters = StringParametersToCIFilterParameters(parameters)
        
        self.init(filterName: filterName, parameters: objectParameters)
    }
}

public func CIFilterParametersToStringParameters(parameters: [String: AnyObject]) -> [String: String] {
    
    var parametersJSON: [String: String] = [ : ]
    for param in parameters {
        
        let string: String
        switch param.1 {
        case let value as CIColor:
            string = value.stringRepresentation
        case let value as CIVector:
            string = value.stringRepresentation
        case let value as Double:
            string = String(value)
        case let value as Float:
            string = String(value)
        case let value as CGFloat:
            string = String(value)
        default:
            fatalError("Catched Not Supproted Value")
        }
        
        parametersJSON[param.0] = string
    }
    
    return parametersJSON
}

public func StringParametersToCIFilterParameters(parameters: [String: AnyObject]) -> [String: AnyObject] {
    
    var objectParameters: [String: AnyObject] = [ : ]
    
    for param in parameters {
        
        guard let string = param.1 as? String else {
            
            fatalError("")
        }
        
        if let value = Double(string) {
            
            objectParameters[param.0] = value
        } else if string.hasPrefix("[") && string.hasSuffix("]") {
            
            let value = CIVector(string: string)
            objectParameters[param.0] = value
        } else {
            
            let value = CIColor(string: string)
            objectParameters[param.0] = value
        }
    }
    
    return objectParameters
}
