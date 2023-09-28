//
//  GifTutorialVC.swift
//  PL2
//
//  Created by iPHTech2 on 03/12/18.
//  Copyright © 2018 IPHS Technologies. All rights reserved.
//

import UIKit


protocol GifTutorialCloseTappedDelegate:class {
    func GifTutorialCloseTapped()
    func GifTutorialGetActiveIndex(activeIndex : Int, toolImage:UIImageView)
    
    
}
class GifTutorialVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var gifCollectionView: UICollectionView!
    @IBOutlet weak var toolImage: UIImageView!
    
    var tutorialData = [TutorialData]()
    var isCancelImageVisible = false
    var iPhoneFontSemiBold : UIFont = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
    var iPadFontVerticalSemiBold : UIFont = UIFont.systemFont(ofSize: 19.0, weight: .semibold)
    var iPadFontHorizontalSemiBold : UIFont = UIFont.systemFont(ofSize: 17.5, weight: .semibold)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    weak var gifTutorialCloseTappedDelegate:GifTutorialCloseTappedDelegate?
    
    var cellWidthInLandscape: CGFloat = 0 {
        didSet {
            self.gifCollectionView.reloadData()
        }
    }
    
    var loadFrom :String = ""
    var lastIndex: Int = 0
    var isFistLaunch : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(loadFrom == "Pages")
        {
            toolImage.isHidden = true
            self.loadTutorialData(index: 1,title: "\(step1_line1)\n\(step1_line2)")
            self.loadTutorialData(index: 2,title: "\(step2_line1)\n\(step2_line2)")
            self.loadTutorialData(index: 3,title: "\(step3_line1)\n\(step3_line2)\n\(step3_line3)")
            self.loadTutorialData(index: 4,title: "\(step4_line1)\n\(step4_line2)")
            self.loadTutorialData(index: 5,title: "\(step7_line1)\n\(step7_line2)")
        }else if(loadFrom == "Home")
        {
            
            self.loadTutorialData(index: 7,title: "\(step5_line1)\n\(step5_line2)")
            self.loadTutorialData(index: 6,title: "\(step6_line1)\n\(step6_line2)")
        }
        else if(loadFrom == "Existing")
        {
            self.loadTutorialData(index: 5,title: "\(step7_line1)\n\(step7_line2)")
        }
        else{
            toolImage.isHidden = true
            self.loadTutorialData(index: 1,title: "\(step1_line1)\n\(step1_line2)")
            self.loadTutorialData(index: 2,title: "\(step2_line1)\n\(step2_line2)")
            self.loadTutorialData(index: 3,title: "\(step3_line1)\n\(step3_line2)\n\(step3_line3)")
            self.loadTutorialData(index: 4,title: "\(step4_line1)\n\(step4_line2)")
            self.loadTutorialData(index: 5,title: "\(step7_line1)\n\(step7_line2)")
            self.loadTutorialData(index: 7,title: "\(step5_line1)\n\(step5_line2)")
            self.loadTutorialData(index: 6,title: "\(step6_line1)\n\(step6_line2)")
           
            
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTutorial(notification:)), name: NSNotification.Name(rawValue: "totorial_refresh"), object: nil)
        // Do any additional setup after loading the view.
        gifCollectionView.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(gifCollectionViewReLoad(notification:)), name: NSNotification.Name(rawValue: "gif_Collection_View_ReLoad"), object: nil)
        
    }
    
    var temcounter: Int = 0
    @objc func refreshTutorial(notification: NSNotification)
    {
        print("refreshTutorial")
        cellWidthInLandscape = UIScreen.main.bounds.size.width
        let layout: UICollectionViewFlowLayout = self.gifCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = self.gifCollectionView.bounds.size
        self.gifCollectionView.collectionViewLayout = layout
        self.gifCollectionView.reloadData()
        self.gifCollectionView.scrollToItem(at: IndexPath(item: lastIndex, section: 0), at: .right, animated: false)
        gifTutorialCloseTappedDelegate?.GifTutorialGetActiveIndex(activeIndex: lastIndex,toolImage:toolImage)
        temcounter = temcounter+1
        print(temcounter)
    }
    
    @objc func gifCollectionViewReLoad(notification: NSNotification)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3)
        {
            self.gifTutorialCloseTappedDelegate?.GifTutorialGetActiveIndex(activeIndex: self.lastIndex,toolImage:self.toolImage)
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if(isFistLaunch){
            print("viewDidLayoutSubviews")
            cellWidthInLandscape = UIScreen.main.bounds.size.width
            let layout: UICollectionViewFlowLayout = self.gifCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = self.gifCollectionView.bounds.size
            self.gifCollectionView.collectionViewLayout = layout
            self.gifCollectionView.reloadData()
            self.gifCollectionView.scrollToItem(at: IndexPath(item: lastIndex, section: 0), at: .right, animated: false)
            gifTutorialCloseTappedDelegate?.GifTutorialGetActiveIndex(activeIndex: lastIndex,toolImage:toolImage)
            isFistLaunch = false
            toolImage.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        if(self.loadFrom == "Home"){
            self.gifCollectionView.scrollToItem(at: IndexPath(item: lastIndex, section: 0), at: .right, animated: false)
            gifTutorialCloseTappedDelegate?.GifTutorialGetActiveIndex(activeIndex: lastIndex,toolImage:toolImage)
            toolImage.isHidden = false
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        lastIndex = Int(scrollView.contentOffset.x / self.gifCollectionView.bounds.width)
        gifTutorialCloseTappedDelegate?.GifTutorialGetActiveIndex(activeIndex: lastIndex,toolImage:toolImage)
        //        for cell in gifCollectionView.visibleCells {
        //            let indexPath = gifCollectionView.indexPath(for: cell)
        //            if(indexPath?.row == tutorialData.count-1)
        //            {
        //                self.isCancelImageVisible = true
        //                let dt = cell as! GifCollectionCell
        //                dt.cancelButton.isHidden = false
        //            }
        //        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Setting new width of collectionView Cell
        return CGSize(width: cellWidthInLandscape, height: collectionView.bounds.size.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 7
        return tutorialData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.gifCollectionView.dequeueReusableCell(withReuseIdentifier: "gifCell",for: indexPath) as! GifCollectionCell
        
        let newTutorialData = self.tutorialData[indexPath.row]
        if(indexPath.row == 1 && loadFrom == "Home"){
            self.toolImage.isHidden = true
        }
        
//        cell.gifImageView.layer.borderWidth = 1.0
//        cell.gifImageView.layer.borderColor = UIColor.black.cgColor
//        cell.descriptionLabel.backgroundColor = .systemBlue

        cell.gifImageView.loadGif(name: newTutorialData.image)
        cell.descriptionLabel.numberOfLines = 6;
        cell.descriptionLabel.text = newTutorialData.title
        cell.pageControl.numberOfPages = tutorialData.count
        
        if indexPath.row == tutorialData.count-1 {
            self.isCancelImageVisible = true
        }
        if self.isCancelImageVisible
        {
            cell.cancelButton.isHidden = false
        }
        
        
        if (UI_USER_INTERFACE_IDIOM() == .pad){
//            if self.appDelegate.isLandscapeByMe()
//            {
//                cell.descriptionLabel.font = iPadFontHorizontalSemiBold
//            }
//            else
//            {
//                cell.descriptionLabel.font = iPadFontVerticalSemiBold
//            }
            cell.descriptionLabel.font = iPadFontVerticalSemiBold

        }
        else
        {
            cell.descriptionLabel.font = UIFont.systemFont(ofSize: 14.0)
            //cell.descriptionLabel.font = iPhoneFontSemiBold
            
            
        }
        
        cell.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cell.pageControl.currentPage = indexPath.row
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 1136 {
                if currentView == CurrentViewController.kHome.rawValue {
                    cell.containerViewTop.constant = 50
                    cell.containerViewBottom.constant = 125
                }
                else {
                    cell.containerViewTop.constant = 60
                    cell.containerViewBottom.constant = 120
                }
            }
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            
                if currentView == CurrentViewController.kHome.rawValue {
                    
                    if UIDevice.current.orientation.isLandscape {
                        cell.containerViewTop.constant = 50
                        cell.containerViewBottom.constant = 125
                    }
                    else {
                        cell.containerViewTop.constant = 80
                        cell.containerViewBottom.constant = 138
                    }
                }
                else {
                    if UIDevice.current.orientation.isLandscape {
                        cell.containerViewTop.constant = 10
                        cell.containerViewBottom.constant = 65
                    }
                    else {
                        cell.containerViewTop.constant = 80
                        cell.containerViewBottom.constant = 138
                    }
            }
            
        }
        
        
        return cell
    }
    
    
    @objc func cancelButtonTapped(sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
        gifTutorialCloseTappedDelegate?.GifTutorialCloseTapped()
    }
    
    
    fileprivate func loadTutorialData(index:Int,title:String) {
        let _tutorialData = TutorialData()
        if(UI_USER_INTERFACE_IDIOM() == .pad)
        {
            _tutorialData.image = "step_\(index)_ipad"
            _tutorialData.isIpad = true
        }
        else{
            _tutorialData.image = "step_\(index)"
            _tutorialData.isIpad = false
        }
        _tutorialData.title = title
        self.tutorialData.append(_tutorialData)
    }
    
}
