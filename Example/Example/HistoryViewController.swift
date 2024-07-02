import UIKit
import Then
import SnapKit

class HistoryViewController: UITableViewController, UISearchBarDelegate {
    private var historyList: [URL] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private let searchController = UISearchController(searchResultsController: nil).then {
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.placeholder = "Search URLs"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        HistoryManager.shared.configureStorageType(.keychain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupNavigationBar()
        historyList = HistoryManager.shared.getHistory()
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllHistory))

        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    @objc func clearAllHistory() {
        HistoryManager.shared.clearHistory()
        historyList = HistoryManager.shared.getHistory()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let url = historyList[indexPath.row]
        cell.textLabel?.text = "\(url.absoluteString) (\(HistoryManager.shared.historyList[url] ?? 0))"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = historyList[indexPath.row]
        let webVC = ViewController()
        webVC.initialURL = url
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try HistoryManager.shared.deleteHistory(at: indexPath.row)
                historyList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Failed to delete history at index \(indexPath.row): \(error)")
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            historyList = HistoryManager.shared.getHistory()
        } else {
            historyList = HistoryManager.shared.searchHistory(keyword: searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        historyList = HistoryManager.shared.getHistory()
    }
}
