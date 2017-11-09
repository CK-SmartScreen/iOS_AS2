
import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var inputCurrency: UIButton!
    @IBOutlet weak var outputCurrency: UIButton!
    @IBOutlet weak var inputCountryButton: UIButton!
    @IBOutlet weak var outputCountryButton: UIButton!
    @IBOutlet weak var DecimalPointButton: UIButton!

    var inputString = "0"
    var outputString = "0"
    var operation1: Double = 0
    var operation2: String = "="
    var exchangeRate: Double = 0.68
    
    var inputCurrencyInfo: (String, String) = ("NZD", "$") {
        willSet {
            inputCountryButton.setTitle(newValue.0, for: .normal)
        }
    }
    
    var outputCurrencyInfo: (String, String) = ("USD", "$") {
        willSet {
            outputCountryButton.setTitle(newValue.0, for: .normal)
        }
    }

    var isFirstDigit = true

    var inputValue: Double {
        get {
            return NumberFormatter().number(from: inputString)!.doubleValue
        }
        set {
            inputString = newValue == 0 ? "0" : String(format: "%.2f", newValue)
            inputCurrency.setTitle(inputCurrencyInfo.1 + inputString, for: .normal)
            isFirstDigit = true
        }
    }
    
    var outputValue: Double {
        get {
            return NumberFormatter().number(from: outputString)!.doubleValue
        }
        set {
            outputString = newValue == 0 ? "0" : String(format: "%.2f", newValue)
            outputCurrency.setTitle(outputCurrencyInfo.1 + outputString, for: .normal)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        inputCountryButton.setTitle(inputCurrencyInfo.0, for: .normal)
        outputCountryButton.setTitle(outputCurrencyInfo.0, for: .normal)
        inputValue =  0
        outputValue = 0
        inputString = "0"
        outputString = "0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func digitPress(_ sender: UIButton) {
        if (inputString.range(of:".") != nil && sender.currentTitle == ".") {
            return
        }

        let digit = sender.currentTitle!
        inputString = isFirstDigit ? digit : inputString + digit
        inputCurrency.setTitle((inputCurrencyInfo.1 + inputString), for: .normal)

        outputValue = inputValue * exchangeRate
        outputString = String(format:"%.2f", inputValue * exchangeRate)

        isFirstDigit = false
    }

    @IBAction func operationAction(_ sender: UIButton) {
        operation2 = sender.currentTitle!
        operation1 = inputValue
        isFirstDigit = true
        DecimalPointButton.isEnabled = true
        DecimalPointButton.backgroundColor = UIColor.orange
    }

    @IBAction func calculateAction(_ sender: Any) {
        switch operation2 {
            case "+": inputValue += operation1
            case "-": inputValue = operation1 - inputValue
            default : break
        }

        outputValue = inputValue * exchangeRate
        outputString = String(format:"%.2f", inputValue * exchangeRate)
    }

    @IBAction func deleteAction(_ sender: Any) {
        inputValue = 0
        outputValue = 0
        isFirstDigit = true
    }

    @IBAction func SwapAction(_ sender: Any) {
        let tempTuple: (String, String) = inputCurrencyInfo
        inputCurrencyInfo = outputCurrencyInfo
        outputCurrencyInfo = tempTuple
        let tmp = inputValue
        inputValue = outputValue
        outputValue = tmp
        exchangeRate = 1 / exchangeRate
    }
    
    // MARK: Segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the currency we are changing (input or output) and
        // the current currency code to the Change Currency View Controller.
        if segue.identifier == "ChangeInputCurrency" {
            let currencyViewController = segue.destination as! CurrencyViewController
            currencyViewController.targetCurrency = "input"
            currencyViewController.selectedCurrency = inputCurrencyInfo.0
            currencyViewController.delegate = self
        }
        
        if segue.identifier == "ChangeOutputCurrency" {
            let currencyViewController = segue.destination as! CurrencyViewController
            currencyViewController.targetCurrency = "output"
            currencyViewController.selectedCurrency = outputCurrencyInfo.0
            currencyViewController.delegate = self
        }
    }
    
}

// MARK: Delegate.
extension CalculatorViewController: CurrencyViewControllerDelegate {
    
    func didChangeCurrency(code: String, symbol: String, target: String) {
        if target == "input" {
            self.inputCurrencyInfo = (code, symbol)
            print("Input currency changed to: \(code)")
        }
        if target == "output" {
            self.outputCurrencyInfo = (code, symbol)
            print("Output currency changed to: \(code)")
        }
    }

}
