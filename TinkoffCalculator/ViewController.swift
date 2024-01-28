//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Олег Ковалев on 28.01.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else { return }
        print(buttonText)
    }
    
}

