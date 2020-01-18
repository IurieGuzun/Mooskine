//
//  Notebook+Extentions.swift
//  Mooskine
//
//  Created by Iurie Guzun on 2020-01-17.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Notebook {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
