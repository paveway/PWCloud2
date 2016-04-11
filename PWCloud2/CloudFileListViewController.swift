//
//  ViewController.swift
//  PWCloud2
//
//  Created by mfuta1971 on 2016/04/07.
//  Copyright © 2016年 Paveway. All rights reserved.
//

import UIKit

class CloudFileListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Constants

    let kTitle = "iCloudファイル一覧"

    let kCellName = "Cell"

    let kDocumentsDirectoryName = "Documents"

    let kDateFormat = "yyyyMMddHHmmssSSS"

    let kLocale = "ja"

    let kFileNamePrefix = "test"

    let kFilePattern = "*"

    let kPredicateFormat = "%K LIKE %@"

    // MARK: - Variables

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var createToolbarButton: UIBarButtonItem!

    var query: NSMetadataQuery?

    var fileNameList = [String]()

    // MARK: - UIViewControllerDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = kTitle

        let action = #selector(rightBarButtonPressed(_:))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: action)

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        setAndStartQuery()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fileNameList.count
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell()
        }

        let row = indexPath.row
        let count = fileNameList.count
        if row + 1 > count {
            return cell!
        }

        let fileName = fileNameList[row]
        cell!.textLabel?.text = fileName

        return cell!
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - NavigationBar button

    func rightBarButtonPressed(sender: UIButton) {
//        setAndStartQuery()
    }

    // MARK: - Toolbar button

    @IBAction func createToolbarButtonPressed(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: kLocale)
        dateFormatter.dateFormat = kDateFormat
        let date = NSDate()
        let suffix = dateFormatter.stringFromDate(date)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let fileManager = NSFileManager.defaultManager()
            var documentURL = fileManager.URLForUbiquityContainerIdentifier(nil)

            documentURL = documentURL!.URLByAppendingPathComponent(self.kDocumentsDirectoryName, isDirectory: true)
            documentURL = documentURL!.URLByAppendingPathComponent("\(self.kFileNamePrefix)\(suffix)")

            let cloudDocument = CloudDocument(fileURL: documentURL!)

            dispatch_async(dispatch_get_main_queue()) {
                cloudDocument.saveToURL(documentURL!, forSaveOperation: .ForCreating, completionHandler: { (success: Bool) -> Void in
                })
            }
        })
    }

    func setAndStartQuery() {
        if query == nil {
            query = createQuery()
        }

        let notificationCenter = NSNotificationCenter.defaultCenter()
        let selector = #selector(processFiles(_:))
        notificationCenter.addObserver(self, selector: selector, name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        notificationCenter.addObserver(self, selector: selector, name: NSMetadataQueryDidUpdateNotification, object: nil)

        if !query!.started {
            query!.startQuery()
        }
    }

    func createQuery() -> NSMetadataQuery {
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: kPredicateFormat, NSMetadataItemFSNameKey, kFilePattern)
        //query.predicate = NSPredicate(format: String(format: "%%K.pathExtension LIKE '%@'", filePattern), NSMetadataItemFSNameKey)
        return query
    }

    func processFiles(notification: NSNotification) {
        query?.disableUpdates()

        fileNameList.removeAll(keepCapacity: false)

        let queryResults = query?.results
        for result in queryResults! {
            let fileURL = result.valueForAttribute(NSMetadataItemURLKey)
            if fileURL != nil {
                var fileName = fileURL?.lastPathComponent
                if fileName == nil {
                    fileName = ""
                }
                fileNameList.append(fileName!)
            }
        }

        tableView.reloadData()

        query?.enableUpdates()
    }
}

