//
//  FriendsControllerHelper.swift
//  facebook-messenger
//
//  Created by Karlos Aguirre on 10/29/18.
//  Copyright © 2018 Karlos Aguirre. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let managedContext = delegate?.persistentContainer.viewContext {
            
            do {
                let entityNames = ["Friend", "Message"]
                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let objects = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
                    for object in objects! {
                        managedContext.delete(object)
                    }
                }
                
                try managedContext.save()
            } catch let error as NSError {
                print("Could not load messages. \(error), \(error.userInfo)")
            }
        }
    }
    
    func setupData() {
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let managedContext = delegate?.persistentContainer.viewContext {
            
            createSteveMessagesWithContext(context: managedContext)
            
            let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: managedContext) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald"
            
            FriendsController.createMessage(with: "You're fired!", friend: donald, minsAgo: 5, context: managedContext)
            
            let ghandi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: managedContext) as! Friend
            ghandi.name = "Mahatma Ghandi"
            ghandi.profileImageName = "ghandi"
            
            FriendsController.createMessage(with: "Love, Peace and Joy!", friend: ghandi, minsAgo: 60*24, context: managedContext)
            
            let hillary = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: managedContext) as! Friend
            hillary.name = "Hillary Clinton"
            hillary.profileImageName = "hillary"
            
            FriendsController.createMessage(with: "Vote for me, you did for Bill!", friend: hillary, minsAgo: 8*60*24, context: managedContext)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func createSteveMessagesWithContext(context:NSManagedObjectContext) {
        
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve"
        
        FriendsController.createMessage(with: "Good morning... ", friend: steve, minsAgo: 2, context: context)
        FriendsController.createMessage(with: "Hello, how are you? Hope you are having a good morning!", friend: steve, minsAgo: 1, context: context)
        FriendsController.createMessage(with: "Are you interested in buying an apple device? WE have a wide variety of Apple devices that will suit your needs. Please make your purchase with us.", friend: steve, minsAgo: 1, context: context)
        
        //response message
        FriendsController.createMessage(with: "Yes, totally looking to buy an iPhone 7.", friend: steve, minsAgo: 1, context: context, isSender: true)
        
        FriendsController.createMessage(with: "Totally understand that you want the new iPhone 7, but you'll have to wait until September for the new release. Sorry but thats just how Apple likes to do things.", friend: steve, minsAgo: 1, context: context)
        
        //response message
        FriendsController.createMessage(with: "Absolutely, I'll just use my gigantic iPhone 6 Plus until then!!!", friend: steve, minsAgo: 1, context: context, isSender: true)
    }
    
    static func createMessage(with text:String, friend:Friend, minsAgo: Double, context:NSManagedObjectContext, isSender:Bool = false) {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = Date().addingTimeInterval(-minsAgo*60)
        message.isSender = isSender
        
        friend.lastMessage = message
    }
}
