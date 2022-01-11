//
//  APIs.swift
//  SwiftUISample
//
//  Created by IC-MAC004 on 2/16/21.
//

import Foundation



struct Domains {
    
    let live = "https://reqres.in/api/" //"https://jsonplaceholder.typicode.com/"
    let testing = ""
    
    func getBaseURL() -> String {
        return live
    }
}

enum Enum_ApisMethods: String {
    case getUsers = "users"
    case login = "login"
    case register = "register"
}

// https://reqres.in/api/users?page=2
