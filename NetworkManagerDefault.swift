//
//  APIManager.swift
//  VimeoPlayerSample
//
//  Created by IC-MAC004 on 10/7/21.
//


//import Alamofire
//import SwiftUI
import UIKit

struct NetworkManagerDefault {
    
    static let shared = NetworkManagerDefault()
    private init () { }
    
    func createRequest(apiStr: Enum_ApisMethods, method: Enum_HTTPMethods, params: [String: Any]?, headerContentType: Enum_HeaderContentTypes = .applicationjson,  isShowLoader: Bool = true, onCompletion: @escaping(_ data: Data?, _ failureMessage: String?)->Void) {
        
        if ReachabilityTest.isConnectedToNetwork() == false {
            
            NetworkAlertController.showAlertControllerForNetwork()
            return
        }
        
        if isShowLoader {
            //            SKActivityCustom.shared.showLoader(text: "Loading...")
        }
        
        let finalURLStr = Domains().getBaseURL() + apiStr.rawValue
        
        guard let url = URL(string: finalURLStr) else {
            print("API Error")
            onCompletion(nil, "API Error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(headerContentType.rawValue, forHTTPHeaderField: ContentType)
        
        if let parameters = params {
            if headerContentType == .applicationjson {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }else  {
                request.httpBody = getFormDataPostString(params: parameters).data(using: .utf8)
                request.addValue("Bearer \(AccessToken)", forHTTPHeaderField: Authentication)
            }
            
        }
        
        
//        request.setValue(headerContentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 600
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
//            SKActivityCustom.shared.hideLoader()
            
            if let err = error {
                print(err)
                onCompletion(nil, "\(err)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data else {
                print("error: not a valid http response")
                onCompletion(nil, "error: not a valid http response")
                return
            }
            
            switch httpResponse.statusCode {
            
            case 200..<300:
                print("SUCCESS")
                print(receivedData)
//                print(httpResponse)
//                print(String(data: receivedData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
                onCompletion(receivedData, nil)
                
            default:
                print("\(apiStr.rawValue):-  request got response \(httpResponse.statusCode)")
                onCompletion(nil, "\(httpResponse.statusCode)")
            
            }
            
        }.resume()
        
    }
    
    
    func getFormDataPostString(params:[String:Any]) -> String {
        var components = URLComponents()
        
        components.queryItems = params.keys.compactMap {
            URLQueryItem(name: $0, value: params[$0] as? String)
            
        }
        
        return components.query ?? ""
        
    }
    
}




////MARK:- Internet check
//class Connectivity {
//    class func isConnectedToInternet() ->Bool {
//        return NetworkReachabilityManager()!.isReachable
//    }
//}

class AlertController {
    static func msg(message: String, title: String = "") {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(alertView, animated: true, completion: nil)

//        UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
    }
}

struct NetworkAlertController {

    static func showAlertControllerForNetwork(title: String = "Internet Connection", message: String = "Please check your Internet Connection", actionTitle: String = "Try Again") {

        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { (action) in

            if ReachabilityTest.isConnectedToNetwork() == false {
             
                UIWindow.key?.rootViewController?.present(alertView, animated: true, completion: nil)
            }

        }
        alertView.addAction(action)
        UIWindow.key?.rootViewController?.present(alertView, animated: true, completion: nil)
//        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(alertView, animated: true, completion: nil)

    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

// application/x-www-form-urlencoded
// multipart/form-data

//MARK:- Headers

let ContentType = "Content-Type"
let Authorization = "Authorization"
let Authentication = "Authentication"
var AccessToken = ""

//func CustomHeaders(ContentType contentType: Enum_HeaderContentTypes = Enum_HeaderContentTypes.applicationjson) -> HTTPHeaders {
//
//    return [ContentType : contentType.rawValue,
//            Authorization:"Bearer \(AccessToken)"]
//}

enum Enum_HeaderContentTypes: String {
    
    /// application/json
    case applicationjson = "application/json"
    
    /// multipart/form-data
    case multiPartFormData = "multipart/form-data"
    
    /// application/x-www-form-urlencoded
    case formurlencoded = "application/x-www-form-urlencoded"
    
}

enum Enum_HTTPMethods: String {

    case get = "GET"
    case post = "POST"
}


//MARK:- Check Internet

import Foundation
import SystemConfiguration

public class ReachabilityTest {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
 
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
 
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
 
    }
    
}
