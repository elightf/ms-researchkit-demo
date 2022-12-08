//
//  CareFeedViewController.swift
//  MindSeaResearchKitDemo
//
//  Created by Eric Lightfoot on 2022-12-07.
//

import CareKit
import CareKitStore
import CareKitUI
import ResearchKit
import UIKit
import os.log

final class CareFeedViewController: OCKDailyPageViewController, OCKSurveyTaskViewControllerDelegate {
    override func dailyPageViewController(
        _ dailyPageViewController: OCKDailyPageViewController,
        prepare listViewController: OCKListViewController,
        for date: Date) {
        
            checkIfOnboardingIsComplete { isOnboarded in
                
                guard isOnboarded else {
                    
                    let onboardCard = OCKSurveyTaskViewController(
                        taskID: TaskIDs.onboarding,
                        eventQuery: OCKEventQuery(for: date),
                        storeManager: self.storeManager,
                        survey: Surveys.onboardingSurvey(),
                        extractOutcome: { _ in [OCKOutcomeValue(Date())] }
                    )

                    onboardCard.surveyDelegate = self

                    listViewController.appendViewController(
                        onboardCard,
                        animated: false
                    )
                    
                    return
                }
                
                let isFuture = Calendar.current.compare(
                    date,
                    to: Date(),
                    toGranularity: .day) == .orderedDescending

                self.fetchTasks(on: date) { tasks in
                    tasks.compactMap {

                        let card = self.taskViewController(for: $0, on: date)
                        card?.view.isUserInteractionEnabled = !isFuture
                        card?.view.alpha = isFuture ? 0.4 : 1.0

                        return card

                    }.forEach {
                        listViewController.appendViewController($0, animated: false)
                    }
                }
                
            }
            
    }
    
    private func checkIfOnboardingIsComplete(_ completion: @escaping (Bool) -> Void) {
        
        var query = OCKOutcomeQuery()
        query.taskIDs = [TaskIDs.onboarding]
        
        storeManager.store.fetchAnyOutcomes(query: query, callbackQueue: .main) { result in
            switch result {
            case .failure:
                print("Failed to fetch onboarding outcomes!")
                completion(false)
            case let .success(outcomes):
                completion(!outcomes.isEmpty)
            }
        }
    }
    
    private func fetchTasks(
        on date: Date,
        completion: @escaping([OCKAnyTask]) -> Void) {

        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true

        storeManager.store.fetchAnyTasks(
            query: query,
            callbackQueue: .main) { result in

            switch result {

            case .failure:
                print("Failed to fetch tasks for date \(date)")
                completion([])

            case let .success(tasks):
                completion(tasks)
            }
        }
    }

    private func taskViewController(
        for task: OCKAnyTask,
        on date: Date) -> UIViewController? {

        switch task.id {

        case TaskIDs.checkIn:

            let survey = OCKSurveyTaskViewController(
                task: task,
                eventQuery: OCKEventQuery(for: date),
                storeManager: storeManager,
                survey: Surveys.checkInSurvey(),
                viewSynchronizer: SurveyViewSynchronizer(),
                extractOutcome: Surveys.extractAnswersFromCheckInSurvey
            )
            survey.surveyDelegate = self

            return survey

        default:
            return nil
        }
    }

    // MARK: SurveyTaskViewControllerDelegate

    func surveyTask(
        viewController: OCKSurveyTaskViewController,
        for task: OCKAnyTask,
        didFinish result: Result<ORKTaskViewControllerFinishReason, Error>) {

        if case let .success(reason) = result, reason == .completed {
            reload()
        }
    }

    func surveyTask(
        viewController: OCKSurveyTaskViewController,
        shouldAllowDeletingOutcomeForEvent event: OCKAnyEvent) -> Bool {

        event.scheduleEvent.start >= Calendar.current.startOfDay(for: Date())
    }
}

final class SurveyViewSynchronizer: OCKSurveyTaskViewSynchronizer {

    override func updateView(
        _ view: OCKInstructionsTaskView,
        context: OCKSynchronizationContext<OCKTaskEvents>) {

        super.updateView(view, context: context)

        if let event = context.viewModel.first?.first, event.outcome != nil {
            view.instructionsLabel.isHidden = false
            
            let pain = event.answer(kind: Surveys.dropOrSpillItemIdentifier)
            let sleep = event.answer(kind: Surveys.checkInSleepItemIdentifier)

            view.instructionsLabel.text = """
                Pain: \(Int(pain))
                Sleep: \(Int(sleep)) hours
                """
        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}
