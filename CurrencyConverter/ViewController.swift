import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var inputCurrency: UIButton!
    @IBOutlet weak var outputCurrency: UIButton!
    @IBOutlet weak var inputCountryButton: UIButton!
    @IBOutlet weak var outputCountryButton: UIButton!

    var exchangeRate: Double = 0.68
    var inputCountryInfo: (String, String) = ("NZD", "$") {
        willSet {
            inputCountryButton.setTitle(newValue.0, for: .normal)
        }
    }
    var outputCountryInfo: (String, String) = ("USD", "$") {
        willSet {
            outputCountryButton.setTitle(newValue.0, for: .normal)
        }
    }

    var isFirstDigit = true
    var inputValue: Double = 0
    var outputValue: Double = 0
    var inputString: String {
        get {
            return tempString
        }
        set {
            inputCurrency.setTitle((inputCountryInfo.1 + newValue), for: .normal)
            inputValue = Double (newValue)!
        }
    }


    var outputString: String {
        get {
            return String(format: "%.2f", outputValue)
        }
        set {
            outputCurrency.setTitle((outputCountryInfo.1 + newValue), for: .normal)
            outputValue = Double (newValue)!
        }
    }

    var tempString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        inputCountryButton.setTitle(inputCountryInfo.0, for: .normal)
        outputCountryButton.setTitle(outputCountryInfo.0, for: .normal)
        inputString = "0"
        outputString = "0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func digitPress(_ sender: UIButton) {
        let digit = sender.currentTitle!
        tempString = isFirstDigit ? digit : tempString + digit
        inputString = tempString
        isFirstDigit = false

        print(inputValue)
    }

    @IBAction func ConvertAction(_ sender: Any) {
        outputValue = inputValue * exchangeRate
        let c:String = String(format:"%.2f", outputValue)
        outputCurrency.setTitle((outputCountryInfo.1 + c), for: .normal)
    }

    @IBAction func deleteAction(_ sender: Any) {
        isFirstDigit = true
        inputCurrency.setTitle("0", for: .normal)
        outputCurrency.setTitle("0", for: .normal)
        inputString = "0"
        outputString = "0"
    }

    @IBAction func SwapAction(_ sender: Any) {
        let tempTuple: (String, String) = inputCountryInfo
        inputCountryInfo = outputCountryInfo
        outputCountryInfo = tempTuple

        let tempString = inputString
        inputString = outputString
        outputString = tempString

        exchangeRate = 1 / exchangeRate
    }

    @IBAction func operationAction(_ sender: Any) {
    }

}

