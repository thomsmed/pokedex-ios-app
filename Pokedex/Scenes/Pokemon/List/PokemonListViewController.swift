//
//  MasterViewController.swift
//  pokedex
//
//  Created by Thomas A. Smedmann on 04/09/2019.
//  Copyright © 2019 Thomas A. Smedmann. All rights reserved.
//

import UIKit
import Resolver

class PokemonListViewController: UITableViewController, UITableViewDataSourcePrefetching {

    @Injected var pokeApiClient: ApiClient

    var objects = [Any]()
    var pokemon = [PokemonPageItem]()
    var count = 0
    var offset = 0
    let limit = 50
    let resource = "pokemon"
    var fetchInProgress = false

    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Blanking out the back-button text
        self.navigationItem.backBarButtonItem = UIBarButtonItem()

        self.tableView.prefetchDataSource = self

        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(fetchInitialPokemon), for: .valueChanged)

        self.refreshControl!.beginRefreshing()
        self.fetchInitialPokemon()
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

        let selectedPokemon = pokemon[indexPath.row]
        pokemonDetailViewController.pokemon = selectedPokemon
    }

    // MARK: - Refresh Control
    @objc
    private func fetchInitialPokemon() {
        if self.fetchInProgress {
            return
        }

        self.fetchInProgress = true
        self.offset = 0
        let params = ["offset": "\(self.offset)", "limit": "\(self.limit)"]

        pokeApiClient.requestResouce(self.resource,
                                     withParams: params,
                                     completionHandler: { (result: PokemonPage?, _: Error?) -> Void in
            if let result = result {
                self.pokemon = result.results ?? [PokemonPageItem]()
                self.offset += self.limit
                self.count = result.count

                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
            }

            self.fetchInProgress = false
        })
    }

    // MARK: - Infinity Scroll
    private func fetchPokemon() {
        if self.fetchInProgress {
            return
        }

        if self.offset >= self.count {
            return
        }

        self.fetchInProgress = true
        let params = ["offset": "\(self.offset)", "limit": "\(self.limit)"]

        pokeApiClient.requestResouce(self.resource,
                                     withParams: params,
                                     completionHandler: { (result: PokemonPage?, _: Error?) -> Void in
            if let result = result {
                self.pokemon.append(contentsOf: result.results ?? [PokemonPageItem]())
                self.offset += self.limit

                DispatchQueue.main.async {
                    let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows ?? []
                    if let firstIndexPath = indexPathsForVisibleRows.first,
                        let lastIndexPath = indexPathsForVisibleRows.last {
                        if firstIndexPath.row > self.offset - self.limit || lastIndexPath.row < self.offset {
                                self.tableView.reloadData()
                        }
                    }
                }
            }

            self.fetchInProgress = false
        })
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row > self.pokemon.count {
            self.fetchPokemon()
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if indexPath.row >= self.pokemon.count {
            cell.textLabel!.text = "..."
        } else {
            let pokemon = self.pokemon[indexPath.row]
            cell.textLabel!.text = pokemon.name
        }

        return cell
    }

}
