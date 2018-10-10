//
//  Errors.swift
//  Alamofire
//
//  Created by Thomas Sempf on 2018-10-10.
//

import Foundation

public enum YggdrasilError: Error {
    case invalidURL(url: String)
    case unknown
}
