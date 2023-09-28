//
//  SliderCollectionViewCell.swift
//  InPower
//
//  Created by Saddam Khan on 5/31/21.
//  Copyright © 2021 iPHSTech31. All rights reserved.
//

import UIKit
import CloudKit

class SliderCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var groupDataArray = [ExploreData]()
    var groupName: String = ""
  
    
    //MARK: UICollectionViewDataSource & UICollectionViewDelegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCell
       // cell.tag = 101
        cell.backgroundColor = editorBGColor
        // let placeholderImage = UIImage(named: "FeedGroup1")!
        cell.groupName.text = NSLocalizedString(groupDataArray[indexPath.item].category.capitalizingFirstLetter(), comment:"")
        
        if(groupDataArray[indexPath.item].nc != nil && groupDataArray[indexPath.item].nc! > 0){
            cell.newButton.isHidden = false
        }
        else{
            cell.newButton.isHidden = true
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            
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
        
        cell.groupName.adjustsFontSizeToFitWidth = true
        
        cell.groupImage.layer.cornerRadius = 16.0
        
        if indexPath.item == self.groupDataArray.count - 1 {
            cell.containerViewTrailing.constant = 16.0
        }
        else {
            cell.containerViewTrailing.constant = 0.0
        }
       
        if cell.groupImage.tag != 101 {
            cell.layoutIfNeeded()
            let view = UIView(frame: cell.groupImage.bounds)
            let gradient = CAGradientLayer()
            gradient.frame = view.frame
            gradient.colors = [#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
            gradient.locations = [0.0, 1.0]
            gradient.opacity = 0.2
            view.layer.insertSublayer(gradient, at: 0)
            cell.groupImage.addSubview(view)
            cell.groupImage.bringSubview(toFront: view)
            cell.groupImage.tag = 101
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        if( groupDataArray[indexPath.item].category.lowercased()=="journy"){
            return
        }
        self.appDelegate.logEvent(name: "Explore_Editor", category: "Explore", action: "Tapping the Editor")
        
        UserDefaults.standard.set(0, forKey: "SELECTED_CATEGORY_INDEX")
        UserDefaults.standard.set(groupDataArray[indexPath.item].category.lowercased(), forKey: "SELECTED_CATEGORY_NAME")
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
        
        if indexPath.item == self.groupDataArray.count - 1 {
            
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 300.0+16+16, height: 300)
            }
            else {
                return CGSize(width: 220.0+16+16, height: 220)
            }
        }
        else {
            
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 300.0+16, height: 300)
            }
            else {
                return CGSize(width: 220.0+16, height: 220)
            }
        }


    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(groupName == "Editor's Picks"){
            var visibleRect = CGRect()
            
            visibleRect.origin = sliderCollectionView.contentOffset
            visibleRect.size = sliderCollectionView.bounds.size
            
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            //        let visiblePoint = CGPoint(x: visibleRect.maxX, y: visibleRect.midY)
            
            guard let indexPath = sliderCollectionView.indexPathForItem(at: visiblePoint) else { return }
           
            pageController.currentPage = indexPath.item
        }
        
    }
    
    //MARK:- AutoScroller for editor's collection
    var topTimer: Timer?
    var isTopScrolllingApplied = false
    var isTopShowOrNot = true
    var topCounter = 1
    
    func applyTopViewScrolling() {
        isTopScrolllingApplied = true
        self.topTimer?.invalidate()
        self.topTimer = nil
        self.topTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.autoScrollTopView), userInfo: nil, repeats: true)
        
    }
    
    func removeTopViewScrolling() {
        
        isTopScrolllingApplied = false
        self.topTimer?.invalidate()
        self.topTimer = nil
        
    }
    
    @objc func autoScrollTopView() {
        //if (appDelegate.isReloadNeeded) {
        //  self.reloadView()
        //}
        
        if isTopShowOrNot == true {
            if topCounter < groupDataArray.count {
                if let index = IndexPath.init(item: topCounter, section: 0) as? IndexPath {
                    if index.item < sliderCollectionView.numberOfItems(inSection: 0) {
                        if(self.sliderCollectionView.indexPathsForVisibleItems.contains(index)) {
                            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                            topCounter += 1
                        }
                    }
                }
            }
            else {
                topCounter = 0
                if let index = IndexPath.init(item: topCounter, section: 0) as? IndexPath {
                    if index.item < sliderCollectionView.numberOfItems(inSection: 0) {
                        if index.item < sliderCollectionView.numberOfItems(inSection: 0) {
                            if !(self.sliderCollectionView.indexPathsForVisibleItems.contains(index)) {
                                self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                                topCounter = 1
                            }
                        }
                    }
            }
        }
    }
    }
    
    
    func loadServerImage(indexPath:IndexPath, name: NSString, cell:SliderCell )
    {
        let thumName = NSString(format:"%@",name)
        let recordID = CKRecordID(recordName:thumName.deletingPathExtension)
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                return
            }
           // print("\n\n\n  Server image loaded\n\n\n")
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

                    if( self.sliderCollectionView != nil){
                      self.sliderCollectionView.reloadItems(at: [indexPath])
                    }
                  
                })
            }
          
        }
    }

    
}
