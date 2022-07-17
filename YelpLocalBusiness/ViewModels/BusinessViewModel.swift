//
//  BusinessViewModel.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import UIKit

class BusinessViewModel {
    
    enum openNow {
        case opened
        case closed
        case unknown
        
        var displayString: String {
            switch self {
            case .opened:
                return "Opened"
            case .closed:
                return "Closed"
            case .unknown:
                return ""
            }
        }
        
        var displayColor: UIColor {
            switch self {
            case .opened:
                return .green
            case .closed:
                return .red
            case .unknown:
                return .black
            }
        }
    }
    
    private let service: BusinessService
    private var business: Business
    
    var id: String {
        get {
            guard let id = business.id else {
                return ""
            }
            return id
        }
    }
    var name: String {
        get {
            guard let name = business.name else {
                return ""
            }
            return name
        }
    }
    var imageURL: String {
        get {
            guard let imageURL = business.imageURL else {
                return ""
            }
            return imageURL
        }
    }
    var rating: Double {
        get {
            guard let rating = business.rating else {
                return 0.0
            }
            return rating
        }
    }
    var categories: [BusinessCategory] {
        get {
            guard let categories = business.categories else {
                return []
            }
            return categories
        }
    }
    var openNow: openNow {
        get {
            guard let hours = business.hours, let businessHours = hours.first else {
                return .unknown
            }
            return businessHours.isOpenNow ? .opened : .closed
        }
    }
    var displayAddress: String {
        get {
            guard let location = business.location, let displayAddress = location.displayAddress else {
                return ""
            }
            return displayAddress.joined(separator: ", ")
        }
    }
    
    init(_ business: Business) {
        self.business = business
        service = BusinessService()
    }
    
    typealias BusinessDetailCompletionHandler = (BusinessViewModel) -> Void
    
    func fetchBusinessDetail(completion: @escaping BusinessDetailCompletionHandler) {
        guard let id = business.id else {
            return
        }
        service.fetchBusinessDetail(id: id) { [weak self] result in
            guard let searchViewModel = self else { return }
            switch result {
            case .success(let business):
                guard let businessDetail = business else {
                    return
                }
                searchViewModel.business = businessDetail
                DispatchQueue.main.async {
                    completion(searchViewModel)
                }
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
    typealias ThumnailCompletionHandler = (UIImage) -> Void
    
    func fetchThumnail(_ targetSize: CGSize, completion: @escaping ThumnailCompletionHandler) {
        service.download(endpoint: ImageDownloadEndpoint(imagePath: imageURL)) { result in
            switch result {
            case .success(let downloadedData):
                guard let imageData = downloadedData else {
                    return
                }
                DispatchQueue.main.async {
                    guard let image = UIImage(data: imageData) else {
                        return
                    }
                    let size = image.size
                    let widthRatio = targetSize.width / size.width
                    let heightRatio = targetSize.height / size.height

                    var newSize: CGSize
                    if (widthRatio > heightRatio) {
                        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
                    } else {
                        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
                    }
                    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

                    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                    image.draw(in: rect)
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    completion(resizedImage)
                }
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
    
}

//extension UIImage {
//    func getImageRatio() -> CGFloat {
//        let imageRatio = CGFloat(self.size.width / self.size.height)
//        return imageRatio
//    }
//}
