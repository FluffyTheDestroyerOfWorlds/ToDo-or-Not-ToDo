//
//  ViewController.swift
//  ToDo or Not ToDo
//
//  Created by David Boesen on 3/5/16.
//  Copyright © 2016 David Boesen. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView1: UITableView!
    
    private var dwarves = [
        "Sleepy", "Sneezy", "Bashful", "Happy",
        "Doc", "Grumpy", "Dopey",
        "Thorin", "Dorin", "Nori", "Ori",
        "Balin", "Dwalin", "Fili", "Kili",
        "Oin", "Gloin", "Bifur", "Bofur",
        "Bombur"
    ]
    let simpleTableIdentifier = "SimpleTableIdentifier"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add Gesture Long Press for moving and sorting list
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        tableView1.addGestureRecognizer(longpress)
        // add Gesture Swipe Right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)


        
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dwarves.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: simpleTableIdentifier)
        }
        
        cell!.textLabel!.text = dwarves[indexPath.row]
    
  //      cell!.textLabel?.font = UIFont .boldSystemFontOfSize(50)
        return cell!
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == 0 {return nil
        } else if (indexPath.row % 2 == 0){
            return NSIndexPath(forRow: 1, inSection: indexPath.section)
        } else {
            return indexPath
        }
    }
            
    
  
  
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            let location : CGPoint = gesture.locationInView(self.tableView1)
            let swipedIndexPath:NSIndexPath = self.tableView1.indexPathForRowAtPoint(location)!
            let swipedcell:UITableViewCell = self.tableView1.cellForRowAtIndexPath(swipedIndexPath)!
            var attrString = NSAttributedString()
            
            print(swipeGesture.direction)
            
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.Right {
                // add to strikeout tableview1 cell 
                attrString = NSAttributedString(string: swipedcell.textLabel!.text!, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
            }
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.Left {
                // add no strikeout and default background
               attrString = NSAttributedString(string: swipedcell.textLabel!.text!, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue])
            }
            swipedcell.textLabel!.attributedText = attrString

        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        
        cellSnapshot.layer.masksToBounds = false
        
        cellSnapshot.layer.cornerRadius = 0.0
        
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        
        cellSnapshot.layer.shadowRadius = 5.0
        
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
        
    }
    
  
    
    // longPressGestureRecognized 
    // written by: Dan Fairbanks 
    //
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        
        var locationInView = longPress.locationInView(tableView1)
        var indexPath = tableView1.indexPathForRowAtPoint(locationInView)
        
        
        
        
        
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        
        
        switch state {
            
        case UIGestureRecognizerState.Began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = tableView1.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshopOfCell(cell)
                var center = cell.center
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                tableView1.addSubview(My.cellSnapshot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    
                    center.y = locationInView.y
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        
                        if finished {
                            cell.hidden = true
                        }
                        
                })
            }
                
          
        case UIGestureRecognizerState.Changed:
            var center = My.cellSnapshot!.center
            
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                swap(&dwarves[indexPath!.row], &dwarves[Path.initialIndexPath!.row])
                tableView1.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                Path.initialIndexPath = indexPath
            }
            
            
            
            
        default:
            
            let cell = tableView1.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
            
            cell.hidden = false
            cell.alpha = 0.0
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                My.cellSnapshot!.center = cell.center
                My.cellSnapshot!.transform = CGAffineTransformIdentity
                My.cellSnapshot!.alpha = 0.0
                
                cell.alpha = 1.0
                
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
            })
 
    }
}
}




