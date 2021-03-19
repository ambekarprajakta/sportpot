////
////  CoreDataManager.swift
////  SportPot
////
////  Created by Prajakta Ambekar on 24/09/2020.
////  Copyright © 2020 Prajakta Ambekar. All rights reserved.
////
//
//import Foundation
//import CoreData
//import UIKit
//
//extension CodingUserInfoKey {
//    static let context = CodingUserInfoKey(rawValue: "context")
//}
//
//class CoreDataManager {
//
//    //1
//    static let sharedManager = CoreDataManager()
//    //2.
//    private init() {} // Prevent clients from creating another instance.
//
//    //3
//    lazy var persistentContainer: NSPersistentContainer = {
//
//        let container = NSPersistentContainer(name: "SportPot")
//
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
//
//    //4
//    func saveContext () {
//        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
//    lazy var fetchedResultsController: NSFetchedResultsController<FixtureModel> = {
//        // Initialize Fetch Request
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        /*Before you can do anything with Core Data, you need a managed object context. */
//        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
//
//        /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
//
//         Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
//         */
//        let fetchRequest = NSFetchRequest<FixtureModel>(entityName: "Fixture")
//
//        //        // Add Sort Descriptors
//        //        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
//        //        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        // Initialize Fetched Results Controller
//        let fetchedResultsController = NSFetchedResultsController<FixtureModel>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        // Configure Fetched Results Controller
//        //    fetchedResultsController.delegate = self
//
//        return fetchedResultsController
//    }()
    
//    func insertFixture(response: Array<FixtureModel>) -> FixtureModel? {
//        
//        // 1
//        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
//        
//        // 2
//        ///Fixture
//        let entityFixture =
//            NSEntityDescription.entity(forEntityName: "Fixture",
//                                       in: managedContext)!
//        
//        let fixture = NSManagedObject(entity: entityFixture,
//                                      insertInto: managedContext)
//        ///League
//        let entityLeague =
//            NSEntityDescription.entity(forEntityName: "League",
//                                       in: managedContext)!
//        
//        let league = NSManagedObject(entity: entityLeague,
//                                     insertInto: managedContext)
//        ///HomeTeam
//        let entityHomeTeam =
//            NSEntityDescription.entity(forEntityName: "HomeTeam",
//                                       in: managedContext)!
//        
//        let homeTeam = NSManagedObject(entity: entityHomeTeam,
//                                       insertInto: managedContext)
//        ///AwayTeam
//        let entityAwayTeam =
//            NSEntityDescription.entity(forEntityName: "AwayTeam",
//                                       in: managedContext)!
//        
//        let awayTeam = NSManagedObject(entity: entityAwayTeam,
//                                       insertInto: managedContext)
//        ///Score
//        
//        // 3
//        // Iterate through the fixtures array to save them one by one.
//        for fixtureModel in response {
//            fixture.setValue(fixtureModel.fixture_id, forKeyPath: "fixture_id")
//            fixture.setValue(fixtureModel.league_id, forKeyPath: "league_id")
//            
//            league.setValue(fixtureModel.league?.name, forKeyPath: "name")
//            league.setValue(fixtureModel.league?.country, forKeyPath: "country")
//            league.setValue(fixtureModel.league?.logo, forKeyPath: "logo")
//            league.setValue(fixtureModel.league?.flag, forKeyPath: "flag")
//            
//            fixture.setValue(fixtureModel.event_date, forKeyPath: "event_date")
//            fixture.setValue(fixtureModel.event_timestamp, forKeyPath: "event_timestamp")
//            fixture.setValue(fixtureModel.firstHalfStart, forKeyPath: "firstHalfStart")
//            fixture.setValue(fixtureModel.secondHalfStart, forKeyPath: "secondHalfStart")
//            fixture.setValue(fixtureModel.round, forKeyPath: "round")
//            fixture.setValue(fixtureModel.status, forKeyPath: "status")
//            fixture.setValue(fixtureModel.statusShort, forKeyPath: "statusShort")
//            fixture.setValue(fixtureModel.elapsed, forKeyPath: "elapsed")
//            fixture.setValue(fixtureModel.venue, forKeyPath: "venue")
//            fixture.setValue(fixtureModel.referee, forKeyPath: "referee")
//            
//            homeTeam.setValue(fixtureModel.homeTeam?.team_id, forKeyPath: "team_id")
//            homeTeam.setValue(fixtureModel.homeTeam?.team_name, forKeyPath: "team_name")
//            homeTeam.setValue(fixtureModel.homeTeam?.logo, forKeyPath: "logo")
//            
//            awayTeam.setValue(fixtureModel.awayTeam?.team_id, forKeyPath: "team_id")
//            awayTeam.setValue(fixtureModel.awayTeam?.team_name, forKeyPath: "team_name")
//            awayTeam.setValue(fixtureModel.awayTeam?.logo, forKeyPath: "logo")
//            
//            fixture.setValue(fixtureModel.goalsHomeTeam, forKeyPath: "goalsHomeTeam")
//            fixture.setValue(fixtureModel.goalsAwayTeam, forKeyPath: "goalsAwayTeam")
//            
//            fixture.setValue(league, forKeyPath: "league")
//            fixture.setValue(homeTeam, forKeyPath: "homeTeam")
//            fixture.setValue(awayTeam, forKeyPath: "awayTeam")
//            //            fixture.setValue(fixtureModel.score, forKeyPath: "score")
////            fixtureData.append(fixture)
//        }
//        
//        // 4
//        do {
//            try managedContext.save()
//            print("\n===YAY!! Data is saved! ===\n\n")
//            print(fixture)
//            return fixture as? FixtureModel
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//        return nil
//    }
//}
