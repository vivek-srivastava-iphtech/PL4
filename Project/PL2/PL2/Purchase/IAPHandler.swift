//
//  IAPHandler.swift
//  PL2
//
//  Created by Lekha Mishra on 12/16/17.
//  Copyright © 2017 IPHS Technologies. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    case failed
    case purchasedWeek
    case purchasedMonth
    case purchasedYear
    case restoredWeek
    case restoredMonth
    case restoredYear
    case buyBucket30
    case buyHint20
    case buyPicker40
    case noActiveSubscription
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your starter pack!"
        case .purchased: return "You've successfully bought this purchase!"
        case .failed: return "Unable to make purchase, Try later!"
        case .purchasedWeek: return "You've successfully bought a weekly subscription!"
        case .purchasedMonth: return "You've successfully bought a monthly subscription!"
        case .purchasedYear: return "You've successfully bought an yearly subscription!"
        case .restoredWeek: return "You've successfully restored your weekly subscription!"
        case .restoredMonth: return "You've successfully restored your monthly subscription!"
        case .restoredYear: return "You've successfully restored your yearly subscription!"
        case .buyBucket30: return "You've successfully bought 30 Paint Buckets!"
        case .buyHint20: return "You've successfully bought 20 Hints!"
        case .buyPicker40: return "You've successfully bought 40 Color Pickers!"
        case .noActiveSubscription: return "No Active Subscription!"
        }
    }
}

class IAPHandler: NSObject {
    static let shared = IAPHandler()
    
    let CONSUMABLE_PURCHASE_PRODUCT_ID = "testpurchase"
    let NON_CONSUMABLE_PURCHASE_PRODUCT_ID = "com.moomoolab.pl2sp"
    let WEEK_SUBSCRIPTION_PURCHASE_PRODUCT_ID = "com.moomoolab.pl2wk"
    let MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID = "com.moomoolab.pl2mo"
    let MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID_Mods = "com.moomoolab.pl2mods" // New Purchse screen
    let YEAR_SUBSCRIPTION_PURCHASE_PRODUCT_ID = "com.moomoolab.pl2yr"
    let Hints_30_PRODUCT_ID = "com.moomoolab.pl2hints40"
    let Paint_Buckets_30_PRODUCT_ID = "com.moomoolab.pl2paints80"
    let Paint_Pickers_30_PRODUCT_ID = "com.moomoolab.30PaintPickers"
   
    var subscriptionTypeRestored = ""
    var starterPackRestored = ""
    var isLoggedevent = 1
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    fileprivate var purchasedProductIds = Array<String>()
    var selectedProductID = ""
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:NON_CONSUMABLE_PURCHASE_PRODUCT_ID, WEEK_SUBSCRIPTION_PURCHASE_PRODUCT_ID, MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID,MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID_Mods, YEAR_SUBSCRIPTION_PURCHASE_PRODUCT_ID, Hints_30_PRODUCT_ID, Paint_Buckets_30_PRODUCT_ID, Paint_Pickers_30_PRODUCT_ID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                print(product.localizedDescription + "\nfor just \(price1Str!)")
                print(product.productIdentifier)
                print("============")

