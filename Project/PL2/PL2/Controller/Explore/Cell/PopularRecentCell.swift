
import UIKit
import CloudKit

class PopularRecentCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    
    var groupDataArray = [ExploreData]()
    var groupName: String = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: UICollectionViewDataSource & UICollectionViewDelegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCell
        
        cell.containerView.backgroundColor = .white
        cell.containerView.layer.cornerRadius = 8.0
       
        if(groupDataArray[indexPath.item].nc != nil && groupDataArray[indexPath.item].nc! > 0){
            cell.newButton.isHidden = false
        }
        else{
            cell.newButton.isHidden = true
        }
        if groupName == "Popular" {
            cell.backgroundColor = popularBGColor
        }
        else if groupName == "Recent" {
            cell.backgroundColor = RecentBGColor
            cell.newButton.isHidden = true
        }
        
        
        cell.groupName.text = NSLocalizedString(groupDataArray[indexPath.item].category.capitalized, comment:"")
        if UIDevice.current.userInterfaceIdiom == .pad{
            
            cell.loader.startAnimating()
            cell.groupImage.image = nil
            var imgName = groupDataArray[indexPath.item].name+"-ipad"
            
            let img = UIImage(named: groupDataArray[indexPath.item].name.replacingOccurrences(of: " ", with: "")+"-ipad")
            if(img != nil){
                imgName = groupDataArray[indexPath.item].name.replacingOccurrences(of: " ", with: "")+"-ipad"
            }
            
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
            var imgName = groupDataArray[indexPath.item].name+"-iphone"
            let img = UIImage(named: groupDataArray[indexPath.item].name.replacingOccurrences(of: " ", with: "")+"-iphone")
            if(img != nil){
                imgName = groupDataArray[indexPath.item].name.replacingOccurrences(of: " ", with: "")+"-iphone"
            }
            
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
    
            cell.groupName.numberOfLines = 1
            cell.groupName.adjustsFontSizeToFitWidth = true
            
            
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
        print(indexPath.item)
        if( groupDataArray[indexPath.item].category.lowercased()=="journy"){
            return
        }
        if groupName == "Popular" {
            self.appDelegate.logEvent(name: "Explore_Popular", category: "Explore", action: "Tapping in Popular")
        }
        else if groupName == "Recent" {
            self.appDelegate.logEvent(name: "Explore_Recent", category: "Explore", action: "Tapping in Recent")
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
    
    
    func loadServerImage(indexPath:IndexPath, name: NSString, cell:SliderCell )
    {
        
        let thumName = NSString(format:"%@",name)
        
        let recordID = CKRecordID(recordName:thumName.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
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
                   
                   
                    self.sliderCollectionView?.reloadItems(at: [indexPath])
                   
                })
            }
            
        }
        
       
    }
    
}
