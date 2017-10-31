import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var inputCurrency: UIButton!
    @IBOutlet weak var outputCurrency: UIButton!
    @IBOutlet weak var inputCountryCode: UIButton!
    @IBOutlet weak var outputCountryCode: UIButton!



    //  Use this value to calculte the currency!  //
    var convertRate: Double = 5   // For example
    var inputCountryInfo: (String, String) = ("USD", "$")
    var outputCountryInfo: (String, String) = ("CYN", "¥")
    // -------------------------------------------//

    var isFirstDigit = true
    var inputValue: Double = 0
    var outputValue: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        inputCountryCode.setTitle(inputCountryInfo.0, for: .normal)
        outputCountryCode.setTitle(outputCountryInfo.0, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func digitPress(_ sender: UIButton) {
        let digit = sender.currentTitle!
        inputCurrency.setTitle((isFirstDigit ? inputCountryInfo.1 + digit : inputCurrency.currentTitle! + digit), for: .normal)
        isFirstDigit = false

        inputValue = strToDecimal(str: inputCurrency.currentTitle!)
        print(inputValue)
    }

    @IBAction func ConvertAction(_ sender: Any) {
        outputValue = inputValue * convertRate

        let c:String = String(format:"%.2f", outputValue)
        outputCurrency.setTitle((outputCountryInfo.1 + c), for: .normal)
    }

    @IBAction func deleteAction(_ sender: Any) {
        isFirstDigit = true
        inputCurrency.setTitle("0", for: .normal)
        outputCurrency.setTitle("0", for: .normal)
        inputValue = 0
        outputValue = 0
    }

    @IBAction func SwapAction(_ sender: Any) {
    }

    @IBAction func operationAction(_ sender: Any) {
    }

    func strToDecimal (str: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let number = formatter.number(from: str) {
            let amount = number.doubleValue
            return amount
        }
        return -1
    }

}

