//
//  CategoryViewController.swift
//  PL2
//
//  Created by iPHTech25 on 15/10/21.
//  Copyright © 2021 IPHS Technologies. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var collectionView: UICollectionView!
    lazy var contentStackView = UIStackView()
    var groupDataArray = [ExploreData]()

    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = popularBGColor
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.4
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    
    lazy var titleView:UIView = {
        let tView = UIView()
        tView.backgroundColor = .gray
//        let capsuleView = UIView()
//        capsuleView.frame = CGRect(x: (self.view.frame.width/2)-50, y: 10, width: 100, height: 10)
//        capsuleView.backgroundColor = .black
//        capsuleView.layer.cornerRadius = 5
//        capsuleView.alpha = 0.5
//        tView.addSubview(capsuleView)
        
        let label = UILabel(frame: CGRect(x: 20, y: 10, width: 200, height: 20))
        label.textAlignment = .left
        label.text = NSLocalizedString("Add New Category", comment: "")
        tView.addSubview(label)
        return tView
    }()
    
    // Constants
    var defaultHeight: CGFloat = 300
    var dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    var currentContainerHeight: CGFloat = 300
  
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    override func loadView() {
        super.loadView()
        if UIDevice.current.userInterfaceIdiom == .phone {
             defaultHeight = 260
             dismissibleHeight = 200
             currentContainerHeight = 260
        }
        self.collectionView.backgroundColor =  popularBGColor
         contentStackView = {
            let spacer = UIView()
            spacer.frame = CGRect(x: 0, y: 0, width: 20, height: 5)
            spacer.backgroundColor = popularBGColor
            
            let stackView = UIStackView(arrangedSubviews: [self.collectionView, spacer])
            stackView.axis = .vertical
            stackView.spacing = 5.0
            stackView.backgroundColor =  popularBGColor
            return stackView
        }()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getPopularDataFromProperityList()
        setupView()
        setupConstraints()
        self.collectionView.backgroundColor = popularBGColor
      
       
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = layout
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        setupPanGesture()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadView), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        titleView.tag = 2001
        containerView.addSubview(titleView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // content stackView
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 5),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
        ])
        
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
       
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let newHeight = currentContainerHeight - translation.y
        switch gesture.state {
        case .ended:
           
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }

        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    
//    @objc func reloadView(notification: NSNotification) {
//
//        if let removable = containerView.viewWithTag(2001){
//           removable.removeFromSuperview()
//            containerView.addSubview(titleView)
//            //viewDidLayoutSubviews()
//            loadViewIfNeeded()
//        }
//
//    }

    
    //MARK: UICollectionViewDataSource & UICollectionViewDelegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category =  groupDataArray[indexPath.item].category.lowercased()
        let bombCategory  = UserDefaults.standard.stringArray(forKey: selectedBombCategory) ?? []
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCell
        
        cell.containerView.backgroundColor = .white
        cell.containerView.layer.cornerRadius = 8.0
        cell.backgroundColor = popularBGColor
       
        if(bombCategory.contains(category)){
            cell.containerView.layer.borderWidth = 1
            cell.containerView.layer.borderColor = UIColor(red: 0.29, green: 0.75, blue: 0.97, alpha: 1.00).cgColor
            cell.checkImage.isHidden = false
        }
        else{
            cell.containerView.layer.borderWidth = 0
            cell.containerView.layer.borderColor = UIColor.white.cgColor
            cell.checkImage.isHidden = true
        }
        
        cell.groupName.text = NSLocalizedString(groupDataArray[indexPath.item].category.capitalized, comment:"")
        if UIDevice.current.userInterfaceIdiom == .pad{
            let img = UIImage(named: groupDataArray[indexPath.item].name.replacingOccurrences(of: " ", with: "")+"-ipad")
            if(img != nil){
            cell.groupImage.image = img
            }else{
                cell.groupImage.image = UIImage(named: groupDataArray[indexPath.item].name+"-ipad")!
            }
        }
        else {
            let img = UIImage(named: groupDataArray[indexPath.item].name.replacingOccurrences(of: " ", with: "")+"-iphone")
            if(img != nil){
            cell.groupImage.image = img
            }else{
                cell.groupImage.image = UIImage(named: groupDataArray[indexPath.item].name+"-iphone")!
            }
            
          //  cell.groupImage.image = UIImage(named: groupDataArray[indexPath.item].name.replacingOccurrences(of: " ", with: "")+"-iphone")!
            if(cell.groupName.text!.split(separator: " ").count > 1){
                cell.groupName.numberOfLines = 0
                cell.groupName.lineBreakMode = .byWordWrapping
               
            }else{
                cell.groupName.numberOfLines = 1
                cell.groupName.adjustsFontSizeToFitWidth = true
            }
          
        }

        //MARK: Popular or Recent Cell Spacing.
        if indexPath.item == 0 {
            cell.containerViewLeading.constant = 16
        }
        else {
            cell.containerViewLeading.constant = 8
        }
        //End: Popular or Recent Cell Spacing.
        
        if indexPath.item == self.groupDataArray.count - 1 {
            if self.groupDataArray.count != 1 {
                cell.containerViewTrailing.constant = 16.0
            }
        }
        else {
            cell.containerViewTrailing.constant = 0.0
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category =  groupDataArray[indexPath.item].category.lowercased()
        var bombCategory  = UserDefaults.standard.stringArray(forKey: selectedBombCategory) ?? []
      
            if( bombCategory.contains(category)){
                bombCategory.removeAll(where: { $0 == category})
            }
            else{
                bombCategory.append(category)
            }
            UserDefaults.standard.set(bombCategory, forKey: selectedBombCategory)
        
        print(bombCategory)
            collectionView.reloadData()
        
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
       
        if indexPath.item == 0 {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 160.0+18, height: 160.0)
            }
            else{
                return CGSize(width: 100.0+18, height: 100.0)
            }
        }
        else if indexPath.item == self.groupDataArray.count - 1 {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: 160.0+26, height: 160.0)
            }
            else{
                return CGSize(width: 100.0+26, height: 100.0)
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
    //MARK:- getExploreDataFromProperityList
    func getPopularDataFromProperityList() {
        groupDataArray.removeAll()
        if let path = Bundle.main.path(forResource: "explore", ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) as? [[String: Any]]
            {
                for arr in array
                {
                    let dict =  arr as NSDictionary
                    if(dict.value(forKey: "type") as! String == "popular"){
                    let exploreData = ExploreData(data: dict)
                    groupDataArray.append(exploreData)
                    }
                }
                
            }
        }
    }
    
    
}


