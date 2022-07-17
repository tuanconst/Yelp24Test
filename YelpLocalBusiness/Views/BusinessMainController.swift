//
//  MainBusinessController.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import UIKit
import RxSwift
import RxCocoa

protocol BusinessMainSearchDelegate {
    
    func shouldPerformSearch(_ searchModel: BusinessSearchViewModel)
}

class BusinessMainController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchViewModel = BusinessSearchViewModel()
    var selectedBusinessViewModel: BusinessViewModel?
    
    private let disposeBag = DisposeBag()
    
    private var firstDisplay = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureTableView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstDisplay {
            firstDisplay = false
            performSegue(withIdentifier: "OpenSearch", sender: self)
        }
    }
    
    private func configureTableView() {
        let nib = UINib(nibName: BusinessSearchResultCell.Identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BusinessSearchResultCell.Identifier)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        //tableView.rowHeight = 90
    }
    
    func bind() {
        searchViewModel.needShowError = { [weak self] error in
            self?.showError(error: error)
            //self?.topIndicatorView.stopAnimating()
            //self?.topIndicatorView.isHidden = true
        }
        searchViewModel.businessViewModels.asObservable()
                .bind(to: tableView.rx.items(cellIdentifier: BusinessSearchResultCell.Identifier, cellType: BusinessSearchResultCell.self))
        { index, businessViewModel, cell in
            cell.businessViewModel = businessViewModel
            businessViewModel.fetchThumnail(cell.thumnailImageView.frame.size) { image in
                guard cell.businessViewModel?.imageURL == businessViewModel.imageURL else {
                    return
                }
                cell.thumnailImageView.image = image
            }
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(BusinessViewModel.self).subscribe(onNext: { businessViewModel in
            self.selectedBusinessViewModel = businessViewModel
            self.performSegue(withIdentifier: "ShowDetail", sender: self)
        }).disposed(by: disposeBag)
    }
    
    @IBAction func openSearch(button: UIButton) {
        performSegue(withIdentifier: "OpenSearch", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier, identifier == "OpenSearch",
              let controller = segue.destination as? BusinessSearchController {
            controller.searchViewModel = self.searchViewModel
            controller.searchDelegate = self
        }
        else if let identifier = segue.identifier, identifier == "ShowDetail",
              let controller = segue.destination as? BusinessDetailController, let businessViewModel = selectedBusinessViewModel {
            controller.businessViewModel = businessViewModel
            self.selectedBusinessViewModel = nil
        }
    }
    

}

extension BusinessMainController: BusinessMainSearchDelegate {
    func shouldPerformSearch(_ searchModel: BusinessSearchViewModel) {
        searchBar.text = String("\(searchViewModel.term) at \(searchViewModel.location)")
        searchViewModel.requestBusinesses()
    }
}

extension UIViewController {
    
    func showError(error: BaseError) {
        let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
