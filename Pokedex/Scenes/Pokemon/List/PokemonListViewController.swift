//
//  MasterViewController.swift
//  Pokedex
//
//  Created by Thomas A. Smedmann on 04/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import UIKit
import Resolver

class PokemonListViewController: UITableViewController, UITableViewDataSourcePrefetching {

    @Injected var pokedex: Pokedex

    var items: [PokedexPageItem] = []
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
        pokemonDetailViewController.pokedexPageItem = selectedPokemon
    }

    // MARK: - Refresh Control
    @objc
    private func fetchInitialPokemon() {
        if fetchInProgress {
            return
        }

        fetchInProgress = true

        pokedex.page(number: 1, completionHandler: { (pokedexPage: PokedexPage?) -> Void in
            self.totalItemsCount = pokedexPage?.totalItemsCount ?? 0
            self.pageNumber = (pokedexPage?.number ?? 1) + 1
            self.noMoreToLoad = pokedexPage?.number == pokedexPage?.totalPagesCount

            if let items = pokedexPage?.items {
                self.items = items
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

        pokedex.page(number: pageNumber, completionHandler: { (pokedexPage: PokedexPage?) -> Void in
            self.pageNumber = (pokedexPage?.number ?? 1) + 1
            self.noMoreToLoad = pokedexPage?.number == pokedexPage?.totalItemsCount

            if let items = pokedexPage?.items {
                let currentCount = self.items.count
                self.items.append(contentsOf: items)

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

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row > items.count {
            self.fetchPokemon()
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalItemsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if indexPath.row >= items.count {
            cell.textLabel?.text = "..."
            cell.detailTextLabel?.text = ""
            cell.imageView?.image = UIImage()
        } else {
            let pokemon = items[indexPath.row]
            cell.textLabel?.text = pokemon.name
            cell.detailTextLabel?.text = "Nr.: \(pokemon.number)"
            cell.imageView?.image = pokemon.image
        }

        return cell
    }

}
