//
//  NetworkManager.swift
//  SwiftUISample
//
//  Created by IC-MAC004 on 2/15/21.
//

import Foundation
import Alamofire
//import SwiftUI
import UIKit

struct NetworkManager {
    
    static let shared = NetworkManager()
    private init () { }
    
    func createRequest(apiStr: Enum_ApisMethods, method: HTTPMethod, params: [String: Any]?, headersArray: [Enum_HeaderContentType]?, isShowLoader: Bool = true, onCompletion: @escaping (_ successResponse: AFDataResponse<Any>?, _ failureResponseString: String?)->Void) {
        
        if Connectivity.isConnectedToInternet() == false {
            
            NetworkAlertController.showAlertControllerForNetwork(title: "Internet Connection", message: "Please check your Internet Connection", actionTitle: "Try Again")
            return
        }
        
        if isShowLoader {
//            SKActivityCustom.shared.showLoader(text: "Loading...")
        }
        
        let finalAPI = Domains().getBaseURL() + apiStr.rawValue
        var headerDict: HTTPHeaders = [ : ]
        
        if let header_array = headersArray {
            for header in header_array {
                let dict = header.getHeaderDict(type: header)
                for (key, value) in dict {
                    headerDict.add(HTTPHeader(name: key, value: value))
                }
            }
        }
        
        
//        print(finalAPI)
//        print(params ?? ["":""])
//        print(headerDict)
        
        // AF.request("", method: .post, parameters: [:], headers: nil, interceptor: nil, requestModifier: { $0.timeoutInterval = 600 })
        // AF.request(finalAPI, method: method, parameters: params, headers: headerDict)
        
        AF.request(finalAPI, method: method, parameters: params, headers: headerDict).responseJSON { serviceResponse in
                        
            var statusCode = 0
            if let code = serviceResponse.response?.statusCode {
                statusCode = code
            }
                                                
            if let error = serviceResponse.error {
                
                switch error {
                
                case .invalidURL(url: let url):
                    print("Invalid URL ->", url)
                    break
                case .parameterEncodingFailed(let reason):
                    print("Parameter encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .multipartEncodingFailed(let reason):
                    print("Multipart encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .responseValidationFailed(let reason):
                    print("Response validation failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    
                    switch reason {
                    case .dataFileNil, .dataFileReadFailed:
                        print("Downloaded file could not be read")
                    case .missingContentType(let acceptableContentTypes):
                        print("Content Type Missing: \(acceptableContentTypes)")
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                    case .unacceptableStatusCode(let code):
                        print("Response status code was unacceptable: \(code)")
                    case .customValidationFailed(error: let error):
                        print("Error: \(error)")
                    }
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                // statusCode = 3840 ???? maybe..
                default:break
                }
                
                onCompletion(nil, error.localizedDescription)
                
            }
            
            
            if let value = serviceResponse.value as? NSDictionary {
                if let errorDescription = value["error_description"] as? String {
                    onCompletion(nil, errorDescription)
                }else {
                    
                    switch statusCode {
                    
                    case 200..<300:
//                        print("Success")
                        onCompletion(serviceResponse, nil)
                        break
                        
                    case 400..<402:
                        
                        if let message = value["Message"] as? String {
                            onCompletion(nil, message)
                        }else {
                            onCompletion(nil, "Bad Request")
                        }
                        
                    default:
                        print("Default")
                        onCompletion(nil, serviceResponse.error?.localizedDescription)
                    }
                }
            }
            
//            SKActivityCustom.shared.hideLoader()
        }
        
    }
    
    /**
        Usage:
        
        var params = ["user_id": user_Defaults.value(forKey: Enum_UserData.user_id.rawValue)!,
                      "first_name": self.TF_firstName.text!,
                      "last_name": self.TF_lastName.text!,
                      "date_of_birth": self.TF_dob.text!,
                      "gender": self.TF_gender.text!.lowercased(),
                      "email": self.TF_email.text!,
                      "mobile": self.TF_mobile.text!,
                      "address": self.TF_address.text!,
                      "device_type": "ios",
                      "device_token": Custom_UDID.get_UDID()]
        
        
        if let profileChageImage = self.profileImage {
            
            params.updateValue([Enum_mimeTypes.image.rawValue:[ImageNameWithURL(name: user_Defaults.value(forKey: Enum_UserData.first_name.rawValue)! as! String, image: profileChageImage, videoURL: nil, type: .jpg, key: "user_image")]], forKey: Enum_mimeTypes.image.rawValue)
        }
     
     (OR)
     
     var params = [String: Any]()
     params.updateValue([Enum_mimeTypes.video.rawValue: [ImageNameWithURL(name: "Mahesh", image: nil, videoURL: self.urlPath, type: .mov, key: "file")]], forKey: Enum_mimeTypes.video.rawValue)
        
        */
    
    
    func createRequest_FormData(apiStr: Enum_ApisMethods, method: HTTPMethod, parameters: [String: Any]?, headersArray: [Enum_HeaderContentType]?, isShowLoader: Bool = true, onCompletion: @escaping (_ successResponse: AFDataResponse<Any>?, _ failureResponseString: String?)->Void) {
        
        if Connectivity.isConnectedToInternet() == false {
            
            NetworkAlertController.showAlertControllerForNetwork(title: "Internet Connection", message: "Please check your Internet Connection", actionTitle: "Try Again")
            return
        }
        
        if isShowLoader {
            //            SKActivityCustom.shared.showLoader(text: "Loading...")
        }
        
        // http://10.10.45.52/DaCastUploadVideoFile/api/PriceTrackerIPCApproval/DaCastUploadVideoFile
        //  Domains().getBaseURL() + apiStr.rawValue
        
        guard let finalAPI = URL(string: "http://10.10.45.52/DaCastUploadVideoFile/api/PriceTrackerIPCApproval/DaCastUploadVideoFile") else {
            onCompletion(nil, "Invalid API")
            return
        }
        let parameters: [String:Any] = parameters ?? [:]
//        let httpHeaders = HTTPHeaders(dictionaryLiteral: ("api_key", ""))
        
        var headerDict: HTTPHeaders = [ : ]
        
        if let header_array = headersArray {
            for header in header_array {
                let dict = header.getHeaderDict(type: header)
                for (key, value) in dict {
                    headerDict.add(HTTPHeader(name: key, value: value))
                }
            }
        }
//        let headers = CustomHeaders(ContentType: .multiPartFormData)
        
        
        //        print(finalAPI)
        //        print(params ?? ["":""])
        //        print(headers)
                
        
        //             let headers: HTTPHeaders = ["Authorization":"Bearer hm0UVOF7KSMgTQBHxrpj9MC6KnN3JVoN3KDXSDoZ_u1ji2v91Fd90H0VWzCw6iEgillmw7nDU5qjbs9bK40o9kdJ9AH8cwcG6mMkwentwNax8bMOPqYd90Io6KE_knHfX8a3vD6ucqhlVtnoIqEV445usB-GkpBjWGI_PQos4I-2KGycRGv4YhuRqIQVUDowj5hc0NT44uv4f4bPa-Tes4fcAF2fiS8xO8ovnCbUwAO3tlj449x5Qc3Bhc-x734uceCxEDh6_5OV0A8QkaDobPdSES9UgzcCFGdF6CB0ckjJupyljBsJxTobrtnMlfn3RU_KyktqJgIjJBSzSDMfpaozK1ZaPiIu9GNZvvecSsLQdy3DtARCoZCLR6ku8kmBizz_Qu51ryRyAB992D0JmZIPIxLfqngaUs7SG_gfGkM_QRYV-bfDtU2f6W2z0dJgdZjFgyODI0gU4DD4umJAF3I62y-GWpOKM5joq_XRaEqIElZCxqETfT9ay7T5eKfWCFp9_FcC7es11EMlVGEKZ7YFsFzg_9bq_lRRcWRCS1cDXGYOwYOCFzyxOPnPDLipK_JH94qHKF_KwiDwAJS5XgEBbbynMffooKofUMNK1zDTxskayFgkpvdbpdqkha70CEAk5YRkA0fo3fLGgjDNIxiKx3XcO6biFhsHNw749Bg"]//user.value(forKey:"token") as! String]
        
        
        AF.upload(multipartFormData: { multipartFormData in
            
            
            // For Parameters
            for (key, value) in parameters {
                
                // For Images
                
                if key == Enum_mimeTypes.image.rawValue {
                    // parameters[Enum_mimeTypes.image.rawValue]
                    if let images_array = value as? [String: [ImageNameWithURL]] {
                                                    
                        if let finaleImages_array = images_array[key] {
                            
                            for image in finaleImages_array {

                                if let imgData = image.image!.jpegData(compressionQuality: Enum_JPEGQuality.high.rawValue) {
                                    multipartFormData.append(imgData, withName:image.key,fileName: image.name, mimeType: image.type?.rawValue)
                                }
                            }
                        }
                        
                    }
                }else if key == Enum_mimeTypes.video.rawValue {
                    
                    // For Videos
                    if let videos_array = value as? [String: [ImageNameWithURL]] {
                                                    
                        if let FinalVideos_array = videos_array[key] {
                            
                            for video in FinalVideos_array {

                                if let videoFilePath = video.videoURL {
                                    multipartFormData.append(videoFilePath, withName: video.key)
                                }
                            }
                        }
                        
                    }
                    
                }
                
                if let tagsArray = value as? [String] {
                    
                    for i in 0..<tagsArray.count {
                        
                        let value = tagsArray[i] //as! Int
                        let valueObj = String(value)
                        
                        let keyObj = key + "[" + String(i) + "]"
                        multipartFormData.append(valueObj.description.data(using: .utf8)!, withName: keyObj)
                        //                            multipartFormData.append(valueObj.data(using: .utf8)!, withName: keyObj)
                    }
                    
                }else if let stringValue = value as? String {
                    
                    multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                    
                }
                
                //                            multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        },to: finalAPI, method: .post , headers: headerDict)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { serviceResponse in
            
            var statusCode = 0
            if let code = serviceResponse.response?.statusCode {
                statusCode = code
            }
            
            if let error = serviceResponse.error {
                
                switch error {
                
                case .invalidURL(url: let url):
                    print("Invalid URL ->", url)
                    break
                case .parameterEncodingFailed(let reason):
                    print("Parameter encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .multipartEncodingFailed(let reason):
                    print("Multipart encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .responseValidationFailed(let reason):
                    print("Response validation failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                    
                    switch reason {
                    case .dataFileNil, .dataFileReadFailed:
                        print("Downloaded file could not be read")
                    case .missingContentType(let acceptableContentTypes):
                        print("Content Type Missing: \(acceptableContentTypes)")
                    case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                        print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                    case .unacceptableStatusCode(let code):
                        print("Response status code was unacceptable: \(code)")
                    case .customValidationFailed(error: let error):
                        print("Error: \(error)")
                    }
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                // statusCode = 3840 ???? maybe..
                default:break
                }
                
                onCompletion(nil, error.localizedDescription)
                
            }
            
            
            if let value = serviceResponse.value as? NSDictionary {
                if let errorDescription = value["error_description"] as? String {
                    onCompletion(nil, errorDescription)
                }else {
                    
                    switch statusCode {
                    
                    case 200..<300:
                        //                        print("Success")
                        onCompletion(serviceResponse, nil)
                        break
                        
                    case 400..<402:
                        
                        if let message = value["Message"] as? String {
                            onCompletion(nil, message)
                        }else {
                            onCompletion(nil, "Bad Request")
                        }
                        
                    default:
                        print("Default")
                        onCompletion(nil, serviceResponse.error?.localizedDescription)
                    }
                }
            }
            
            //            SKActivityCustom.shared.hideLoader()
        })
        
        
    }
}


//MARK:- Internet check
 
 
class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}



class AlertController {
    static func msg(message: String, title: String = "") {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(alertView, animated: true, completion: nil)

//        UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
    }
}

struct NetworkAlertController {

    static func showAlertControllerForNetwork(title: String = "", message: String, actionTitle: String) {
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { (action) in
            
            if Connectivity.isConnectedToInternet() == false {
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

var AccessToken = ""
 
enum Enum_HeaderContentType {

    /// application/json
    case applicationjson //= "application/json"

    /// multipart/form-data
    case multiPartFormData //= "multipart/form-data"

    /// application/x-www-form-urlencoded
    case formurlencoded //= "application/x-www-form-urlencoded"
    
    case authorizationWithBearer// = "Bearer"
    
    case apiKey(value: String)
    
    func getHeaderDict(type: Self) -> [String: String] {
        
        switch type {
        
        case .applicationjson: return ["Content-Type": "application/json"]
        case .multiPartFormData: return ["Content-Type": "multipart/form-data"]
        case .formurlencoded: return ["Content-Type": "application/x-www-form-urlencoded"]
        case .authorizationWithBearer: return ["Authorization": "Bearer \(AccessToken)"]
        case .apiKey(let value):  return ["api_key": value]
            
//        default:
//            return ["Content-Type": "application/json"]
        }
    }

}


 

//MARK:- Image Functionality

struct ImageNameWithURL {
    
    var name = String()
    var image: UIImage?
    var videoURL = URL(string: "")
    var type: Enum_mimeTypes?
    var key = String()
}

enum Enum_mimeTypes: String {
    
    case file = "file"
    case jpg = "image/jpeg"
    case png = "image/png"
    case mp4 = "video/mp4"
    case mov = "video/mov"
    
    // For Identify in api hitting function
    case image
    case video
}

extension Dictionary where Value: Equatable {
    func key(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

enum Enum_JPEGQuality: CGFloat {
    
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}
