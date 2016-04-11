//
//  CoudDocument.swift
//  PWCloud2
//
//  Created by mfuta1971 on 2016/04/10.
//  Copyright © 2016年 Paveway. All rights reserved.
//

import UIKit

@objc protocol CloudDocumentDelegate {

    func documentConetntsDidChange(cloudDocument: CloudDocument)
}

class CloudDocument: UIDocument {

//    var documentText: String {
//        get {
//            return self.documentText
//        }
//        set(newDocumentText) {
//            let oldDocumentText = documentText
//            self.documentText = newDocumentText
//
//            //undoManager.setActionName("Text Change")
//            //undoManager.registerUndoWithTarget(self, selector: Selector("setDocumentText:"), object: oldDocumentText)
//        }
//    }
    var documentText: String = ""

    var delegate: CloudDocumentDelegate?

    override func contentsForType(typeName: String) throws -> AnyObject {
        let documentData = documentText.dataUsingEncoding(NSUTF8StringEncoding)
        if documentData == nil {
            return NSData()
        }
        return documentData!
    }

    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {
        if contents.length > 0  {
            documentText = String(data: contents as! NSData, encoding: NSUTF8StringEncoding)!
        } else {
            documentText = ""
        }

        delegate?.documentConetntsDidChange(self)
    }
}