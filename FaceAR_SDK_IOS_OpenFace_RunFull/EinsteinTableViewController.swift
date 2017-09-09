//
//  EinsteinTableViewController.swift
//  FaceDetect
//
//  Created by B Gay on 8/9/17.
//  Copyright © 2017 Simon Gladman. All rights reserved.
//

import UIKit

protocol EinsteinTableViewControllerDelegate: class
{
    func didSelect(_ einstein: Einstein)
}

class EinsteinTableViewController: UITableViewController
{
    var selectedEinstein: Einstein?
    weak var delegate: EinsteinTableViewControllerDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 52.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    @IBAction func didPressDone(_ sender: UIBarButtonItem)
    {
        dismiss(animated: true)
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Einstein.all.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(EinsteinTableViewCell.self)", for: indexPath) as! EinsteinTableViewCell
        cell.einstein = Einstein.all[indexPath.row]
        cell.accessoryType = selectedEinstein == cell.einstein ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let einstein = Einstein.all[indexPath.row]
        delegate?.didSelect(einstein)
        selectedEinstein = einstein
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        { [unowned self] in
            self.dismiss(animated: true)
        }
    }
}
