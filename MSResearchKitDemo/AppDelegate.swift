//
//  AppDelegate.swift
//  MSResearchKitDemo
//
//  Created by Eric Lightfoot on 2022-12-06.
//

import UIKit
import CareKit
import CareKitStore
import OSLog

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let storeManager = OCKSynchronizedStoreManager(
        wrapping: OCKStore(name: "com.mindsea.carekitstore", type: .onDisk(protection: .complete))
    )

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        seedTasks()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    private func seedTasks() {
        let onboardingSchedule = OCKSchedule.dailyAtTime(
            hour: 0, minutes: 0,
            start: Date(), end: nil,
            text: "Task due!",
            duration: .allDay
        )
        
        var onboardTask = OCKTask(
            id: TaskIDs.onboarding,
            title: "Onboard",
            carePlanUUID: nil,
            schedule: onboardingSchedule
        )
        
        onboardTask.instructions = "You'll need to agree to some terms and conditions before we get started!"
        onboardTask.impactsAdherence = false
        
        let checkInSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0,
            start: Date(), end: nil,
            text: nil
        )

        let checkInTask = OCKTask(
            id: TaskIDs.checkIn,
            title: "Check In",
            carePlanUUID: nil,
            schedule: checkInSchedule
        )
        
        storeManager.store.addAnyTasks(
            [onboardTask, checkInTask],
            callbackQueue: .main) { result in
                switch result {
                case let .success(tasks):
                    print("seeded \(tasks.count) tasks")
                case let .failure(error):
                    print("Error: \(error.localizedDescription)")
                }
            }
    }
}

