//
//  PagesView.swift
//  PL2
//
//  Created by Lekha Mishra on 11/30/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit
import CloudKit

protocol PagesViewDelegate:class {
    
    func didSelectioItem(item: ImageData)
    func didScrollDown(scroll: UIScrollView)
    
}

class PagesView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var currentLevelsArray = [String]()
    var currentSourceDict = [String: [ImageData]]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var delegate : PagesViewDelegate? = nil
    var collectionView : UICollectionView? = nil
    
    var totalCount = 0
    
    var keyValue = ""

    override func draw(_ rect: CGRect) {
        
    }
    
    func initializeView() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "load"), object: nil)
        if backgroundOrientation {
        NotificationCenter.default.addObserver(self, selector: #selector(loadInitial(notification:)), name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
        }
        self.backgroundColor = UIColor.white
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 0.0
        //layout.headerReferenceSize = CGSize(width:self.bounds.width , height: 50) //uncommet when Allow multilevels
        
        var noOfRows:CGFloat = 2.0
        
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            //noOfRows = 3.0
            if appDelegate.isLandscapeByMe()
            {
                noOfRows = 4.0
            }
            else {
                noOfRows = 3.0

            }
        }
        
        var width  = UIScreen.main.bounds.size.width/noOfRows
        
        var height = width - 20
        var offset = 0
        let max_width = 280
        offset = Int(height) > Int(max_width) ? (Int(height) - Int(max_width)) : 0
        width = width - CGFloat(offset)
        height = width - 20
        let margin:CGFloat = (CGFloat(offset)*noOfRows)/2

        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        
        var countForLevel1 = 0
        if let countValueForLevel1 = currentSourceDict["1"]?.count {
            keyValue = "1"
            countForLevel1 = countValueForLevel1
        }

        var countForLevel2 = 0
        if let countValueForLevel2 = currentSourceDict["2"]?.count {
            keyValue = "2"
            countForLevel2 = countValueForLevel2
        }
        
        totalCount = countForLevel1 + countForLevel2

        if UIDevice.current.userInterfaceIdiom == .pad {

            if totalCount <= 3 {
                layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 850, right: margin)
            }
            else if totalCount <= 6 {
                layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 800, right: margin)
            }
            else if totalCount <= 9 {
                layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 170, right: margin)
            }
            else {
                if !((((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || ((appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))))
                {
                    layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 165, right: margin)
                }
                else {
                    layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 106, right: margin)
                }
            }
        }
        else {
            
            if totalCount <= 2 {
                layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 600, right: margin)
            }
            else if totalCount <= 4 {
                layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 550, right: margin)
            }
            else if totalCount <= 6 {
                layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 115, right: margin)
            }
            else {
                if !((((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || ((appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))))
                {
                    layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 50, right: margin)
                }
                else {
                    layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 10, right: margin)
                }
            }
        }

        layout.itemSize = CGSize(width: width, height: height)
        layout.estimatedItemSize = CGSize.zero

        self.collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        if(userInterface == .pad)
        {
            let getWidth = UIScreen.main.bounds.width
            let getHeight = UIScreen.main.bounds.height
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
            {
                let framRect = CGRect(x:0 ,y:0 ,width:getWidth ,height: getHeight)
                self.collectionView = UICollectionView(frame: framRect, collectionViewLayout: layout)
            }
            else
            {
                let framRect = CGRect(x:0 ,y:0 ,width:getWidth ,height: getHeight)
                self.collectionView = UICollectionView(frame: framRect, collectionViewLayout: layout)
            }
        }
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.collectionView?.register(UINib(nibName : "MyWorkCell" , bundle : nil), forCellWithReuseIdentifier:"MyWorkCell" )
        //self.collectionView?.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView") //uncommet when Allow multilevels
        
        self.addSubview(self.collectionView!)
        self.collectionView?.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        self.collectionView?.reloadData()
        
    }
    
    
    @objc func loadList(notification: NSNotification) {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScrollDown(scroll: scrollView)
    }

    
    @objc func loadInitial(notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1)
        {
            self.collectionView?.removeFromSuperview()
            self.initializeView()
        }
    }
    
    //MARK: - CollectionView DataSource and Delegate
    
    //uncommet when Allow multilevels
