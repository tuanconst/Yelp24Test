//
//  NetworkService.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import Foundation

protocol BaseError: Error {
    var genericErrorMessage: String { get }
    var description: String { get }
}

extension BaseError {
    var genericErrorMessage: String {
        return "An error was occurred"
    }
}

enum NetworkError: Error, BaseError {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case badEndpoint
    case badData
    case generic(Error)
    
    var description: String {
        switch self {
        case .error(let statusCode, _):
            return "API returned with error code \(statusCode)"
        case .notConnected:
            return "Please check your connection again"
        case .cancelled:
            return genericErrorMessage
        case .badEndpoint:
            return genericErrorMessage
        case .badData:
            return genericErrorMessage
        case .generic:
            return genericErrorMessage
        }
    }
}

protocol NetworkRequest {
    var urlRequest: URLRequest? { get }
}

protocol NetworkService {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    var session: URLSession { get }
    func request(endpoint: NetworkEndpoint, completion: @escaping CompletionHandler)
    func decode<T: Decodable>(data: Data?) -> Result<T, DataDecoderError>
}

extension NetworkService {
    
    var session: URLSession {
        return URLSession.shared
    }
    
    func request(endpoint: NetworkEndpoint, completion: @escaping CompletionHandler) {
        guard let urlRequest = endpoint.urlRequest else {
            completion(.failure(.badEndpoint))
            return
        }
        session.dataTask(with: urlRequest) { data, response, requestError in
            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                completion(.failure(error))
            } else {
                completion(.success(data))
            }
        }.resume()
    }
    
    func decode<T: Decodable>(data: Data?) -> Result<T, DataDecoderError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result = try JSONDecoder().decode(T.self, from: data)
            return .success(result)
        } catch {
            return .failure(.parsing(error))
        }
    }
    
    func download(endpoint: NetworkEndpoint, completion: @escaping CompletionHandler) {
        guard let urlRequest = endpoint.urlRequest else {
            completion(.failure(.badEndpoint))
            return
        }
        session.dataTask(with: urlRequest) { data, response, requestError in
            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                completion(.failure(error))
            } else {
                completion(.success(data))
            }
        }.resume()
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

class ImageDownloadEndpoint: NetworkEndpoint {
    
    let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: "\(imagePath)") else {
            return nil
        }
        let urlRequest = URLRequest(url: url)
        return urlRequest
    }
    
}

enum DataDecoderError: Error, BaseError {
    case noResponse
    case parsing(Error)
    //case networkFailure(NetworkError)
    //case resolvedNetworkFailure(Error)
    
    var description: String {
        switch self {
        case .noResponse:
            return "Can not retrieve data"
        case .parsing:
            return genericErrorMessage
        }
    }
}

//class ResponseDecoder<T: Decodable> {
//    
//    func decode(_ data: Data) -> Result<T, DataDecoderError> {
//        do {
//            let result = try JSONDecoder().decode(T.self, from: data)
//            return .success(result)
//        } catch {
//            return .failure(.parsing(error))
//        }
//    }
//}
//
////protocol NetworkReponse {
////    var responseDecoder: ResponseDecoder<Decodable>? { get }
////}
//
//protocol DataDecoderService {
//    typealias CompletionHandler<T> = (Result<T, DataDecoderError>) -> Void
//
//    static func decode<T: Decodable>(data: Data, decoder: T) -> Result<T, DataDecoderError>
//}
//
//extension DataDecoderService {
//
//    static func decode<T: Decodable>(data: Data, decoder: T) -> Result<T, DataDecoderError> {
//        do {
//            let result = try JSONDecoder().decode(T.self, from: data)
//            return .success(result)
//        } catch {
//            return .failure(.parsing(error))
//        }
//    }
//}

protocol NetworkEndpoint: NetworkRequest {
}
