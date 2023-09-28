//
//  TutorialViewController.swift
//  PL2
//
//  Created by Lekha Mishra on 12/11/17.
//  Copyright © 2017 IPHS Technologies. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var tutCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imgArray = [String]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UI_USER_INTERFACE_IDIOM() == .pad){

            if appDelegate.isLandscapeByMe()
            {
                imgArray = ["tutorial1-ipadh","tutorial2-ipadh","tutorial3-ipadh","tutorial4-ipadh","tutorial5-ipadh","tutorial6-ipadh","tutorial7-ipadh"]
            }
            else
            {
                imgArray = ["tutorial1-ipadv","tutorial2-ipadv","tutorial3-ipadv","tutorial4-ipadv","tutorial5_ipadv","tutorial6_ipadv"]
            }
        }
        else
        {
             imgArray = ["tutorial1","tutorial2","tutorial3","tutorial4","tutorial5","tutorial6","tutorial7"]
        }
      
        appDelegate.logScreen(name: "Tutorial 1")
        self.pageControl.numberOfPages = imgArray.count
        self.tutCollectionView.register(UINib(nibName : "TutorialCell" , bundle : nil), forCellWithReuseIdentifier:"TutorialCell" )
        //NotificationCenter.default.addObserver(self, selector: #selector(refreshTutorial(notification:)), name: NSNotification.Name(rawValue: "totorial_refresh"), object: nil)
        // Do any additional setup after loading the view.
    }

//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarningTutorial Shoaib")
        // Dispose of any resources that can be recreated.

    }

    @objc func refreshTutorial(notification: NSNotification)
    {
        if (UI_USER_INTERFACE_IDIOM() == .pad){

            imgArray.removeAll()
            if appDelegate.isLandscapeByMe()
            {
                imgArray = ["tutorial1-ipadh","tutorial2-ipadh","tutorial3-ipadh","tutorial4-ipadh","tutorial5-ipadh","tutorial6-ipadh"]
            }
            else
            {
                 imgArray = ["tutorial1-ipadv","tutorial2-ipadv","tutorial3-ipadv","tutorial4-ipadv","tutorial5_ipadv","tutorial6_ipadv"]
            }
            self.pageControl.numberOfPages = imgArray.count
            self.viewDidLayoutSubviews()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout: UICollectionViewFlowLayout = self.tutCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = self.tutCollectionView.bounds.size
        self.tutCollectionView.collectionViewLayout = layout
        self.tutCollectionView.reloadData()
        let indexPath = IndexPath(item: self.pageControl.currentPage, section: 0)
        self.tutCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UICollectionViewDelegate Methods-
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.imgArray.count)
    }
    
    func collectionView(_ collectionVie: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "TutorialCell"
        let cell = self.tutCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,for: indexPath) as! TutorialCell
        
        cell.imgView.image  = UIImage(named:self.imgArray[indexPath.row])
        return cell
        
    }
    
    // MARK: - UIScrollViewDelegate Methods-
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentIndex = self.tutCollectionView.contentOffset.x / self.tutCollectionView.frame.size.width;
        
        if(Int(currentIndex) != self.pageControl.currentPage)
        {
            if currentIndex == 0 {
                appDelegate.logScreen(name: "Tutorial 1")
            }
            else if currentIndex == 1 {
                appDelegate.logScreen(name: "Tutorial 2")
            }
            else if currentIndex == 2 {
                appDelegate.logScreen(name: "Tutorial 3")
            }
        }
        self.pageControl.currentPage = Int(currentIndex)
        
    }
    
    // MARK: - IBActions
    
    @IBAction func pageControlClicked(_ sender: Any) {
        let indexPath = IndexPath(item: self.pageControl.currentPage, section: 0)
        self.tutCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        if self.pageControl.currentPage == 0 {
            appDelegate.logScreen(name: "Tutorial 1")
        }
        else if self.pageControl.currentPage == 1 {
            appDelegate.logScreen(name: "Tutorial 2")
        }
        else if self.pageControl.currentPage == 2 {
            appDelegate.logScreen(name: "Tutorial 3")
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}
