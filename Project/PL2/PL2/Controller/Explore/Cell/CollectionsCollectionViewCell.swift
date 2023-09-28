//
//  CollectionsCollectionViewCell.swift
//  InPower
//
//  Created by Saddam Khan on 5/31/21.
//  Copyright © 2021 iPHSTech31. All rights reserved.
//

import UIKit
import CloudKit

protocol CollectionsCollectionViewDelegate {
    func viewAllButtonTapped(currentOrientation: Bool)
}

class CollectionsCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var allCollectionsLabel: UILabel!
    
    var groupDataArray = [ExploreData]()
    var groupName: String = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var delegate: CollectionsCollectionViewDelegate!
    
    //MARK: UICollectionViewDataSource & UICollectionViewDelegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCell
        cell.containerView.backgroundColor = .white
        cell.containerView.layer.cornerRadius = 8.0
        cell.groupImage.layer.cornerRadius = 8.0
        
        if(groupDataArray[indexPath.item].nc != nil && groupDataArray[indexPath.item].nc! > 0){
            cell.newButton.isHidden = false
        }
        else{
            cell.newButton.isHidden = true
        }
        
        if cell.groupImage.tag != 101 {
            cell.layoutIfNeeded()
            let view = UIView(frame: CGRect(x: 0, y: 0, width: cell.groupImage.bounds.width + 16, height: cell.groupImage.bounds.height))
            let gradient = CAGradientLayer()
            gradient.frame = view.frame
            gradient.colors = [#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
            gradient.locations = [0.0, 1.0]
            view.layer.insertSublayer(gradient, at: 0)
            cell.groupImage.addSubview(view)
            cell.groupImage.bringSubview(toFront: view)
            cell.groupImage.tag = 101
        }
        
        cell.backgroundColor = collectionBGColor
        let line1  = NSLocalizedString(groupDataArray[indexPath.item].category.capitalizingFirstLetter(), comment: "")
        let line2  = NSLocalizedString("Collection", comment: "")
        let cateogryName = "\(line1)\n\(line2)"
        cell.groupName.text =  cateogryName
        if UIDevice.current.userInterfaceIdiom == .pad{
           // cell.groupImage.image = UIImage(named: groupDataArray[indexPath.item].name+"-ipad")!
            cell.loader.startAnimating()
            cell.groupImage.image = nil
            let imgName = groupDataArray[indexPath.item].name+"-ipad"
            if let img = appDelegate.getExploreImage(imgName: imgName){
                cell.groupImage.image = img
                if img.size.height > 1{
                    cell.loader.stopAnimating()
                   
                } else{
                    cell.loader.startAnimating()
                   
                }
            }
            else
            {
                self.loadServerImage(indexPath: indexPath, name: imgName as NSString, cell:cell)
            }
            cell.groupName.font =  UIFont.systemFont(ofSize: CGFloat(16), weight: .semibold)
        }
        else {
            cell.loader.startAnimating()
            cell.groupImage.image = nil
            let imgName = groupDataArray[indexPath.item].name+"-iphone"
            if let img = appDelegate.getExploreImage(imgName: imgName){
                cell.groupImage.image = img
                if img.size.height > 1{
                    cell.loader.stopAnimating()
                    
                } else{
                    cell.loader.startAnimating()
                    
                }
            }
            else
            {
                self.loadServerImage(indexPath: indexPath, name: imgName as NSString, cell:cell)
            }
        
        }
        
        //MARK: Collection Cell Spacing.
        if indexPath.item == 0 {
            cell.containerViewLeading.constant = 16
            print(cell.containerView.frame.width)
        }
        else {
            cell.containerViewLeading.constant = 12
            print(cell.containerView.frame.width)
        }
        //End: Collection Cell Spacing.
        
        if indexPath.item == self.groupDataArray.count - 1 {
            cell.containerViewTrailing.constant = 16.0
        }
        else {
            cell.containerViewTrailing.constant = 0.0
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        if( groupDataArray[indexPath.item].category.lowercased()=="journy"){
            return
        }
        
        let category = groupDataArray[indexPath.item].category.lowercased()
        var collectionArray = UserDefaults.standard.object(forKey: viewedInCollection) as? [String]
    
         if let itemArray = collectionArray {
            if(!itemArray.contains(category)){
                collectionArray!.append(category)
            }
            
            UserDefaults.standard.set(collectionArray, forKey: viewedInCollection)
         }else{
            collectionArray = [String]()
            collectionArray!.append(category)
            UserDefaults.standard.set(collectionArray, forKey: viewedInCollection)
            
         }
        
        
        viewedCollectionLogEvent()
        
           
        
        
        self.appDelegate.logEvent(name: "Explore_Collections", category: "Explore", action: "Tapping in Collections")
        
        UserDefaults.standard.set(0, forKey: "SELECTED_CATEGORY_INDEX")
        UserDefaults.standard.set(category, forKey: "SELECTED_CATEGORY_NAME")
        UserDefaults.standard.synchronize()
        if(appDelegate.pagesVC == nil){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "active_Pages_TabBar"), object: indexPath.item)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1)
            {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "show_selected_category"), object: nil)
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1)
            {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "show_selected_category"), object: nil)
            }
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0 {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 180.0+22-8, height: 180.0)
            }
            else{
                return CGSize(width: 130.0+22-8, height: 130.0)
            }
        }
        else if indexPath.item == self.groupDataArray.count - 1 {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 180.0+26, height: 180.0)
            }
            else{
                return CGSize(width: 130.0+26, height: 130.0)
            }
        }
        else {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 180.0+10, height: 180.0)
            }
            else{
                return CGSize(width: 130.0+10, height: 130.0)
            }
        }
    }
    
    
    
    func viewedCollectionLogEvent()
    {
        
        let collectionArray = UserDefaults.standard.object(forKey: viewedInCollection) as? [String]

        if let itemArray = collectionArray {
            if(itemArray.count == 0 ){
                return
            }
            else if(itemArray.count <= 5 )
            {
                self.appDelegate.logEvent(name: "collection_L1", category: "Explore Collection", action: "Collection")
            }
            else if(itemArray.count > 5 && itemArray.count <= 10 )
            {
                self.appDelegate.logEvent(name: "collection_L2", category: "Explore Collection", action: "Collection")
            }
            else
            {
                self.appDelegate.logEvent(name: "collection_L3", category: "Explore Collection", action: "Collection")
            }
        }
    }
    
    
    func loadServerImage(indexPath:IndexPath, name: NSString, cell:SliderCell )
    {
        
        let thumName = NSString(format:"%@",name)
        
        let recordID = CKRecordID(recordName:thumName.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
           
            if let fileData = record.object(forKey: "data") as? Data {
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(thumName as String)
                
                let fileManager = FileManager.default
                
                if !fileManager.fileExists(atPath: paths){
                    fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
                }
                DispatchQueue.main.async {
                    print("\n\n\n  Server image loaded:",thumName,"\n\n\n")
                    cell.loader.stopAnimating()
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.00001 , execute: {
                   
                   
                    self.sliderCollectionView?.reloadItems(at: [indexPath])
                   
                })
            }
            
        }
    }
   
    @IBAction func viewAllButtonTapped(_ sender: UIButton) {
        print("viewAllButtonTapped")
        
        let orientation = UIDevice.current.orientation
        
        if orientation.isPortrait {
            print("isPortrait")
            potraitOrientation = true
            landsacpeOrientation = false
            
            delegate?.viewAllButtonTapped(currentOrientation: true)
        }
        else if orientation.isLandscape {
            print("isLandscape")
            landsacpeOrientation = true
            potraitOrientation = false
            
            delegate?.viewAllButtonTapped(currentOrientation: false)
        }
        else if orientation.isFlat {
            print("isFlat")
            if potraitOrientation == true {
                landsacpeOrientation = false
                delegate?.viewAllButtonTapped(currentOrientation: true)
            } else if landsacpeOrientation == true {
                potraitOrientation = false
                delegate?.viewAllButtonTapped(currentOrientation: false)
            }
            else {
                delegate?.viewAllButtonTapped(currentOrientation: true)
            }
        }
        
    }
}
