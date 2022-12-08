/*
 Copyright © 2021 Apple Inc. All rights reserved.

 Apple permits redistribution and use in source and binary forms, with or without
 modification, providing that you adhere to the following conditions:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions, and the following disclaimer in the documentation and
 other distributed materials.

 3. You may not use the name of the copyright holders nor the names of any contributors
 to endorse or promote products that derive from this software without specific prior
 written permission. Apple does not grant license to the trademarks of the copyright
 holders even if this software includes such marks.

 THE COPYRIGHT HOLDERS AND CONTRIBUTORS PROVIDE THIS SOFTWARE "AS IS”, AND DISCLAIM ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 OR CONSEQUENTIAL  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) WHATEVER THE CAUSE AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF YOU
 ADVISE THEM OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CareKitStore
import ResearchKit

struct Surveys {

    private init() {}

    // MARK: Onboarding

    static func onboardingSurvey() -> ORKTask {
        
        // The Welcome Instruction step.
        let welcomeInstructionStep = ORKInstructionStep(
            identifier: "onboarding.welcome"
        )
        
        welcomeInstructionStep.title = "Welcome!"
        welcomeInstructionStep.detailText = "Thank you for joining our study. Tap Next to learn more before signing up."
        welcomeInstructionStep.image = UIImage(named: "welcome-image")
        welcomeInstructionStep.imageContentMode = .scaleAspectFill
        
        // The Informed Consent Instruction step.
        let studyOverviewInstructionStep = ORKInstructionStep(
            identifier: "onboarding.overview"
        )
        
        studyOverviewInstructionStep.title = "Before You Join"
        studyOverviewInstructionStep.iconImage = UIImage(systemName: "checkmark.seal.fill")
        
        let heartBodyItem = ORKBodyItem(
            text: "The study will ask you to share some of your health data.",
            detailText: nil,
            image: UIImage(systemName: "heart.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        
        let completeTasksBodyItem = ORKBodyItem(
            text: "You will be asked to complete various tasks over the duration of the study.",
            detailText: nil,
            image: UIImage(systemName: "checkmark.circle.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        
        let signatureBodyItem = ORKBodyItem(
            text: "Before joining, we will ask you to sign an informed consent document.",
            detailText: nil,
            image: UIImage(systemName: "signature"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        
        let secureDataBodyItem = ORKBodyItem(
            text: "Your data is kept private and secure.",
            detailText: nil,
            image: UIImage(systemName: "lock.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        
        studyOverviewInstructionStep.bodyItems = [
            heartBodyItem,
            completeTasksBodyItem,
            signatureBodyItem,
            secureDataBodyItem
        ]
        
        // The Signature step (using WebView).
        let webViewStep = ORKWebViewStep(
            identifier: "onboarding.signatureCapture",
            html: informedConsentHTML
        )
        
        webViewStep.showSignatureAfterContent = true
        
        // The Request Permissions step.
        let healthKitTypesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]
        
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        let healthKitPermissionType = ORKHealthKitPermissionType(
            sampleTypesToWrite: healthKitTypesToWrite,
            objectTypesToRead: healthKitTypesToRead
        )
        
        let notificationsPermissionType = ORKNotificationPermissionType(
            authorizationOptions: [.alert, .badge, .sound]
        )
        
        let motionPermissionType = ORKMotionActivityPermissionType()
        
        let requestPermissionsStep = ORKRequestPermissionsStep(
            identifier: "onboarding.requestPermissionsStep",
            permissionTypes: [
                healthKitPermissionType,
                notificationsPermissionType,
                motionPermissionType
            ]
        )
        
        requestPermissionsStep.title = "Health Data Request"
        requestPermissionsStep.text = "Please review the health data types below and enable sharing to contribute to the study."
        
        // Completion Step
        let completionStep = ORKCompletionStep(
            identifier: "onboarding.completionStep"
        )
        
        completionStep.title = "Enrollment Complete"
        completionStep.text = "Thank you for enrolling in this study. Your participation will contribute to meaningful research!"
        
        let surveyTask = ORKOrderedTask(
            identifier: "onboard",
            steps: [
                welcomeInstructionStep,
                studyOverviewInstructionStep,
                webViewStep,
                requestPermissionsStep,
                completionStep
            ]
        )
        
        return surveyTask
    }
    
    // MARK: Check-in Survey

    static let checkInIdentifier = "checkin"
    static let checkInFormIdentifier = "checkin.form"
    static let dropOrSpillItemIdentifier = "checkin.form.dropOrSpill"
    static let rearrangeWorkspaceItemIdentifier = "checkin.form.rearrangeWorkspace"
    static let checkInSleepItemIdentifier = "checkin.form.sleep"

    static func checkInSurvey() -> ORKTask {

        let dropOrSpillItemQuestion = "How often in the last 24 hours have you dropped something or spilled a drink?"
        let dropOrSpillAnswerFormat = ORKAnswerFormat.scale(
            withMaximumValue: 5,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "5 or more",
            minimumValueDescription: "Few"
        )
        
        let rearranegWorkspaceItemQuestion = "Have you had to adjust the location or layout of your workspace because distracting sights or sounds (such as people talking or walking outside a window) which made it hard or even impossible to get work done?"
        let rearrangeWorkspaceAnswerFormat = ORKAnswerFormat.scale(
            withMaximumValue: 5,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "5 or more",
            minimumValueDescription: "Few"
        )

        let dropOrSpillItem = ORKFormItem(
            identifier: dropOrSpillItemIdentifier,
            text: dropOrSpillItemQuestion,
            answerFormat: dropOrSpillAnswerFormat
        )
        dropOrSpillItem.isOptional = false
        
        let rearrangeWorkspaceItem = ORKFormItem(
            identifier: rearrangeWorkspaceItemIdentifier,
            text: rearranegWorkspaceItemQuestion,
            answerFormat: rearrangeWorkspaceAnswerFormat
        )
        rearrangeWorkspaceItem.isOptional = false

        let formStep = ORKFormStep(
            identifier: checkInFormIdentifier,
            title: "Check In",
            text: "Please answer the following questions."
        )
        formStep.formItems = [dropOrSpillItem, rearrangeWorkspaceItem]
        formStep.isOptional = false

        let surveyTask = ORKOrderedTask(
            identifier: checkInIdentifier,
            steps: [formStep]
        )

        return surveyTask
    }

    static func extractAnswersFromCheckInSurvey(
        _ result: ORKTaskResult) -> [OCKOutcomeValue]? {

        guard
            let response = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == checkInFormIdentifier }),

            let scaleResults = response
                .results?.compactMap({ $0 as? ORKScaleQuestionResult }),

            let dropOrSpillAnswer = scaleResults
                .first(where: { $0.identifier == dropOrSpillItemIdentifier })?
                .scaleAnswer,

            let rearrangeWorkspaceAnswer = scaleResults
                .first(where: { $0.identifier == rearrangeWorkspaceItemIdentifier })?
                .scaleAnswer
        else {
            assertionFailure("Failed to extract answers from check in survey!")
            return nil
        }

        var dropOrSpillValue = OCKOutcomeValue(Double(truncating: dropOrSpillAnswer))
        dropOrSpillValue.kind = dropOrSpillItemIdentifier

        var rearrangeWorkspaceValue = OCKOutcomeValue(Double(truncating: rearrangeWorkspaceAnswer))
        rearrangeWorkspaceValue.kind = rearrangeWorkspaceItemIdentifier

        return [dropOrSpillValue, rearrangeWorkspaceValue]
    }
}
