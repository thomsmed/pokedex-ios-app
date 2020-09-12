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
    var isFullyLoaded: Bool = false
}

class PokemonListViewController: UITableViewController {
    @Injected var pokedex: Pokedex

    var fetchPokedexPageTask: PokedexFetchTask?
    var fetchPokemonTasks: [PokedexFetchTask] = []

    let maxFetchTasks = 20

    let maxCachedItemsCount = 100
    var items: [PokemonListItem] = []
    var firstItemIndex = 0
    var lastItemIndex = 0
    var itemsPerPageCount = 0
    var totalItemsCount = 0
    var fetchingPage: Int?

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

        let index = indexPath.row - firstItemIndex
        let selectedPokemon = items[index]
        pokemonDetailViewController.pokemonListItem = selectedPokemon
    }

    // MARK: - Refresh Control
    @objc
    private func fetchInitialPokemon() {
        if fetchingPage == 1 {
            return
        }
        fetchPokedexPageTask?.cancel()
        fetchingPage = 1

        fetchPokedexPageTask = pokedex.fetchPage(1, completionHandler: { (result: Result<PokedexPage, Error>) -> Void in
            switch result {
            case .failure(let error):
                let nserror = error as NSError
                if nserror.code != NSURLErrorCancelled {
                    print(error)
                }
            case .success(let pokedexPage):
                self.itemsPerPageCount = pokedexPage.items.count
                self.totalItemsCount = pokedexPage.totalItemsCount
                self.items = pokedexPage.items.map({ item in PokemonListItem(number: item.number, name: item.name)})
                self.lastItemIndex = self.items.count - 1
                self.tableView.reloadData()
            }

            self.refreshControl?.endRefreshing()

            self.fetchingPage = nil
        })
    }

    private func fetchPokedexPage(_ page: Int) {
        if fetchingPage == page {
            return
        }
        fetchPokedexPageTask?.cancel()
        fetchingPage = page

        fetchPokedexPageTask = pokedex.fetchPage(page, completionHandler: { (result: Result<PokedexPage, Error>) in
            switch result {
            case .failure(let error):
                let nserror = error as NSError
                if nserror.code != NSURLErrorCancelled {
                    print(error)
                }
            case .success(let pokedexPage):
                self.handleFetchedPokedexPage(pokedexPage)
            }

            self.fetchingPage = nil
        })
    }

    private func handleFetchedPokedexPage(_ pokedexPage: PokedexPage) {
        let newItems = pokedexPage.items.map({ item in
            PokemonListItem(number: item.number, name: item.name)
        })

        let firstPageItemIndex = (pokedexPage.number - 1) * self.itemsPerPageCount
        let lastPageItemIndex = firstPageItemIndex + pokedexPage.items.count - 1
        if firstPageItemIndex > self.lastItemIndex {
            if firstPageItemIndex - self.lastItemIndex > 1 {
                self.items = newItems
            } else if self.items.count >= self.maxCachedItemsCount {
                self.items.append(contentsOf: newItems)
                self.items.removeFirst(pokedexPage.items.count)
            } else {
                self.items.append(contentsOf: newItems)
            }
            self.lastItemIndex = lastPageItemIndex
            self.firstItemIndex = lastPageItemIndex - self.items.count + 1
        } else {
            if self.firstItemIndex - lastPageItemIndex > 1 {
                self.items = newItems
            } else if self.items.count >= self.maxCachedItemsCount {
                self.items.insert(contentsOf: newItems, at: 0)
                self.items.removeLast(pokedexPage.items.count)
            } else {
                self.items.insert(contentsOf: newItems, at: 0)
            }
            self.firstItemIndex = firstPageItemIndex
            self.lastItemIndex = firstPageItemIndex + self.items.count - 1
        }

        let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows ?? []
        if let firstVisibleIndexPath = indexPathsForVisibleRows.first,
           let lastVisibleIndexPath = indexPathsForVisibleRows.last {
            if firstVisibleIndexPath.row < lastPageItemIndex && lastVisibleIndexPath.row > firstPageItemIndex {
                self.tableView.reloadData()
            }
        }
    }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if indexPath.row < firstItemIndex || indexPath.row > lastItemIndex {
            cell.textLabel?.text = "..."
            cell.detailTextLabel?.text = ""
            cell.imageView?.image = UIImage()
        } else {
            let index = indexPath.row - firstItemIndex
            var pokemonListItem = items[index]
            var name = pokemonListItem.name
            cell.textLabel?.text = name.removeFirst().uppercased() + name
            cell.detailTextLabel?.text = "Nr.: \(pokemonListItem.number)" + (
                pokemonListItem.type != nil ? ", Type: \(pokemonListItem.type)" : ""
            )
            if let image = pokemonListItem.image {
                if let data = try? Data(contentsOf: URL(string: image)!) {
                    cell.imageView?.image = UIImage(data: data)
                }
            }

//            if false {
            if !pokemonListItem.isFullyLoaded {
                pokemonListItem.isFullyLoaded = true
                items[index] = pokemonListItem
                fetchPokemon(pokemonListItem.name)
            }
        }

        return cell
    }

    private func fetchPokemon(_ pokemonName: String) {
        let fetchTask = self.pokedex.fetchPokemon(pokemonName,
                                                  completionHandler: { (result: Result<Pokemon, Error>) in
            switch result {
            case .failure(let error):
                let nserror = error as NSError
                if nserror.code != NSURLErrorCancelled {
                    print(error)
                }
            case .success(let pokemon):
                let itemIndex = pokemon.number - 1
                let index = itemIndex - self.firstItemIndex

                guard index > -1 && index < self.items.count else { return }

                var pokemonListItem = self.items[index]
                pokemonListItem.image = pokemon.image
                pokemonListItem.type = pokemon.type

                self.items[index] = pokemonListItem

                UIView.performWithoutAnimation {
                    let cof = self.tableView.contentOffset
                    self.tableView.reloadRows(at: [IndexPath(row: itemIndex, section: 0)], with: .none)
                    self.tableView.contentOffset = cof
                }
            }
        })

        self.fetchPokemonTasks.append(fetchTask)
        if self.fetchPokemonTasks.count > self.maxFetchTasks {
            self.fetchPokemonTasks.removeFirst().cancel()
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension PokemonListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last else { return }

        let indexToLoad = lastIndexPath.row
        if indexToLoad > lastItemIndex || indexToLoad < firstItemIndex {
            let pageToLoad = indexToLoad / itemsPerPageCount + 1
            fetchPokedexPage(pageToLoad)
        }
    }
}
