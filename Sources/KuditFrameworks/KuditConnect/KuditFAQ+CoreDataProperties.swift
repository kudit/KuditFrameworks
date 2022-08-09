//
//  KuditFAQ+CoreDataProperties.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/18/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation
import CoreData


extension KuditFAQ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KuditFAQ> {
        return NSFetchRequest<KuditFAQ>(entityName: "FAQ");
    }

    @NSManaged public var answer: String?
    @NSManaged public var category: String?
    @NSManaged public var lastUpdated: NSDate?
    @NSManaged public var maxversion: String?
    @NSManaged public var minversion: String?
    @NSManaged public var question: String?

}
