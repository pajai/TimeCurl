//
//  IntrinsicTableView.swift
//  TimeCurl
//
//  Created by Patrick Jayet on 24/09/16.
//  Copyright © 2016 zuehlke. All rights reserved.
//

import UIKit

class IntrinsicTableView: UITableView {
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }
    
}
