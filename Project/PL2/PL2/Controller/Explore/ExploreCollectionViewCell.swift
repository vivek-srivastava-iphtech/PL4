//
//  ExploreCollectionViewCell.swift
//  PL2
//
//  Created by iPHTech25 on 18/05/21.
//  Copyright © 2021 IPHS Technologies. All rights reserved.
//

import UIKit

class ExploreCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var discoverCellCollectionView: UICollectionView!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var cellHeaderHeight: NSLayoutConstraint!
    // @IBOutlet weak var cellHeaderMarginHeight: NSLayoutConstraint!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var groupDataArray = [ExploreData]()
    var groupName: String = ""
    var pagesVC: PagesVC!
    
    //MARK: UICollectionViewDataSource & UICollectionViewDelegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if( groupName=="Journey"){
            return 1
        }
        else{
            
            return groupDataArray.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        if( groupDataArray[indexPath.item].category.lowercased()=="journy"){
            return
        }
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(groupName == "Editor's Picks"){
            var visibleRect = CGRect()
            
            visibleRect.origin = discoverCellCollectionView.contentOffset
            visibleRect.size = discoverCellCollectionView.bounds.size
            
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            //        let visiblePoint = CGPoint(x: visibleRect.maxX, y: visibleRect.midY)
            
            guard let indexPath = discoverCellCollectionView.indexPathForItem(at: visiblePoint) else { return }
            print(indexPath.item)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "change_Page_Control"), object: indexPath.item)
        }
        
    }
    
    //    func collectionView(_ collectionView: UICollectionView,
    //                        layout collectionViewLayout: UICollectionViewLayout,
    //                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return 1.0
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                            collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(groupName == "Editor's Picks"){
            return 10
        }else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreItemCell", for: indexPath) as! ExploreItemCell
        
        cell.customContentView.backgroundColor = .white
        if UIDevice.current.userInterfaceIdiom == .pad{
            // if( UIImage(named: groupDataArray[indexPath.item].name+"-ipad") != nil){
            cell.groupImage.image = UIImage(named: groupDataArray[indexPath.item].name+"-ipad")!
            cell.categoryImage.image = UIImage(named: groupDataArray[indexPath.item].name+"-ipad")!
            
            //            }
            //            else{
            //               // cell.groupImage.image = nil
            //               // cell.categoryImage.image = nil
            //                if let img = appDelegate.getImage(imgName: groupDataArray[indexPath.item].name, imageId: groupDataArray[indexPath.item].name){
            //
            //                    cell.categoryImage.image = img
            //                    if img.size.height > 1{
            //                        //cell.loader.stopAnimating()
            //                    } else{
            //                        //                cell.loader.startAnimating()
            //                    }
            //
            //                }
            //            }
            
        }
        else {
            cell.groupImage.image = UIImage(named: groupDataArray[indexPath.item].name+"-iphone")!
            cell.categoryImage.image = UIImage(named: groupDataArray[indexPath.item].name+"-iphone")!
        }
        
        cell.customContentView.layer.cornerRadius = 10.0
        cell.groupImage.layer.cornerRadius = 5.0
        if(groupName == "Editor's Picks"){
            cell.customContentView.backgroundColor = .white
            cell.customContentView.layer.cornerRadius = 25.0
            cell.groupDescription.isHidden = true
            cell.categoryImage.isHidden = true
            cell.categoryLable.text = NSLocalizedString(groupDataArray[indexPath.item].category.capitalizingFirstLetter(), comment:"")
            cell.categoryLable.font = UIFont.systemFont(ofSize: CGFloat(20), weight: .semibold)
            cell.categoryLable.textColor = .white
        }
        else if(groupName == "Popular" || groupName == "Recent"){
            cell.groupDescription.isHidden = true
            cell.groupImage.isHidden = false
            cell.categoryImage.isHidden = true
            cell.categoryLable.isHidden = false
            cell.groupImage.tag = 101
            cell.categoryLable.text = NSLocalizedString(groupDataArray[indexPath.item].category.capitalizingFirstLetter(), comment:"")
            cell.categoryLable.lineBreakMode = .byWordWrapping
            cell.categoryLable.numberOfLines = 0
            cell.categoryLable.textAlignment = .center
            cell.categoryLable.font = UIFont.systemFont(ofSize: CGFloat(12), weight: .regular)
        }
        else if(groupName == "Collections"){
            cell.categoryImage.isHidden = true
            cell.categoryLable.isHidden = true
            cell.categoryLable.isHidden = false
            cell.groupDescription.isHidden = true
            cell.groupImage.isHidden = false
            cell.categoryLable.lineBreakMode = .byWordWrapping
            cell.categoryLable.numberOfLines = 0
            cell.categoryLable.textAlignment = .center
            cell.categoryLable.textColor = .white
            
            let line1  = NSLocalizedString(groupDataArray[indexPath.item].category.capitalizingFirstLetter(), comment: "")
            let line2  = NSLocalizedString("Collection", comment: "")
            let cateogryName = "\(line1)\n\(line2)"
    
            cell.categoryLable.text =  cateogryName
            cell.categoryLable.font = UIFont.systemFont(ofSize: CGFloat(14), weight: .semibold)
            cell.categoryLable.adjustsFontSizeToFitWidth = true
            
        }
        else {
            cell.categoryImage.isHidden = true
            cell.categoryLable.isHidden = true
            cell.groupDescription.isHidden = true
            cell.groupImage.isHidden = true
            cell.customContentView.backgroundColor = .clear
            if let nameLabel = cell.viewWithTag(123){
                nameLabel.removeFromSuperview()
            }
            
            
            
            let contentViewSub = UIView(frame: CGRect(x: 20, y: 0, width: contentView.frame.width - 20, height: 20))
            contentViewSub.backgroundColor = UIColor(red: 0.95, green: 0.80, blue: 0.58, alpha: 1.00)
            cell.customContentView.addSubview(contentViewSub)
            contentViewSub.translatesAutoresizingMaskIntoConstraints = false
            contentViewSub.tag = 123
            contentViewSub.heightAnchor.constraint(equalToConstant: 100).isActive = true
            contentViewSub.widthAnchor.constraint(equalToConstant: contentView.frame.width*0.8).isActive = true
            contentViewSub.centerYAnchor.constraint(equalTo: cell.customContentView.centerYAnchor).isActive = true
            contentViewSub.centerXAnchor.constraint(equalTo: cell.customContentView.centerXAnchor).isActive = true
            contentViewSub.layer.cornerRadius = 10
            
            if let nameLabel = cell.viewWithTag(786) as? UILabel{
                nameLabel.removeFromSuperview()
            }
            
            if let jButton = cell.viewWithTag(92) as? UIButton{
                UIView.transition(with: self.contentView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    jButton.removeFromSuperview()
                }, completion: nil)
            }
            
            let totalWidth = contentViewSub.frame
            let journeyLable = UILabel(frame: CGRect(x: 20, y: 10, width: totalWidth.width-20, height: 20))
            let journeyButton = UIButton(frame: CGRect(x: 0, y: journeyLable.frame.height+10, width: totalWidth.width * 0.6, height: 30))
            contentViewSub.addSubview(journeyLable)
            
            journeyLable.text =  NSLocalizedString("Your journey to relexation begins here", comment: "")
            journeyLable.tag = 786;
            journeyLable.lineBreakMode = .byWordWrapping
            journeyLable.numberOfLines = 0
            journeyLable.textAlignment = .center
            journeyButton.setTitle(NSLocalizedString("Start Trial", comment:""), for: .normal)
            journeyButton.tag = 92;
            journeyButton.setTitleColor(.white, for: .normal)
            journeyButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
            journeyButton.backgroundColor = UIColor(red: 0.94, green: 0.44, blue: 0.39, alpha: 1.00)
            
            
            UIView.transition(with: self.contentView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                contentViewSub.addSubview(journeyButton)
            }, completion: nil)
            
            journeyButton.translatesAutoresizingMaskIntoConstraints = false
            journeyButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            if UIDevice.current.userInterfaceIdiom == .pad{
                journeyButton.widthAnchor.constraint(equalToConstant: contentViewSub.frame.width*0.3).isActive = true
            }
            else{
                journeyButton.widthAnchor.constraint(equalToConstant: contentViewSub.frame.width*0.6).isActive = true
            }
            journeyButton.centerXAnchor.constraint(equalTo: cell.customContentView.centerXAnchor).isActive = true
            journeyButton.bottomAnchor.constraint(equalTo: contentViewSub.bottomAnchor, constant: -20).isActive = true
            
            journeyLable.translatesAutoresizingMaskIntoConstraints = false
            journeyLable.heightAnchor.constraint(equalToConstant: 20).isActive = true
            journeyLable.widthAnchor.constraint(equalToConstant: contentViewSub.frame.width*0.7).isActive = true
            journeyLable.centerXAnchor.constraint(equalTo: cell.customContentView.centerXAnchor).isActive = true
            journeyLable.topAnchor.constraint(equalTo: contentViewSub.topAnchor, constant: 8).isActive = true
            
            journeyButton.layer.cornerRadius = 40/2
            contentViewSub.layer.cornerRadius = 20
        }
        
        return cell
    }
    
    @objc func pressed() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "free_Trial_Notification"), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(groupName == "Editor's Picks"){
            
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 300.0+10, height: 300)
            }
            else {
                return CGSize(width: 220.0+10, height: 220)
            }
        }
        else if(groupName == "Journey"){
            return CGSize(width: UIScreen.main.bounds.width-20, height: 100.0)
        }
        else if(groupName == "Collections"){
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 180.0+10, height: 180.0)
            }
            else{
                return CGSize(width: 130.0+10, height: 130.0)
            }
        }
        else {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 160.0+10, height: 160.0)
            }
            else{
                return CGSize(width: 100.0+10, height: 100.0)
            }
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
                    if index.item < discoverCellCollectionView.numberOfItems(inSection: 0) {
                        if (self.discoverCellCollectionView.indexPathsForVisibleItems.contains(index)) {
                            self.discoverCellCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                            topCounter += 1
                        }
                    }
                }
            }
            else {
                topCounter = 0
                if let index = IndexPath.init(item: topCounter, section: 0) as? IndexPath {
                    if index.item < discoverCellCollectionView.numberOfItems(inSection: 0) {
                        if !(self.discoverCellCollectionView.indexPathsForVisibleItems.contains(index)) {
                            self.discoverCellCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                            topCounter = 1
                        }
                    }
                }
            }
        }
    }
}

