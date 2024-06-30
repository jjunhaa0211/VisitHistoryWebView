import UIKit
import VisitHistoryWebView

class HistoryViewController: UITableViewController {
    private var historyList: [URL] {
        return HistoryManager.shared.getHistory()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllHistory))
    }

    @objc func clearAllHistory() {
        HistoryManager.shared.clearHistory()
        tableView.reloadData()
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
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Failed to delete history at index \(indexPath.row): \(error)")
            }
        }
    }
}
