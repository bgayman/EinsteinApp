//
//  FiltersTableViewController.swift
//  FaceDetect
//
//  Created by B Gay on 8/10/17.
//  Copyright © 2017 Simon Gladman. All rights reserved.
//

import UIKit

protocol FiltersTableViewControllerDelegate: class
{
    func didUpdate(selectedFilters: [CIFilter])
}

class FiltersTableViewController: UITableViewController
{
    weak var delegate: FiltersTableViewControllerDelegate?
    var selectedFilters = [CIFilter]()
    var images = [UIImage]()
    let eaglContext = EAGLContext(api: .openGLES2)!
    lazy var ciContext: CIContext =
    {
        return  CIContext(eaglContext: self.eaglContext)
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Filters"
        navigationItem.rightBarButtonItem = (traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular) ? nil : navigationItem.rightBarButtonItem
        let mlisa = CIImage(image: #imageLiteral(resourceName: "monalisa"))!
        images = CIFilter.possibleFilters.map {
            let ciImage = CIFilter.apply($0, to: mlisa)
            let cgImage = self.ciContext.createCGImage(ciImage, from: mlisa.extent)!
            return UIImage(cgImage: cgImage)
        }
        tableView.estimatedRowHeight = 76.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func didPressDone(_ sender: UIBarButtonItem)
    {
        dismiss(animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return CIFilter.possibleFilters.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(FilterTableViewCell.self)", for: indexPath) as! FilterTableViewCell
        let filter = CIFilter.possibleFilters[indexPath.row]
        cell.titleLabel.text = CIFilter.localizedName(forFilterName: filter.name)
        cell.filterImageView.image = images[indexPath.row]
        cell.accessoryType = self.selectedFilters.contains(filter) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let filter = CIFilter.possibleFilters[indexPath.row]
        if let index = selectedFilters.index(of: filter)
        {
            selectedFilters.remove(at: index)
        }
        else
        {
            selectedFilters.append(filter)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        delegate?.didUpdate(selectedFilters: selectedFilters)
    }

}
