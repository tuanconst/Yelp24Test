//
//  BusinessSearchController.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import UIKit
import RxSwift
import RxCocoa

class BusinessSearchController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    var searchDelegate: BusinessMainSearchDelegate?
    
    var searchViewModel: BusinessSearchViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //configureTableView()
        searchBar.delegate = self
        locationTextField.delegate = self
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    func bind() {
        guard let searchViewModel = searchViewModel else {
            return
        }
        if !searchViewModel.fetchedTerm.isEmpty {
            searchBar.text = searchViewModel.fetchedTerm
        }
        if !searchViewModel.fetchedLocation.isEmpty {
            locationTextField.text = searchViewModel.fetchedLocation
        }
        searchBar.rx.text
            .orEmpty
            .subscribe(onNext: { query in
                searchViewModel.term = query
            }).disposed(by: disposeBag)
        locationTextField.rx.text
            .orEmpty
            .subscribe(onNext: { query in
                searchViewModel.location = query
            }).disposed(by: disposeBag)
        sortSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { index in
                if index == 0 {
                    searchViewModel.sortBy = .distance
                }
                else {
                    searchViewModel.sortBy = .rating
                }
            }).disposed(by: disposeBag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BusinessSearchController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchViewModel = searchViewModel else {
            return
        }
        let term = searchViewModel.term.trimmingCharacters(in: .whitespaces)
        let location = searchViewModel.location.trimmingCharacters(in: .whitespaces)
        // Clear text then clear table view
        if term.isEmpty || location.isEmpty {
            //display alert
            return
        }
        guard let searchDelegate = searchDelegate else {
            return
        }
        searchDelegate.shouldPerformSearch(searchViewModel)
        searchBar.resignFirstResponder()
        self.dismiss(animated: true)
    }
}

extension BusinessSearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchViewModel = searchViewModel else {
            return false
        }
        let term = searchViewModel.term.trimmingCharacters(in: .whitespaces)
        let location = searchViewModel.location.trimmingCharacters(in: .whitespaces)
        // Clear text then clear table view
        if term.isEmpty || location.isEmpty {
            //display alert
            return false
        }
        guard let searchDelegate = searchDelegate else {
            return false
        }
        searchDelegate.shouldPerformSearch(searchViewModel)
        textField.resignFirstResponder()
        self.dismiss(animated: true)
        return true
    }
}
