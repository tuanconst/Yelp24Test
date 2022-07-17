//
//  BusinessSearchViewModel.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import Foundation
import RxCocoa

class BusinessSearchViewModel {
    
    var needShowError: ((BaseError) -> Void)?
    
    enum BusinessSearchSortBy {
        case distance
        case rating
        
        var queryValue: String {
            switch self {
            case .distance:
                return "distance"
            case .rating:
                return "rating"
            }
        }
    }
    
    let service: BusinessService
    //var businesses: [Business] = []
    
    var businessViewModels: BehaviorRelay<[BusinessViewModel]> = BehaviorRelay(value:[])
    
    var term = "chicken rice"
    var location = "Sentosa, Singapore"
    var sortBy: BusinessSearchSortBy = .distance
    
    var fetchedTerm = ""
    var fetchedLocation = ""
    var fetchedSortBy: BusinessSearchSortBy = .distance
    var fetchedOffset = 0
    var fetchedTotal = 0
    
    init() {
        service = BusinessService()
    }
    
    func requestBusinesses() {
        service.searchBusinesses(term: term, location: location, categories: "", sort: sortBy.queryValue, offset: 0) { [weak self] result in
            guard let searchViewModel = self else { return }
            switch result {
            case .success(let searchResult):
                guard let businesses = searchResult?.businesses else {
                    searchViewModel.needShowError?(DataDecoderError.parsing(NSError()))
                    return
                }
                searchViewModel.fetchedTerm = searchViewModel.term
                searchViewModel.fetchedLocation = searchViewModel.location
                businesses.forEach({
                    var businessViewModels = searchViewModel.businessViewModels.value
                    businessViewModels.append(BusinessViewModel($0))
                    searchViewModel.businessViewModels.accept(businessViewModels)
                })
            case .failure(let error):
                print("\(error)")
                guard let baseError = error as? BaseError else {
                    return
                }
                searchViewModel.needShowError?(baseError)
            }
        }
    }
    
    func requestMoreBusinesses() {
        service.searchBusinesses(term: fetchedTerm, location: fetchedLocation, categories: "", sort: "", offset: fetchedOffset) { [weak self] result in
            guard let searchViewModel = self else { return }
            switch result {
            case .success(let searchResult):
                // Save data to realm
                guard let businesses = searchResult?.businesses else {
                    return
                }
                
                businesses.forEach({
                    var businessViewModels = searchViewModel.businessViewModels.value
                    businessViewModels.append(BusinessViewModel($0))
                    searchViewModel.businessViewModels.accept(businessViewModels)
                })
            case .failure(let error):
                print("\(error)")
                guard let baseError = error as? BaseError else {
                    return
                }
                searchViewModel.needShowError?(baseError)
            }
        }
    }
    
}
