//
//  ViewController.swift
//  Bow Ties
//
//  Created by Pietro Rea on 6/25/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    
    var managedObjContext:NSManagedObjectContext!
    
    //当前的Bowties实例，因为要存要取，所以当前对象的所有方法都必须能访问
    var currentTie:Bowties!
    
    //segmentedControl 当前选择的位置
    var sIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
        insertSampleData()
        displayData(sIndex)
    
    }
  
    @IBAction func segmentedControl(control: UISegmentedControl) {
        sIndex = control.selectedSegmentIndex
        displayData(sIndex)
    
    }

    @IBAction func wear(sender: AnyObject) {
        currentTie.lastWorn = NSDate()
        
        var times = currentTie.timesWorn as Int
        currentTie.timesWorn = NSNumber(integer: times + 1)
        
        managedObjContext.save(nil)
        displayData(sIndex)
        
    }
  
    @IBAction func rate(sender: AnyObject) {
        var alert = UIAlertController(title: "请评分", message: "输入一个分数，满分为5", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(nil)
        ((alert.textFields as! [UITextField])[0] as UITextField).keyboardType = UIKeyboardType.NumberPad
        
        var confirmAc = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in
            
            var str = ((alert.textFields as! [UITextField])[0] as UITextField).text
            var int = str.toInt()!
            if int >= 0 && int <= 5{
            self.currentTie.rating = NSNumber(integer: int)
            self.managedObjContext.save(nil)
            
            self.displayData(self.sIndex)
            }else{
                println("cuo")
            }

        }
        var cancelAc = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(confirmAc)
        alert.addAction(cancelAc)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    /**
    显示数据
    
    :param: index segmentedControl的当前位置
    */
    func displayData(index:Int){
        var request = NSFetchRequest(entityName: "Bowties")
        var error:NSError?
        request.predicate = NSPredicate(format: "searchKey == %@", segmentedControl.titleForSegmentAtIndex(index)!)
        if let result = managedObjContext.executeFetchRequest(request, error: &error) as? [Bowties]{
            
            currentTie = result[0]
            //把各个view显示的内容添加上去
            
            nameLabel.text      = currentTie.name
            ratingLabel.text    = "这个领结评分为\(currentTie.rating)"
            timesWornLabel.text = "戴过\(currentTie.timesWorn)次"
            
            //定义一个日期格式
            let dateFormat       = NSDateFormatter()
            //日期风格
            dateFormat.dateStyle = NSDateFormatterStyle.ShortStyle
            //时间风格
            dateFormat.timeStyle = NSDateFormatterStyle.ShortStyle
            //设置相对日期
            dateFormat.doesRelativeDateFormatting = true
            //日期的地区为中国
            dateFormat.locale = NSLocale(localeIdentifier: "zh_cn")
            
            var dateStr          = dateFormat.stringFromDate(currentTie.lastWorn)
            lastWornLabel.text   = "上一次戴的时间是\(dateStr)"
            

            if (currentTie.isFavorite as Bool) {
                favoriteLabel.hidden = false
            }else{
                favoriteLabel.hidden = true
            }
            
            var image       = UIImage(data: currentTie.imageData)
            imageView.image = image
            
            view.tintColor = currentTie.tintColor as! UIColor
        }
    }
    
    /**
    导入plist文件到实体中
    */
    func insertSampleData(){
        
        //先判断实体中有没有数据
        var request =  NSFetchRequest(entityName: "Bowties")
        request.predicate = NSPredicate(format: "searchKey != nil")
        var count = managedObjContext.countForFetchRequest(request, error: nil)
        
        if count == 0 {
            
        var path = NSBundle.mainBundle().pathForResource("SampleData", ofType: "plist")
        var dataArray:[AnyObject] = NSArray(contentsOfFile: path!) as! [AnyObject]
        
        for dataDict in dataArray{
            var entity = NSEntityDescription.entityForName("Bowties", inManagedObjectContext: managedObjContext)
            var bowtie:Bowties = Bowties(entity: entity!, insertIntoManagedObjectContext: managedObjContext)
            
            bowtie.name       = dataDict["name"] as! String
            bowtie.isFavorite = dataDict["isFavorite"] as! NSNumber
            bowtie.searchKey  = dataDict["searchKey"] as! String
            bowtie.rating     = dataDict["rating"] as! NSNumber
            bowtie.lastWorn   = dataDict["lastWorn"] as! NSDate
            bowtie.timesWorn  = dataDict["timesWorn"] as! NSNumber
            
            var image        = UIImage(named: dataDict["imageName"] as! String)
            var data         = UIImagePNGRepresentation(image)
            bowtie.imageData = data
            
            var color        = getColor(dataDict["tintColor"] as! NSDictionary)
            bowtie.tintColor = color
            
            var error:NSError?
            if !managedObjContext.save(&error){
                println("无法存储数据，\(error)")
            }
            
            }
        }
        
    }
    
    /**
    从plist文件的表示颜色的字典中提取UIColor
    
    :param: dic plist文件中的存储颜色的字典
    
    :returns: 返回颜色
    */
    func getColor(dic:NSDictionary)-> UIColor{
        var red = dic["red"] as! NSNumber
        var green = dic["green"] as! NSNumber
        var blue = dic["blue"] as! NSNumber
    
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
        
    }
    
}

