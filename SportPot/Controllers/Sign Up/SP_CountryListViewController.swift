//
//  SP_CountryListViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 06/07/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit
import Alamofire

protocol CountryDelegate {
    func selectedCountry(country: Country)
}

struct ResponseData: Decodable {
    var country: [Country]
}
struct Country : Decodable {
    var name: String
    var dialCode: String
    var isoCode: String
    var flag: String
}

class SP_CountryListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countriesTableView: UITableView!
    
    var countries = [Country]()
    var filteredCountries = [Country]()
    var countryDelegate: CountryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
        countries = loadJson(filename: "countries") ?? [Country]()
        filteredCountries = countries
        countriesTableView.reloadData()
        
    }
    
    func loadJson(filename fileName: String) -> [Country]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode([Country].self, from: data)
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

extension SP_CountryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont.ubuntuRegularFont(ofSize: 14)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = filteredCountries[indexPath.row].dialCode + ": " + filteredCountries[indexPath.row].name
        cell.tag = indexPath.row
        /* TODO: Show country flags
        if let imageUrl = URL(string: countries[indexPath.row].flag) {
            if(cell.tag == indexPath.row) {
                Alamofire.request(imageUrl).response { response in
                    if let data = response.data {
                        let image = UIImage(data: data)
                        cell.imageView?.image = image
                    } else {
                        print("Data is nil. I don't know what to do :(")
                    }
                }
            }
        }
         */
            //
//            DispatchQueue.main.async {[weak self] in
//                self?.downloadLogo(url: imageUrl, forImageView: cell.imageView!)
//            }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.countryDelegate?.selectedCountry(country: self.filteredCountries[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
    func  updateSearchResultsForSearchController(searchBar: UISearchBar) {
        if let searchText = searchBar.text?.lowercased() {
            if searchText.count == 0 {
                filteredCountries = countries
            }
            else {
                filteredCountries = countries.filter {
                    return $0.name.lowercased().contains(searchText) ||
                        $0.dialCode.lowercased().contains(searchText)
                }
            }
        }
        self.countriesTableView.reloadData()
    }
}
extension SP_CountryListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResultsForSearchController(searchBar: searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}
