//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Patrick Jayet on 23/09/16.
//  Copyright © 2016 zuehlke. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet
    weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 75.0
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // solution http://stackoverflow.com/questions/25780730/ios-8-today-widget-fit-height-of-uitableview-using-auto-layout
        let heightConstraint = NSLayoutConstraint(item: self.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.tableView.contentSize.height)
        
        heightConstraint.priority = UILayoutPriorityRequired
        
        self.view.addConstraint(heightConstraint)
        self.view.needsUpdateConstraints()
        self.view.setNeedsLayout()

    }
    
    var activitiesByDay: Array<Array<Activity>> = []
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        //self.preferredContentSize = CGSize(width: 0, height: 400)
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        let now = NSDate()
        let threeDaysAgo = now.addingTimeInterval(-3600*24*3)
        let activities = CoreDataWrapper.shared().fetchActivitiesBetweenDate(threeDaysAgo as Date!, andExclusiveDate: now as Date!) as! Array<Activity>?
        activitiesByDay = CoreDataWrapper.shared().groupActivities(byDay: activities) as! Array<Array<Activity>>
        self.tableView.reloadData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - method from table data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return activitiesByDay.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesByDay[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // case day title cell
        if indexPath.row == 0 {
            
            let activitiesForDay = self.activitiesByDay[indexPath.section]
            return ActivityCellUtils.createDayHeaderCell(indexPath, for: tableView, andActivitiesForDay: activitiesForDay)
        }
        // case day activity
        else {
            
            let activity = self.activitiesByDay[indexPath.section][indexPath.row - 1]
            return ActivityCellUtils.createDayActivityCell(indexPath, for: tableView, andActivity: activity)
        }

    }
    
    // MARK: - method from the table delegate
    
    //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    //}
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .compact) {
            self.preferredContentSize = maxSize;
        }
        else {
            self.preferredContentSize = self.tableView.contentSize
        }
    }
}
