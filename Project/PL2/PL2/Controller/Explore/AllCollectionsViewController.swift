//
//  AllCollectionsViewController.swift
//  PL2
//
//  Created by iPHTech38 on 30/08/22.
//  Copyright © 2022 IPHS Technologies. All rights reserved.
//

import UIKit
import CloudKit

class AllCollectionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var leftLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var rightLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var topHeightSpace: NSLayoutConstraint!

    var groupDataArray = [ExploreData]()
    var groupName: String = ""
    
    var currentOrientationValue = true
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.sliderCollectionView.delegate = self
        self.sliderCollectionView.dataSource = self
        
        self.view.backgroundColor = editorBGColor
        self.sliderCollectionView.backgroundColor = editorBGColor
        
        headerLabel.text = NSLocalizedString("Explore",comment:"")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadOrientationChange()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape == true {
            print("Landscape")
            currentOrientationValue = false
            reloadOrientationChange()
            self.sliderCollectionView.reloadData()
        } else if UIDevice.current.orientation.isPortrait == true {
            print("Portrait")
            currentOrientationValue = true
            reloadOrientationChange()
            self.sliderCollectionView.reloadData()
        }
        else if UIDevice.current.orientation.isFlat {
            if potraitOrientation == true {
                landsacpeOrientation = false
                currentOrientationValue = true
                reloadOrientationChange()
            } else if landsacpeOrientation == true {
                potraitOrientation = false
                currentOrientationValue = false
                reloadOrientationChange()
            }
            else {
                currentOrientationValue = true
                reloadOrientationChange()
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
        DispatchQueue.main.async {            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_explore"), object: nil)
        }
    }
        
    //MARK: UICollectionViewDataSource & UICollectionViewDelegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllCollectionsViewCell", for: indexPath) as! AllCollectionsViewCell
        cell.containerView.backgroundColor = editorBGColor
        cell.containerView.layer.cornerRadius = 8.0
        cell.groupImage.layer.cornerRadius = 8.0
        
        cell.groupName.adjustsFontSizeToFitWidth = true
        
        if cell.groupImage.tag != 101 {
            cell.layoutIfNeeded()
            let view = UIView(frame: CGRect(x: 0, y: 0, width: cell.groupImage.bounds.width, height: cell.groupImage.bounds.height))
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: cell.groupImage.bounds.width + 100 , height: cell.groupImage.bounds.height + 100)
            gradient.colors = [#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
            gradient.locations = [0.0, 1.0]
            view.layer.insertSublayer(gradient, at: 0)
            cell.groupImage.addSubview(view)
            cell.groupImage.bringSubview(toFront: view)
            cell.groupImage.tag = 101
        }
        
        cell.backgroundColor = editorBGColor
        let line1  = NSLocalizedString(groupDataArray[indexPath.item].category.capitalizingFirstLetter(), comment: "")
        let line2  = NSLocalizedString("Collection", comment: "")
        let cateogryName = "\(line1)\n\(line2)"
        cell.groupName.text =  cateogryName
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
        print(cell.containerView.frame.width)
        
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
        
        var noOfRows:CGFloat = 2.0
        
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            if !(currentOrientationValue) {
                noOfRows = 5.0
                
            }
            else {
                noOfRows = 4.0
                
            }

            let width  = self.sliderCollectionView.bounds.size.width/noOfRows - middle_spacing_ipad + 12
            let height = width - 7
            print("\(height), \(width)")
            return CGSize(width: width, height: height)
        }
        else {
            noOfRows = 3.0
            var width  = self.sliderCollectionView.bounds.size.width/noOfRows
            var height = width
            var offset = 0
            let max_width = 280
            offset = Int(height) > Int(max_width) ? (Int(height) - Int(max_width)) : 0
            width = width - CGFloat(offset)
            height = width - 9
            print("\(height), \(width)")
            return CGSize(width: width, height: height)
        }
    }
    
    fileprivate func  reloadOrientationChange() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        var noOfRows:CGFloat = 2.0
        
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            layout.minimumLineSpacing = middle_spacing_ipad
            layout.minimumInteritemSpacing = 0
            
            if !(currentOrientationValue) {
                noOfRows = 5.0
                
                leftLeadingSpace.constant = side_spacing_landscape - 10
                rightLeadingSpace.constant = side_spacing_landscape
                topHeightSpace.constant = 42
            }
            else {
                noOfRows = 4.0
                leftLeadingSpace.constant = side_spacing_potrait - 10
                rightLeadingSpace.constant = side_spacing_potrait
                topHeightSpace.constant = 42

            }
            
            let width  = self.sliderCollectionView.bounds.size.width/noOfRows - middle_spacing_ipad + 12
            let height = width - 7
            let offset = 0
            let margin:CGFloat = (CGFloat(offset)*noOfRows)/2 + 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: margin, right: margin)
            layout.itemSize = CGSize(width: width, height: height)
            
        }
        else {
            leftLeadingSpace.constant = side_spacing_ios - 10
            rightLeadingSpace.constant = side_spacing_ios
            topHeightSpace.constant = 45
            
            layout.minimumLineSpacing = middle_spacing_iphone - 5
            layout.minimumInteritemSpacing = 0
            var width  = self.sliderCollectionView.bounds.size.width/noOfRows
            var height = width
            var offset = 0
            let max_width = 280
            offset = Int(height) > Int(max_width) ? (Int(height) - Int(max_width)) : 0
            width = width - CGFloat(offset)
            height = width - 9
            let margin:CGFloat = (CGFloat(offset)*noOfRows)/2
            layout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: margin, right: margin)
            layout.itemSize = CGSize(width: width, height: height)
        }
        
        self.sliderCollectionView.collectionViewLayout = layout
        layout.invalidateLayout()
        
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
    
    
    func loadServerImage(indexPath:IndexPath, name: NSString, cell:AllCollectionsViewCell )
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
    
}
