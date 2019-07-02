import UIKit

let num = 13.54454455

round(1000*num)/1000


round(100*num)/100

pow(10, 5)



extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}



num.roundToDecimal(3)
