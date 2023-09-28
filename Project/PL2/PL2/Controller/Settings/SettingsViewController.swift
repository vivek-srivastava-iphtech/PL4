//
//  SettingsViewController.swift
//  PL2
//
//  Created by Lekha Mishra on 12/11/17.
//  Copyright © 2017 IPHS Technologies. All rights reserved.
//

import UIKit
import MessageUI
import SVProgressHUD

enum Options : Int {
    case kOptionTutorial
    case kOptionContact
    case kOptionRestore
    case kOptionAbout
    case kOptionHelp
    case kOptionPaintBucket
    case kSoundEffect
    
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var optionTable: UITableView!
    var optionsArray = [String]()
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var paintBucketKey = "isPaintBucketExtended"

    override func viewDidLoad() {
        super.viewDidLoad()

        /*let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
         //, NSLocalizedString("Add New Category", comment:"Add New Category")*/
        
        let str = "Tutorial"
        optionsArray = [str.localized , NSLocalizedString("Contact", comment:"Contact"), NSLocalizedString("Restore", comment:"Restore"), NSLocalizedString("About", comment:"About"), NSLocalizedString("Help", comment:"Help"),NSLocalizedString("Paint Bucket", comment:"Paint Bucket"),NSLocalizedString("Sound Effect", comment:"Sound Effect")]

        optionTable.register(UINib(nibName: "OptionCell", bundle: nil), forCellReuseIdentifier: "OptionCell")
        optionTable.reloadData()
        // Do any additional setup after loading the view.
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }

        
    }

    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
        appDelegate.logScreen(name: "Settings")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarningSettings Shoaib")
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITableView Delegate Methods-
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "OptionCell"
        let cell = self.optionTable.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! OptionCell
        cell.selectionStyle = .none
        cell.toggleSwitch.onTintColor = UIColor.red
        cell.toggleSwitch.tag = indexPath.row // for detect which row switch Changed
        cell.toggleSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.titleTxt.font = UIFont.boldSystemFont(ofSize: 13)
        cell.titleTxt.textColor = UIColor.gray
        cell.arrowLabel.isHidden = true

        if indexPath.row == optionsArray.count - 2{
            let isPaintBucketExtended = UserDefaults.standard.bool(forKey: paintBucketKey)
            cell.toggleSwitch.isHidden = false
            
            if isPaintBucketExtended == false {
                let extendedText = NSLocalizedString("Extended", comment:"Extended")
                cell.titleTxt.text = "\(self.optionsArray[indexPath.row]) - \(extendedText)"
                cell.toggleSwitch.isOn = true

            }
            else {
                let normalText = NSLocalizedString("Normal", comment:"Normal")
                cell.titleTxt.text = "\(self.optionsArray[indexPath.row]) - \(normalText)"
                cell.toggleSwitch.isOn = false

            }
        }
        else if indexPath.row == optionsArray.count - 1{
            cell.toggleSwitch.isHidden = false
            cell.titleTxt.text = "\(self.optionsArray[indexPath.row])"
            
            if UserDefaults.standard.bool(forKey: isSoundEnabled){
                cell.toggleSwitch.isOn = true
            }
            else{
                cell.toggleSwitch.isOn = false
            }


        }
        else {
            cell.titleTxt.text = self.optionsArray[indexPath.row]
            cell.toggleSwitch.isHidden = true
            cell.arrowLabel.isHidden = false
        }

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedVal = Int(indexPath.row)
        
        switch selectedVal {
        case Options.kOptionTutorial.rawValue:
            appDelegate.logEvent(name: "settings_tutorial", category: "Settings", action: "Tutorial Button")
           // let vc = self.storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GifTutorialVC") as! GifTutorialVC
            vc.modalPresentationStyle = .overFullScreen //.overCurrentContext
            // vc.gifTutorialCloseTappedDelegate = self
            self.present(vc,animated:true,completion:nil)
            break
        case Options.kOptionContact.rawValue:
            appDelegate.logEvent(name: "settings_contact", category: "Settings", action: "Contact Button")
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            break
        case Options.kOptionRestore.rawValue:
            appDelegate.logEvent(name: "settings_restore", category: "Settings", action: "Restore Button")
            restorePurchase()
            break
        case Options.kOptionAbout.rawValue:
            appDelegate.logEvent(name: "settings_about", category: "Settings", action: "About Button")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutWebViewController") as! AboutWebViewController
            vc.resorceString = "newAbout"//"about"
            vc.loadUrl = "About"
            self.present(vc,animated:true,completion:nil)
            break
        case Options.kOptionHelp.rawValue:
            appDelegate.logEvent(name: "settings_help", category: "Settings", action: "Help Button")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutWebViewController") as! AboutWebViewController
            vc.resorceString = NSLocalizedString("help_base", comment: "")
            vc.loadUrl = "Help"
            self.present(vc,animated:true,completion:nil)
            break
        case Options.kOptionPaintBucket.rawValue:

            let isPaintBucketExtended = UserDefaults.standard.bool(forKey: paintBucketKey)

            let cell = tableView.cellForRow(at: indexPath) as! OptionCell

            if isPaintBucketExtended == false {
                
                let normalText = NSLocalizedString("Normal", comment:"Normal")
                cell.titleTxt.text = "\(self.optionsArray[indexPath.row]) - \(normalText)"
                cell.toggleSwitch.isOn = false
            }
            else {
                let extendedText = NSLocalizedString("Extended", comment:"Extended")
                cell.titleTxt.text = "\(self.optionsArray[indexPath.row]) - \(extendedText)"
                cell.toggleSwitch.isOn = true
            }

            UserDefaults.standard.set(!isPaintBucketExtended, forKey:paintBucketKey)
//        case Options.kOptionAddCategory.rawValue:
//            presentModalController()
        case Options.kSoundEffect.rawValue:
            let cell = tableView.cellForRow(at: indexPath) as! OptionCell

            if cell.toggleSwitch.isOn {
                UserDefaults.standard.setValue(false,forKey: isSoundEnabled)
                cell.toggleSwitch.isOn = false
                
            }else{
                UserDefaults.standard.setValue(true,forKey: isSoundEnabled)
                cell.toggleSwitch.isOn = true

            }


        default:
            print("NO Options Selected")
            
        }
    }
    
    //MARK: Switch
    @objc func switchChanged(_ sender : UISwitch!){
        
        if sender.tag == Options.kOptionPaintBucket.rawValue{
            let isPaintBucketExtended = UserDefaults.standard.bool(forKey: paintBucketKey)
            
            if sender.isOn{
                if isPaintBucketExtended == false {
                    let normalText = NSLocalizedString("Normal", comment:"Normal")
                    optionsArray[sender.tag] = "\(normalText)"
                }
                
            }
            else{
                optionsArray[sender.tag] = "\(self.optionsArray[sender.tag])"
                
            }
            UserDefaults.standard.set(!isPaintBucketExtended, forKey:paintBucketKey)
            optionTable.reloadData()
        }
        else{
            if sender.isOn{
                UserDefaults.standard.setValue(true,forKey: isSoundEnabled)
                
            }else {
                UserDefaults.standard.setValue(false,forKey: isSoundEnabled)
                
            }
        }
        
    }
    
    //MARK: Contact
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["feedback@pixelcolorapp.com"])
        mailComposerVC.setSubject("Feedback")

        let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let iOSVersionString = "\(UIDevice.modelName), \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let bodyString = "\nVersion: \(currentAppVersion)\n\(iOSVersionString)"
        mailComposerVC.setMessageBody(bodyString, isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - RESTORE PURCHASE
    @objc func restorePurchase()
    {
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || ((appDelegate.purchaseType() == .kPurchaseTypeNonConsumable)))
        {
          //Already Active Subscription
            let alertView = UIAlertController(title: "", message: "Already Active Subscription!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
        }
        else
        {
            if (UserDefaults.standard.object(forKey: "EXPIRE_INTENT") != nil)
            {
                let expirationIntent = UserDefaults.standard.integer(forKey: "EXPIRE_INTENT")
                if expirationIntent != 1
                {
                    SVProgressHUD.show()
                    IAPHandler.shared.restorePurchase()
                }
                else
                {
                    let alertView = UIAlertController(title: "", message: "No Active Subscription!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertView.addAction(action)
                    self.present(alertView, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            }
            else
            {
                SVProgressHUD.show()
                IAPHandler.shared.restorePurchase()
            }
        }
    }

//extension SettingsViewController:GifTutorialCloseTappedDelegate {
//    func GifTutorialCloseTapped() {
//        self.dismiss(animated: true, completion: nil)
//    }
//}

// To be updated
func presentModalController() {
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
    vc.modalPresentationStyle = .overCurrentContext
    self.present(vc,animated:false,completion:nil)

}

}
