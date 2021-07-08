//
//  PathComponent.swift
//  xcp
//
//  Created by kingkong999yhirose on 2016/12/23.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation

public enum PathComponent {
    case simple(String)
    case environmentPath(SourceTreeType.Environment, String)
    
    var string: String {
        get {
            switch self {
            case .simple(let path):
                return path
            case .environmentPath( _, let path):
                return path
            }
        }
    }
}
