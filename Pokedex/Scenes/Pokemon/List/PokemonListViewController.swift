//
//  MasterViewController.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 04/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import UIKit
import Resolver

struct PokemonListItem {
    let number: Int
    var name: String
    var type: PokemonType?
    var image: String?
    var hasFullyLoaded: Bool = false
}

class PokemonListViewController: UITableViewController {
    @Injected var pokedex: Pokedex

    var items: [PokemonListItem] = []
    var pageNumber = 1
    var totalItemsCount = 0
    var fetchInProgress = false
    var noMoreToLoad = false

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Blanking out the back-button text
        navigationItem.backBarButtonItem = UIBarButtonItem()

        tableView.prefetchDataSource = self

        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(fetchInitialPokemon), for: .valueChanged)

        refreshControl!.beginRefreshing()
        fetchInitialPokemon()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? true
        super.viewWillAppear(animated)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail", let indexPath = tableView.indexPathForSelectedRow else {
            return
        }

        guard let navigationController = segue.destination as? UINavigationController,
            let pokemonDetailViewController = navigationController.topViewController
                as? PokemonDetailViewController else {
            return
        }

        let selectedPokemon = items[indexPath.row]
        pokemonDetailViewController.pokemonListItem = selectedPokemon
    }

    // MARK: - Refresh Control
    @objc
    private func fetchInitialPokemon() {
        if fetchInProgress {
            return
        }
        fetchInProgress = true

        pokedex.page(number: 1, completionHandler: { (pokedexPage: PokedexPage?, _: Error?) -> Void in
            self.totalItemsCount = pokedexPage?.totalItemsCount ?? 0
            self.pageNumber = (pokedexPage?.number ?? 1) + 1
            self.noMoreToLoad = pokedexPage?.number == pokedexPage?.totalPagesCount

            if let items = pokedexPage?.items {
                self.items = items.map({ item in PokemonListItem(number: item.number, name: item.name)})
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()

            self.fetchInProgress = false
        })
    }

    // MARK: - Infinity Scroll
    private func fetchPokemon() {
        if fetchInProgress || noMoreToLoad {
            return
        }
        fetchInProgress = true

        pokedex.page(number: pageNumber, completionHandler: { (pokedexPage: PokedexPage?, _: Error?) -> Void in
            self.pageNumber = (pokedexPage?.number ?? 1) + 1
            self.noMoreToLoad = pokedexPage?.number == pokedexPage?.totalItemsCount

            if let items = pokedexPage?.items {
                let currentCount = self.items.count
                self.items.append(contentsOf: items.map({ item in PokemonListItem(number: item.number, name: item.name)}))

                let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows ?? []
                if let firstIndexPath = indexPathsForVisibleRows.first,
                    let lastIndexPath = indexPathsForVisibleRows.last {
                    if firstIndexPath.row > currentCount || lastIndexPath.row < items.count {
                        self.tableView.reloadData()
                    }
                }
            }

            self.fetchInProgress = false
        })
    }
    
//    private func populateVisiblePokemon() {
//        tableView.visibleCells.forEach({ (cell: UITableViewCell) in
//            guard let cell = cell as? PokemonTableViewCell else {
//                return
//            }
//
//            self.pokedex.pokemon(number: cell.number, completionHandler: {[weak cell] (pokemon: Pokemon?, error: Error?) in
//                guard let pokemon = pokemon else {
//                    return
//                }
//
//                guard let cell = cell, cell.number == pokemon.number else {
//                    return
//                }
//
//                cell.textLabel?.text = (cell.textLabel?.text ?? "") + "(Nr: \(pokemon.number))"
//            })
//        })
//    }
}

// MARK: - UIScrollViewDelegate
extension PokemonListViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    }
}

// MARK: - UITableViewDelegate
extension PokemonListViewController {

}

// MARK: - UITableViewDataSource
extension PokemonListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalItemsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PokemonTableViewCell else {
            return UITableViewCell()
        }

//        cell.number = indexPath.row + 1
        
        if indexPath.row >= items.count {
            cell.textLabel?.text = "..."
            cell.detailTextLabel?.text = ""
            cell.imageView?.image = UIImage()
        } else {
            var pokedexPageItem = items[indexPath.row]
            cell.textLabel?.text = pokedexPageItem.name
            cell.detailTextLabel?.text = "Nr.: \(pokedexPageItem.number)"
            
            if !pokedexPageItem.hasFullyLoaded {
                pokedexPageItem.hasFullyLoaded = true
                items[indexPath.row] = pokedexPageItem
                pokedex.pokemon(number: pokedexPageItem.number, completionHandler: {(pokemon: Pokemon?, error: Error?) in
                    var pokedexPageItem = self.items[indexPath.row]
                    
                    if let pokemon = pokemon {
                        pokedexPageItem.name += " (Nr: \(pokemon.number))"
                        pokedexPageItem.image = pokemon.image
                        
                        self.items[indexPath.row] = pokedexPageItem
                        self.tableView.reloadRows(at: [IndexPath(row: pokemon.number - 1, section: 0)], with: .fade)
                    } else {
                        pokedexPageItem.hasFullyLoaded = false
                        self.items[indexPath.row] = pokedexPageItem
                    }

                })
            }
        }

        return cell
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension PokemonListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row > items.count {
            self.fetchPokemon()
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // TODO?
    }
}