//    func numberOfSections(in collectionView: UICollectionView) -> Int
//     {
//        if currentSourceDict.count > 1 {
//            return self.currentLevelsArray.count
//        }
//        else {
//            return 1
//        }
//     }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        //        return (self.currentSourceDict[currentLevelsArray[section]]?.count)!
        if let countValue = self.currentSourceDict["1"]?.count {
            return countValue
        }
        else if let countValue = self.currentSourceDict["2"]?.count {
            return countValue
        }
        return 0

    }
    
    let loader = UIActivityIndicatorView()
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "MyWorkCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,for: indexPath) as! MyWorkCell
        collectionView.isMultipleTouchEnabled = false
        cell.backImageView.backgroundColor = UIColor.white

        let userInterface = UIDevice.current.userInterfaceIdiom
        let orientDevice = appDelegate.isLandscapeByMe()
        
        if(userInterface == .pad && orientDevice == true)
        {
            cell.updateOffSetForiPadLandscape(indexPath.row%3)
        }
        else
        {
            switch indexPath.row%2 {
            case 0:
                cell.updateOffSet(true)
            default:
                cell.updateOffSet(false)
            }
        }

//        let currentValuesArray = currentSourceDict[currentLevelsArray[indexPath.section]]
        let currentValuesArray = currentSourceDict[keyValue]
        if let imgData = currentValuesArray![indexPath.row] as? ImageData {
            
            if appDelegate.isCompletedImage(imageId: imgData.imageId!, imageName: imgData.name!)
            {
                cell.completeIcon.isHidden = false
            }
            else
            {
                cell.completeIcon.isHidden = true
            }
            cell.loader.startAnimating()
            cell.imageView.image = nil
            
            if let img = appDelegate.getImage(imgName: imgData.name!, imageId: imgData.imageId!){
                //print("\n\n\n  Found Image in app delegate\n\n\n")
                cell.imageView.image = img
                if img.size.height > 1{
                    cell.loader.stopAnimating()
                } else{
                    //                cell.loader.startAnimating()
                }
                
            }
            else
            {
                //print("\n\n\n  Loading Image from server\n\n\n")
                self.loadServerImage(indexPath: indexPath, name: imgData.name! as NSString, cell:cell) //To Do Testing
            }
            
            cell.lockView.isHidden = true
            
            if let val = imgData.purchase{
                if val != 0 {
                    //                if appDelegate.purchaseType() == .kPurchasTypeNone
                    //                {
                    //                   cell.lockView.isHidden = false
                    //                }
                    let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                    if ((imgData.purchase == 0) || ((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (imgData.purchase == 1 && (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable)))
                    {
                        cell.lockView.isHidden = true
                    }
                    else
                    {
                        cell.lockView.isHidden = false
                    }

                }
            }
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.layoutIfNeeded()
        
        
        let width  = (collectionView.frame.size.width)/2
        let height = width-20;
        print("WIDTH==",width)
        return CGSize(width: width, height: height)
        
    }
    
    //uncommet when Allow multilevels
    /*func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
     switch kind {
     
     case UICollectionElementKindSectionHeader:
     
     let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath as IndexPath) as! HeaderView
     let titleTxt = "Level "+currentLevelsArray[indexPath.section]
     
     headerView.headerLbl.text = titleTxt
     return headerView
     default:break ;
     
     }
     return UICollectionReusableView()
     }*/
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let imgData = currentSourceDict[currentLevelsArray[indexPath.section]]![indexPath.row]
        let imgData = currentSourceDict[keyValue]![indexPath.row]
        if let _ = appDelegate.getImage(imgName: imgData.name!, imageId: imgData.imageId!){
            delegate?.didSelectioItem(item: imgData)
        }
    }
    
    func loadServerImage(indexPath:IndexPath, name: NSString, cell:MyWorkCell )
    {
        
        let thumName = NSString(format:"t_%@",name)
        
        let recordID = CKRecordID(recordName:thumName.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            //print("\n\n\n  Server image loaded\n\n\n")
            if let fileData = record.object(forKey: "data") as? Data {
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(thumName as String)
                
                let fileManager = FileManager.default
                
                if !fileManager.fileExists(atPath: paths){
                    fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
                }
                DispatchQueue.main.async {
                    cell.loader.stopAnimating()
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.00001 , execute: {
                    self.collectionView?.reloadItems(at: [indexPath])
                   // print("\n\n\n  Reloading collection View\n\n\n")
                })
            }
            //print("The user record is: \(record)")
        }
        
        let recordID2 = CKRecordID(recordName:name.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID2) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            //print("\n\n\n  saving image to Server image\n\n\n")
            let fileData = record.object(forKey: "data") as! Data
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name as String)
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: paths){
                fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            }
            //print("The user record is: \(record)")
        }
    }
    
}
