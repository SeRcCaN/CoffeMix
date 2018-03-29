//
//  LatteViewController.swift
//  CoffeeMix
//
//  Created by Sercan Burak AĞIR on 22.03.2018.
//  Copyright © 2018 Sercan Burak AĞIR. All rights reserved.
//

import UIKit

class LatteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let customPresentAnimationController = CustomTransition()
    var parallaxOffsetSpeed: CGFloat = 10
    var cellHeight:CGFloat = 315
    var parallaxImageHeight: CGFloat{
        let maxOffset = (sqrt(pow(cellHeight, 2) + 4 * parallaxOffsetSpeed * self.tableView.frame.height) - cellHeight) / 2
        return maxOffset + self.cellHeight
    }
    
    var lattes: [Coffee] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkServices.shared.getAllCoffeeRecipes(url: LATTE_URL) { (coffees) in
            self.lattes = coffees
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            let destination = segue.destination as? DetailViewController
            destination?.transitioningDelegate = self
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            destination?.selectedCoffee = lattes[indexPath.row]
        }
    }
}

//MARK: - Transition Delegate

extension LatteViewController: UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customPresentAnimationController
    }
}

//MARK: - Tableview's Delegate and Datasource

extension LatteViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CoffeeCell else { return UITableViewCell() }
        let latte = lattes[indexPath.row]
        cell.configureCell(coffee: latte)
        cell.coffeeImageHeightConstraint.constant = parallaxImageHeight
        cell.coffeeImageTopConstraint.constant = parallaxOffset(newOffsetY: tableView.contentOffset.y, cell: cell)
        return cell
    }
    
    func parallaxOffset(newOffsetY: CGFloat, cell: UITableViewCell) -> CGFloat{
        return(newOffsetY - cell.frame.origin.y) / parallaxImageHeight * parallaxOffsetSpeed
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = tableView.contentOffset.y
        
        for cell in (tableView.visibleCells as? [CoffeeCell])!{
            cell.coffeeImageTopConstraint.constant = parallaxOffset(newOffsetY: offsetY, cell: cell)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lattes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
}
