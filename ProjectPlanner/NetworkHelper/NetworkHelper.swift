//
//  NetworkHelper.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/9/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

private let baseUrl = "http://localhost:8090/"
public typealias RequestResponse = (Bool, Any?, Error?) -> Void

class NetworkHelper{
    
    static func getDataWithDomain(domain: String, completion: @escaping RequestResponse){
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        guard let url = URL.init(string: baseUrl+domain) else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return
        }
        
        requestWith(url: URLRequest.init(url: url), completion: completion)
    }
    
    static func postDataWithDomain(domain: String, parameters: String,completion: @escaping RequestResponse){
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        guard let url = URL.init(string: baseUrl+domain+"?"+parameters) else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return
        }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        requestWith(url: request, completion: completion)
    }
    
    static func deleteDataWithDomain(domain: String, parameters: String,completion: @escaping RequestResponse){
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        guard let url = URL.init(string: baseUrl+domain+"/"+parameters) else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return
        }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        requestWith(url: request, completion: completion)
    }
    
    static func requestWith(url: URLRequest, completion: @escaping RequestResponse){
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let code = (response as? HTTPURLResponse)?.statusCode , 200...299 ~= code{
                    completion(true, json, nil)
                }else{
                    completion(false, nil, error)
                }
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            }.resume()
    }
}
