//
//  BusinessService.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import Foundation

struct BusinessService: NetworkService {
    
    func searchBusinesses(term: String, location: String, categories: String, sort: String, offset: Int, completion: @escaping (Result<BusinessSearchResult?, Error>) -> Void) {
        request(endpoint: YelpAPI.searchBusinesses(term: term, location: location, categories: categories, sort: sort, offset: offset)) { result in
            switch result {
            case .success(let data):
                let decodedResult: Result<BusinessSearchResult, DataDecoderError> = decode(data: data)
                switch decodedResult {
                case .success(let searchResult):
                    completion(.success(searchResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchBusinessDetail(id: String, completion: @escaping (Result<Business?, Error>) -> Void) {
        request(endpoint: YelpAPI.fetchBusinessDetail(id: id)) { result in
            switch result {
            case .success(let data):
                let decodedResult: Result<Business, DataDecoderError> = decode(data: data)
                switch decodedResult {
                case .success(let searchResult):
                    completion(.success(searchResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
