import UIKit
import GoogleMobileAds

class CalculatorViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var inputCurrency: UIButton!
    @IBOutlet weak var outputCurrency: UIButton!
    @IBOutlet weak var inputCountryButton: UIButton!
    @IBOutlet weak var outputCountryButton: UIButton!
    @IBOutlet weak var DecimalPointButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!


    var inputString = "0"
    var outputString = "0"
    var operation1: Double = 0
    var operation2: String = "="
    var inputRate = 1.44
    var outputRate = 1.0
    var exchangeRate: Double {
        get{
            return outputRate / inputRate
        }
    }

    
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

        // For Admob
        bannerView.isHidden = true
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-8666765004598567/9186400824"
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        bannerView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func digitPress(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if (isFirstDigit) {
            inputString = ""
        }
        if (inputString.range(of:".") != nil && digit == ".") {
            return
        }
        if (isFirstDigit && digit == "."){
            inputString = "0."
            isFirstDigit = false
            return
        }

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
        let tmprate = inputRate
        inputRate = outputRate
        outputRate = tmprate
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
    
    func didChangeCurrency(code: String, symbol: String, rate: Double, target: String) {
        if target == "input" {
            self.inputCurrencyInfo = (code, symbol)
            print("Input currency changed to: \(code), with rate: \(rate)")
            inputRate = rate
            self.deleteAction(UIButton())
        }
        if target == "output" {
            self.outputCurrencyInfo = (code, symbol)
            print("Output currency changed to: \(code), with rate: \(rate)")
            outputRate = rate
            self.deleteAction(UIButton())
        }
    }

}
