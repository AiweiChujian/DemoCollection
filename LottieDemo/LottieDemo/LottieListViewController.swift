//
//  LottieListViewController.swift
//  LottieDemo
//
//  Created by Aiwei on 2023/2/21.
//

import UIKit

class LottieListViewController: UITableViewController {
    
    private let reuseIdentifier = "reuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private lazy var lottieFileNames: [String] = ["tab-mine", "tab-msg", "mine", "red_packet", "red_packet_vip", "playlist", "refresh"]

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lottieFileNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = lottieFileNames[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LottieDetail") as? LottieDetailViewController else {
            return
        }
        vc.lottieFileName = lottieFileNames[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}