                if product.productIdentifier == WEEK_SUBSCRIPTION_PURCHASE_PRODUCT_ID
                {
                    UserDefaults.standard.set(price1Str, forKey: "WEEKLY_PRICE")
                }
                else if (product.productIdentifier == MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID)
                {
                    UserDefaults.standard.set(price1Str, forKey: "MONTHLY_PRICE")
                    let dd = Double(product.price).rounded(toPlaces: 2) + Double(product.price).rounded(toPlaces: 2)
                    UserDefaults.standard.set(numberFormatter.string(from: NSNumber(value: dd)), forKey: "MONTHLY_PRICE_OFFER")
                    print("MONTHLY_PRICE_OFFER:- \(UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"))")
                }
                else if (product.productIdentifier == MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID_Mods){
                    
                    UserDefaults.standard.set(price1Str, forKey: "MONTHLY_PRICE_MODS")
                    let dd = Double(product.price).rounded(toPlaces: 2) + Double(product.price).rounded(toPlaces: 2)
                    UserDefaults.standard.set(numberFormatter.string(from: NSNumber(value: dd)), forKey: "MONTHLY_PRICE_OFFER_MODS")
                   
                    
                    if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                        UserDefaults.standard.set(price1Str, forKey: "MONTHLY_PRICE")
                        let dd = Double(product.price).rounded(toPlaces: 2) + Double(product.price).rounded(toPlaces: 2)
                        UserDefaults.standard.set(numberFormatter.string(from: NSNumber(value: dd)), forKey: "MONTHLY_PRICE_OFFER")
                        print(UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"))
                    }
//
                    // print("MONTHLY_PRICE_OFFER MODS:- \(UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"))")
                    
                }
                
                else if product.productIdentifier == YEAR_SUBSCRIPTION_PURCHASE_PRODUCT_ID
                {
                    UserDefaults.standard.set(price1Str, forKey: "YEARLY_PRICE")
                }
                else if product.productIdentifier == Hints_30_PRODUCT_ID
                {
                    UserDefaults.standard.set(price1Str, forKey: "Hints_30")
                }
                else if product.productIdentifier == Paint_Buckets_30_PRODUCT_ID
                {
                    UserDefaults.standard.set(price1Str, forKey: "Paint_Buckets_30")
                }
                else if product.productIdentifier == Paint_Pickers_30_PRODUCT_ID
                {
                    UserDefaults.standard.set(price1Str, forKey: "Paint_Pickers_30")
                }

            }
            let FETCH_PRODUCT_ONLY = UserDefaults.standard.value(forKey: "FETCH_PRODUCT_ONLY") as? String
            if FETCH_PRODUCT_ONLY == "NO"
            {
                purchaseMyProduct(product_identifier: selectedProductID)
            }

        }
        else
        {
            purchaseStatusBlock?(.failed)
            SVProgressHUD.dismiss()
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //purchaseStatusBlock?(.restored) //ToDo
        let transactions =  queue.transactions
        //self.receiptValidation()
        IAPViewController.shared.verifySubscriptions([.pl2sp,.pl2wk, .pl2mo, .pl2mods, .pl2yr])
        subscriptionTypeRestored = ""
        starterPackRestored = ""
        isLoggedevent = 0
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .restored:
                    if let productIdentifier = transaction.payment?.productIdentifier {

                        SwiftyReceiptValidator.validate(forIdentifier: productIdentifier, sharedSecret: "41d0f1f21d1a4e51a9811b08cf282e53") { (success, response) in
                            if success {
                                /// Your code to restore product for productIdentifier, I usually use delegation here
                                if let receipt = response!["pending_renewal_info"]
                                {
                                    let renewalInfo = receipt.lastObject as! NSDictionary
                                    let auttoRenewStatus: String = renewalInfo["auto_renew_status"] as! String
                                    switch auttoRenewStatus {
                                    case "1":
                                        let prodID = renewalInfo["auto_renew_product_id"] as! String
                                        switch prodID
                                        {
                                        case self.WEEK_SUBSCRIPTION_PURCHASE_PRODUCT_ID:
                                            print("restored week")
                                            if self.isLoggedevent == 0
                                            {
                                                self.isLoggedevent = 1
                                                self.appDelegate.logEvent(name: "weekly_subscription_restore_complete", category: "Subscription", action: "Restore Button")
                                            }
                                            self.subscriptionTypeRestored = transaction.payment.productIdentifier as String
                                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                            self.purchaseStatusBlock?(.restoredWeek)
                                            SVProgressHUD.dismiss()
                                            break
                                        case self.MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID,self.MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID_Mods:
                                            print("restored month")
                                            if self.isLoggedevent == 0
                                            {
                                                self.isLoggedevent = 1
                                                self.appDelegate.logEvent(name: "monthly_subscription_restore_complete", category: "Subscription", action: "Restore Button")
                                            }
                                            self.subscriptionTypeRestored = transaction.payment.productIdentifier as String
                                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                            self.purchaseStatusBlock?(.restoredMonth)
                                            SVProgressHUD.dismiss()
                                            break
                                        case self.YEAR_SUBSCRIPTION_PURCHASE_PRODUCT_ID:
                                            print("restored year")
                                            if self.isLoggedevent == 0
                                            {
                                                self.isLoggedevent = 1
                                                self.appDelegate.logEvent(name: "yearly_subscription_restore_complete", category: "Subscription", action: "Restore Button")
                                            }
                                            self.subscriptionTypeRestored = transaction.payment.productIdentifier as String
                                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                            self.purchaseStatusBlock?(.restoredYear)
                                            SVProgressHUD.dismiss()
                                            break
                                        case self.NON_CONSUMABLE_PURCHASE_PRODUCT_ID:
                                            print("restored starter")
                                            self.starterPackRestored = transaction.payment.productIdentifier as String
                                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                            self.purchaseStatusBlock?(.restored)
                                            SVProgressHUD.dismiss()
                                            break
                                        default:
                                            break
                                        }
                                        break
                                    case "0":
                                        let prodID = transaction.payment.productIdentifier as String
                                        switch prodID
                                        {
                                        case self.NON_CONSUMABLE_PURCHASE_PRODUCT_ID:
                                            print("restored starter case auto_renew_status=0")
                                            self.starterPackRestored = transaction.payment.productIdentifier as String
                                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                            self.purchaseStatusBlock?(.restored)
                                            SVProgressHUD.dismiss()
                                            break
                                        default:
                                            print("iap not found case auto_renew_status=0")
                                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                            break
                                        }
                                        break
                                    default:
                                        break
                                    }
                                }
                                else
                                {
                                    let prodID = transaction.payment.productIdentifier as String
                                    switch prodID
                                    {
                                    case self.NON_CONSUMABLE_PURCHASE_PRODUCT_ID:
                                        print("restored starter pending renewal not there")
                                        self.starterPackRestored = transaction.payment.productIdentifier as String
                                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                        break
                                    default:
                                        print("iap not found pending renewal not there")
                                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                                        break
                                    }
                                }
                            }
                        }
                    }
                    break
                case .failed:
                    print("failed restore")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    print(trans.error as Any)
                    purchaseStatusBlock?(.failed)
                    SVProgressHUD.dismiss()
                    break
                default: break
                }
            }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("ERROR===",error)
        purchaseStatusBlock?(.failed)
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
        
    }
    
    func purchaseMyProduct(product_identifier: String){
        print("GET PRODUCT IDENTIFIER: \(product_identifier)")
        selectedProductID = product_identifier
        if iapProducts.count == 0
        {
            UserDefaults.standard.set("NO", forKey: "FETCH_PRODUCT_ONLY")
            self.fetchAvailableProducts()
        }
        else{
            
            if self.canMakePurchases() {
                for product in iapProducts{
                    if product.productIdentifier == product_identifier
                    {
                        let payment = SKPayment(product: product)
                        SKPaymentQueue.default().add(self)
                        SKPaymentQueue.default().add(payment)
                        print("PRODUCT TO PURCHASE/IDENTIFIER: \(product.productIdentifier)")
                        productID = product.productIdentifier
                    }
                }
            }
            else {
                purchaseStatusBlock?(.disabled)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        //self.receiptValidation()
        IAPViewController.shared.verifySubscriptions([.pl2sp,.pl2wk, .pl2mo, .pl2mods, .pl2yr])
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    let product_id = transaction.payment.productIdentifier
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchasedProductIds.append(product_id)
                    if product_id == WEEK_SUBSCRIPTION_PURCHASE_PRODUCT_ID
                    {
                        purchaseStatusBlock?(.purchasedWeek)
                        SVProgressHUD.dismiss()
                        if isPagesFreeTrailButtonClick == true {
                            //self.appDelegate.logEvent(name: "Weekly_sub_comp_BN", category: "Subscription", action: "Pages")
                            //self.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Banner")
                            isPagesFreeTrailButtonClick = false
                        }
                    }
                    else if (product_id == MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID || product_id == MONTH_SUBSCRIPTION_PURCHASE_PRODUCT_ID_Mods)
                    {
                        purchaseStatusBlock?(.purchasedMonth)
                        SVProgressHUD.dismiss()
                    }
                    else if product_id == YEAR_SUBSCRIPTION_PURCHASE_PRODUCT_ID
                    {
                        purchaseStatusBlock?(.purchasedYear)
                        SVProgressHUD.dismiss()
                    }
                    else if product_id == Hints_30_PRODUCT_ID
                    {
                        purchaseStatusBlock?(.buyHint20)
                        SVProgressHUD.dismiss()
                    }
                        
                    else if product_id == Paint_Buckets_30_PRODUCT_ID
                    {
                        purchaseStatusBlock?(.buyBucket30)
                        SVProgressHUD.dismiss()
                    }
                    else if product_id == Paint_Pickers_30_PRODUCT_ID
                    {
                        purchaseStatusBlock?(.buyPicker40)
                        SVProgressHUD.dismiss()
                    }
                    else
                    {
                        purchaseStatusBlock?(.purchased)
                        SVProgressHUD.dismiss()
                    }
                    
                    break
                    
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    print(trans.error as Any)
                    purchaseStatusBlock?(.failed)
                    SVProgressHUD.dismiss()
                    break
                case .restored:
                    print("restored11")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    SVProgressHUD.dismiss()
                    break
                    
                default: break
                }}}
    }

    public func isProductPurchased(productId: String) -> Bool {
        return purchasedProductIds.contains(productId)
    }
    
    
    //MARK: Check for Receipt
    func receiptValidation(isPurchase: ((Bool) -> Void)? = nil) {

        let SUBSCRIPTION_SECRET = "41d0f1f21d1a4e51a9811b08cf282e53"
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            //print(base64encodedReceipt!)
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]

            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
            do {

                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                //PRODUCTION URL//https://buy.itunes.apple.com/verifyReceipt
                //SANDBOX URL//https://sandbox.itunes.apple.com/verifyReceipt
                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                //let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
               // request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                 request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data) as! NSDictionary
                            //print("COMPLETE RECEIPT WITH ALL PURCHASE ::\n \(appReceiptJSON)")
                            UserDefaults.standard.set("NO", forKey: "FIRST_RECEIPT")
                            //Last receipt
                            if let receiptInfo: NSArray = appReceiptJSON["latest_receipt_info"] as? NSArray {
                               // print("receiptInfo RECEIPT WITH ALL PURCHASE ::\n \(receiptInfo)")
                                let lastReceipt = receiptInfo.lastObject as! NSDictionary
                                // Get last receipt
                                //  print("LAST RECEIPT INFORMATION ::\n",lastReceipt)
                                // Format date
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                                //formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                                // Get Expiry date as NSDate
                                var stringDate1 = lastReceipt["expires_date"] as! String
                                stringDate1 = stringDate1.replacingOccurrences(of: "Etc/GMT", with: "GMT")
                                //let subscriptionExpirationDate: NSDate = formatter.date(from: lastReceipt["expires_date"] as! String) as NSDate!
                                let subscriptionExpirationDate: NSDate = formatter.date(from: stringDate1) as NSDate!
                                formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
                                //print("\n   - DATE SUBSCRIPTION EXPIRES = \(subscriptionExpirationDate)")
                                // Update Expiration Date
                                let ExpirationDateString = formatter.string(from: subscriptionExpirationDate as Date)
                                UserDefaults.standard.set(ExpirationDateString, forKey: "EXPIRATION_DATE")
                                //print("\n   - DATE SUBSCRIPTION EXPIRES STRING = \(ExpirationDateString)")

                                let checkExpirationBool : Bool =  self.checkExpirationExceeded(expirationDateString:ExpirationDateString)
                                if checkExpirationBool == true
                                {
                                   // print("EXPIRED RECEIPT")
                                    UserDefaults.standard.set("YES", forKey: "IS_EXPIRED")
                                    UserDefaults.standard.set(1, forKey: "EXPIRE_INTENT")
                                    UserDefaults.standard.synchronize()
                                }
                                else
                                {
                                   // print("RUNNING RECEIPT")
                                    UserDefaults.standard.set("NO", forKey: "IS_EXPIRED")
                                    UserDefaults.standard.set(0, forKey: "EXPIRE_INTENT")
                                    UserDefaults.standard.set("YES", forKey: "SUBSCRIPTION_PURCHASE")
                                    UserDefaults.standard.synchronize()
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
                                    }
                                }
                                for productInfo:Any in receiptInfo
                                {
                                    let info = productInfo as! NSDictionary
                                    let productIdentifier: String = info["product_id"] as! String
                                    if productIdentifier == self.NON_CONSUMABLE_PURCHASE_PRODUCT_ID
                                    {
                                       // print("NON CONSUMABLE PURCHASE===",productIdentifier)
                                        // Check if product id com. strtar pach exists then update userdefault
                                        UserDefaults.standard.set("YES", forKey: "NON_CONSUMABLE_PURCHASE")
                                    }
                                }
                                if let purchase = isPurchase{
                                    purchase(receiptInfo.count > 0)
                                }
                            }
                            
                            // Manage Expiration Intent
                            /*if let pendingRenewalInfo: NSArray = appReceiptJSON["pending_renewal_info"] as? NSArray
                            {
                                //print("PENDING RENEWAL INFO ::\n \(pendingRenewalInfo)")
                                let renewalInfo = pendingRenewalInfo.lastObject as! NSDictionary
                                let auttoRenewStatus: String = renewalInfo["auto_renew_status"] as! String

                                if auttoRenewStatus == "1"
                                {
                                    //Update --IS EXPIRED
                                    UserDefaults.standard.set("NO", forKey: "IS_EXPIRED")
                                    UserDefaults.standard.set(0, forKey: "EXPIRE_INTENT")
                                    UserDefaults.standard.set("YES", forKey: "SUBSCRIPTION_PURCHASE")
                                    UserDefaults.standard.synchronize()
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
                                    }
                                    //Running
                                }
                                if let expirationIntent: String = renewalInfo["expiration_intent"] as? String
                                {
                                    if expirationIntent == "1"
                                    {
                                        //Update -- IS EXPIRED
                                        UserDefaults.standard.set("YES", forKey: "IS_EXPIRED")
                                        UserDefaults.standard.set(1, forKey: "EXPIRE_INTENT")
                                        UserDefaults.standard.synchronize()
                                        //EXPIRED
                                    }
                                }
                            }*/
                            
                            
                            
                        } catch let error as NSError {
                            print("json serialization failed with error: \(error)")
                        }
                    } else {
                        print("the upload task returned an error: \(String(describing: error))")
                    }
                }
                task.resume()
            } catch let error as NSError {
                print("json serialization failed with error: \(error)")
            }
        }
    }

    func checkExpirationExceeded(expirationDateString:String)->Bool
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        let currentDateString = formatter.string(from: date)
        print("Current Date String IAP==\(currentDateString),Expiration Date String IAP==\(expirationDateString)")
        //let dateGMT = Date().preciseGMTTime
        //let dateLocal = Date().preciseLocalTime
        //print("dateGMT IAP==\(dateGMT),dateLocal IAP==\(dateLocal)")
        let currentDate = formatter.date(from: currentDateString)!
        let expirationDate = formatter.date(from: expirationDateString)!
        print("Current Date IAP==\(currentDate),Expiration Date IAP==\(expirationDate)")

        if currentDate > expirationDate
        {
            return true
        }
        else if currentDate < expirationDate
        {
           return false
        }
        else
        {
            return false
        }
    }

}
extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        return formatter
    }()
}
extension Date {
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var nanosecond: Int { return Calendar.current.component(.nanosecond,  from: self)   }
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
