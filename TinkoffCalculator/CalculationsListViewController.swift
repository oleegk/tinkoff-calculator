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
    

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init (nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    required init? (coder: NSCoder) {
        super.init (coder: coder)
        initialize()
    }
    private func initialize() {
        modalPresentationStyle = .fullScreen
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        showCalculationLabelResult()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func showCalculationLabelResult() {
        if result == "0" {
            calculationLabel.text = "NoData"
        } else {
            calculationLabel.text = result
        }
    }
}
