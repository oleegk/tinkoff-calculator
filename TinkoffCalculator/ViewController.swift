//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Олег Ковалев on 28.01.2024.
//

import UIKit

protocol LongPressViewProtocol {
    var shared: UIView { get }
    
    func startAnimation()
    func stopAnimation()
}

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
    case date(String)
}


class ViewController: UIViewController {
    
    var shared: UIView = UIView()
    var animator: UIViewPropertyAnimator?


    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    
    var calculationHistoryStorage = CalculationHistoryStorage()
    
    private let alertView: AlertView = {
        let screenBounds = UIScreen.main.bounds
        let alertHeight: CGFloat = 100
        let alertWidth: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - alertWidth / 2
        let y: CGFloat = screenBounds.height / 2 - alertHeight / 2
        let alertFrame = CGRect(x: x, y: y, width: alertWidth, height: alertHeight)
        let alertView = AlertView(frame: alertFrame)
        return alertView
    }()
    
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLabelText()
        calculations = calculationHistoryStorage.loadHistory()
        historyButton.accessibilityIdentifier = "toHistoryPageButton"
        
        view.addSubview(alertView)
        alertView.alpha = 0
        alertView.alertText = "Вы нашли пасхалку!"
        
        
        // Создаем жест нажатия на экран
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

    }
    
    
    
    @objc func handleTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            startAnimation()
        } else if sender.state == .ended {
            stopAnimation()
        }
    }

    func startAnimation() {
        // Создаем и добавляем на экран UIView shared
        shared = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shared.center = view.center
        shared.backgroundColor = .red
        view.addSubview(shared)

        // Создаем аниматор и запускаем анимацию
        animator = UIViewPropertyAnimator(duration: 2.0, curve: .easeInOut) {
            self.shared.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            
        }
        animator?.startAnimation()
    }

    func stopAnimation() {
        // Останавливаем аниматор и удаляем UIView shared
        animator?.stopAnimation(true)
        animator = nil
        shared.removeFromSuperview()
        
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
            
            if label.text == "3,141592" {
                animateAlert()
            }
            sender.animateTap()
                
                
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
            vc.calculations = calculations
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
            let newCalculation = Calculation(expression: calculationHistory, result: result, date: dateToStringForHeader())
            
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Ошибка"
            label.shake()
        }
        calculationHistory.removeAll()
    }
    
    func calculatePi(digits: String) -> String {
        let precision = pow(4, Double(10))
        var pi = 0.0
        var sign = 1.0
        for i in 0..<Int(precision) {
            let n = Double(i * 2 + 1)
            pi += sign / n
            sign *= -1
        }
        return String(format: "%.\(digits)f", pi * 4)
    }
    
    @IBAction func piCalculation(_ sender: Any) {
        DispatchQueue.main.async {
            self.label.text = self.calculatePi(digits: self.label.text ?? "2")
        }
    }
    
    func dateToStringForHeader(date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
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
    
    func animateAlert() {
        if !view.contains(alertView) {
            alertView.alpha = 0
            alertView.center = view.center
            view.addSubview(alertView)
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.5) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.alertView.alpha = 1
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                var newCenter = self.label.center
                newCenter.y -= self.alertView.bounds.height
                self.alertView.center = newCenter
            }
        }
    }
}

extension UILabel {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))
        
        layer.add(animation, forKey: "position")
    }
}

extension UIButton {
    
    func animateTap() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.9, 1]
        scaleAnimation.keyTimes = [0, 0.2, 1]
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.4, 0.8, 1]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        
        layer.add(animationGroup, forKey: "groupAnimation")
    }
}

extension ViewController: LongPressViewProtocol {}


