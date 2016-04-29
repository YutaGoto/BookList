//
//  CoreDataStack.swift
//  BookList
//
//  Created by PC006 on 4/29/16.
//  Copyright © 2016 YutaGoto. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    let context:NSManagedObjectContext
    
    // DocumentURLのディレクトリ
    let appDocumentDirURL: NSURL = {
        // NSFileManagerはiOSのファイルまわりの操作をするクラス
        // 今回はデフォルトのマネジャーを使います
        let fileManager = NSFileManager.defaultManager()
        
        // NSFileManagerのディレクトリURLsを指定
        // 第1引数の検索ディレクトリをDocumentDirectoryに、第2引数の検索を行う場所をUserDomainMaskに指定しています
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)
        
        // 検索でヒットしたURLの配列のラストの要素を返しています。
        return urls.last!
    }()
    
    // クラスの初期化
    init() {
        
        // NSBundleはディレクトリに入っているリソースやコードにアクセスするためのクラス
        // 今回はmainBundleを使う
        let bundle = NSBundle.mainBundle()
        
        // modelURLにBookListModel.momdファイルのURLを代入する。見つからなければfatalerrorする
        guard let modelURL = bundle.URLForResource("BookListModel", withExtension: "momd") else {
            fatalError()
        }
        
        // modelにmodelURLのURL部分のモデルを代入する。見つからなければfatalerrorする
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError()
        }
        
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }
    
    // ストア追加を完了したかどうか通知するハンドラ
    func addPersistentStoreWithCompletionHandler(completionHandler: (()->Void)?) {
        // 永続ストアの追加
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        // バックグラウンドのoperation
        dispatch_async(backgroundQueue) {
            
            let dirURL = self.appDocumentDirURL
            let storeURL = dirURL.URLByAppendingPathComponent("BookList.sqlite")
            
            do {
                // 永続ストアコーディネータに永続ストアを追加
                let coordinator = self.context.persistentStoreCoordinator!
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
                completionHandler?()
            } catch let error as NSError {
                fatalError("\(error)")
            }
        }
    }
    
    // 保存する関数
    func saveContext() throws {
        
        // コンテキストに変更があるかどうか
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("\(error)")
                // エラーログを表示するためにthrowする
                throw error
            }
        }
    }
    
}
