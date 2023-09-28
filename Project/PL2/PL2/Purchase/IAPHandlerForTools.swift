import UIKit
import StoreKit
import SVProgressHUD

class IAPHandlerForTools: NSObject {
    static let shared = IAPHandlerForTools()

    let Hints_30_PRODUCT_ID = "com.moomoolab.pl2hints40"
    let Paint_Buckets_30_PRODUCT_ID = "com.moomoolab.pl2paints80"
    let Paint_Pickers_30_PRODUCT_ID = "com.moomoolab.30PaintPickers"

    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    fileprivate var purchasedProductIds = Array<String>()
    var selectedProductID = ""
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }

    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:Hints_30_PRODUCT_ID, Paint_Buckets_30_PRODUCT_ID, Paint_Pickers_30_PRODUCT_ID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

//MARK:- Product Request Delegate and Payment Transaction Methods
extension IAPHandlerForTools: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    // REQUEST IAP PRODUCTS
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

                if product.productIdentifier == Hints_30_PRODUCT_ID
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
        let transactions =  queue.transactions
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
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
        SVProgressHUD.dismiss()
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

    // IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    let product_id = transaction.payment.productIdentifier
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if product_id == Hints_30_PRODUCT_ID
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
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                default: break
                }}}
    }

}
