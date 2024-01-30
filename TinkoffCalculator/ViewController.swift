//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Олег Ковалев on 28.01.2024.
//

import UIKit

class ViewController: UIViewController {
    
    enum CalculationError: Error {
        case devidedByZero
        case zeroAndFractionalPart
        case labelError
    }
    
    enum Operation: String {
        case add = "+"
        case substract = "-"
        case multiply = "x"
        case divide = "/"
        
        func calculate(_ number1: Double, _ number2: Double) throws -> Double {
            switch self {
            case .add:
                return number1 + number2
            case .substract:
                return number1 - number2
            case .multiply:
                return number1 * number2
            case .divide:
                if number2 == 0 {
                    throw CalculationError.devidedByZero
                }
                return number1 / number2
            }
        }
    }
    
    enum CalculationHistoryItem {
        case number(Double)
        case operation(Operation)
    }
    
    @IBOutlet weak var label: UILabel!
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    var calculationHistory: [CalculationHistoryItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabelText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    

    
    @IBAction func buttonPressed(_ sender: UIButton)  {
        guard let buttonText = sender.titleLabel?.text else { return }
        
        do {
            if buttonText == "," && label.text?.contains(",") == true { return }
            
            if (label.text == "0" || label.text == "Ошибка") && buttonText == "," {
                throw CalculationError.zeroAndFractionalPart
            }
            if label.text == "Ошибка" {
                throw CalculationError.labelError
            }
            
            
            if label.text == "0" {
                label.text = buttonText
            } else {
                label.text?.append(buttonText)
            }
        } catch CalculationError.zeroAndFractionalPart {
            label.text = "0,"
        } catch {
            label.text = buttonText
        }
    }
    
 
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text,
              let buttonOperation = Operation(rawValue: buttonText)
              else { return }
        
        guard let labelText = label.text,
              let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
              else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
    }
    
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        
        if let vc = calculationListVC as? CalculationsListViewController {
            vc.result = label.text
        }
        navigationController?.pushViewController(calculationListVC, animated: true)
    }
    
    
    func resetLabelText() {
        label.text = "0"
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard let labelText = label.text,
              let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
              else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            label.text = numberFormatter.string(from: NSNumber(value: result))
        } catch {
            label.text = "Ошибка"
        }
        calculationHistory.removeAll()
    }
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard case .operation(let operation) = calculationHistory[index],
                  case .number(let number) = calculationHistory[index + 1]
                  else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
}

