//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Олег Ковалев on 29.01.2024.
//

import UIKit

class CalculationsListViewController: UIViewController {
    
    var result: String?
    
    @IBOutlet weak var calculationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCalculationLabelResult()
        navigationItem.title = "Прошлые вычисления"
    }
    
    private func showCalculationLabelResult() {
        if result == "0" {
            calculationLabel.text = "NoData"
        } else {
            calculationLabel.text = result
        }
    }
}
