//
//  YelpAPI.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import Foundation

class AppConfig {
    static let baseURL = "https://api.yelp.com/v3/"
    static let apiKey = ""
}

enum YelpAPI: NetworkEndpoint {
    
    case searchBusinesses(term: String, location: String, categories: String, sort: String, offset: Int)
    case fetchBusinessDetail(id: String)
    
    var baseURL: String {
        return AppConfig.baseURL
    }
    
    var path: String {
        switch self {
        case .searchBusinesses:
            return "businesses/search"
        case .fetchBusinessDetail(id: let id):
            return "businesses/\(id)"
        }
    }
    
    var parameters: [String: Any]? {
        var params: [String: Any] = [:]

        switch self {
        case .searchBusinesses(let term, let location, let categories, let sort, let offset):
            params["term"] = term
            params["location"] = location
            if (!categories.isEmpty) {
                params["categories"] = categories
            }
            if (!sort.isEmpty) {
                params["sort_by"] = sort
            }
            //params["offset"] = offset
        case .fetchBusinessDetail:
            print("nothing")
        }

        return params
    }
    
    var urlRequest: URLRequest? {
        /*
        guard let url = URL(string: "\(baseURL)\(path)") else {
            return nil
        }
        */
        /*
        switch self {
        case .searchBusinesses(let term, let location, let categories, let sort, let order, let offset):
            let params = BusinessSearchParametersEncodable(term: term, location: location)
        }
        */
        let endpoint = "\(baseURL)\(path)"
        var urlQueryItems = [URLQueryItem]()
        if let queryParameters = parameters {
            queryParameters.forEach {
                urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
           }
        }
        guard var urlComponents = URLComponents(string: endpoint) else {
            return nil
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        guard let url = urlComponents.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer \(AppConfig.apiKey)", forHTTPHeaderField: "Authorization")
        print("request \(urlRequest)")
        return urlRequest
    }
}
