//
//  Constants.swift
//  PL2
//
//  Created by Praveen kumar on 08/02/18.
//  Copyright © 2018 IPHS Technologies. All rights reserved.
//

import Foundation


let DRAW_VIEW_ENTITY_ZONE = "DrawViewEntity_Zone"
let MY_WORK_ENTITY_ZONE = "MyWorkEntity_Zone"
let IMAGE_COLOR_ENTITY_ZONE = "ImageColorEntity_Zone"
let THUMBNAIL_ENTITY_ZONE = "ThumbNailEntity_Zone"

let DRAW_VIEW_ENTITY = "DrawViewEntity"
let MY_WORK_ENTITY = "MyWorkEntity"
let IMAGE_COLOR_ENTITY = "ImageColorEntity"
let THUMBNAIL_ENTITY = "ThumbNailEntity"
let SHARED_IMAGES = "sharedImages"
let SESSION_LIMIT = "sessionLimit"
let BONUS_NOT_CLAIMED = "PendingBouns"
let BONUS = "Bouns"
let LAUNCH_COUNT = "LaunchCount"
let SHOW_SUBSCRIPTION = "ShowSubscription"
let IS_MOREINFO = "MoreInfo"
let detectAppVersion = "detectAppVersion"
let detectAppType = "detectAppType"
let isAdTrackingPromptAuthorization = "isAdTrackingPromptAuthorization"
let isComplianceDone = "isComplianceDone"
let displayComplianceWindow = "displayComplianceWindow"
let HINTCOUNT = "HintCount"
let PAINTCOUNT = "PaintCount"
let AUTOMOVECOUNT = "AutoMoveCount"
let isKillByForce = "isKillByForce"
let APP_TRACKING = "App_Tracking"
let SCROLL_OBSERVER = "Scroll_Observer"
let RELEASE_MEMORY = "Release_Memory"

let tutKey = "is_viewed_tutorial"
let newPicker = "is_viewed_tutorial_New_Picker"

let tutKeyPageVC = "is_viewed_tutorial_pageVc"


let step1_line1  = NSLocalizedString("Tap 1 time for 1x zoom", comment: "")
let step1_line2  = NSLocalizedString("Tap 2 times for 2x zoom", comment: "")

let step2_line1  = NSLocalizedString("Pinch to zoom in", comment: "")
let step2_line2  = NSLocalizedString("and zoom out", comment: "")

let step3_line1  = NSLocalizedString("Select color in palette", comment: "")
let step3_line2  = NSLocalizedString("and color boxes with", comment: "")
let step3_line3  = NSLocalizedString("matching numbers", comment: "")

let step4_line1  = NSLocalizedString("Use long tap to color", comment: "")
let step4_line2  = NSLocalizedString("consecutive boxes", comment: "")

let step5_line1  = NSLocalizedString("Tap Paint Bucket", comment: "")
let step5_line2  = NSLocalizedString("to color large area", comment: "")

let step6_line1  = NSLocalizedString("Tap Hint to help", comment: "")
let step6_line2  = NSLocalizedString("finding where to color", comment: "")

let step7_line1  = NSLocalizedString("Tap Paint Picker to", comment: "")
let step7_line2  = NSLocalizedString("auto-select color", comment: "")
//let step7_line3  = NSLocalizedString("in palette", comment: "")

let highlightColorString = "#FF7165"

var interstitialTime = 2
var rewardTime = 0
var currentToolWindow = ""
var reminderTime1 = 0
var reminderTime = 0
var rewardTools = 5
var purchasess = 0
var mysteryWinNumber = 1
let interstitialTimeKey = "interstitialTime"
let rewardTimeKey = "rewardTime"
let currentToolWindowKey = "current_tool_window"
let reminderTime1Key = "reminder_time1"
let reminderTimeKey = "reminder_time"
let rewardToolsKey = "reward_tools"

let purchasessKey = "purchase_ss"
let purchasessActiveKey = "purchase_ss_active"

let isPermissionCodeExecute:String = "isPermissionCodeExecute"

let isOpenSettingForNotificationExecute:String = "isOpenSettingForNotificationExecute"

//inActive
let inActiveReminderTimeKey = "inactive_reminder_time"
let InActiveReminderTimeKey1 = "inactive_reminder_time1"
let InActiveRewardToolsKey = "inactive_reward_tools"
let InActiveRewardTimeKey = "inactive_rewardTime"
let InActiveInterstitialTimeKey = "inactive_interstitialTime"
let InActiveCurrentToolWindowKey = "inactive_current_tool_window"

//End inActive


let MAX_NOTIFICATION_COUNT = 3 //max notification Count
let timeComponent: Calendar.Component = .second  //.day //.hour //.minute //.second
let timeDelayValue = 25  // please set notification dealy time

var currentView:String = ""
let basedVideoAdString:String = "basedVideoAdString"
let rewardBasedVideoAdString:String = "rewardBasedVideoAdString"
let intertialPlayScreenVideoAdString:String = "intertialPlayScreenVideoAdString"
let intertialMyWorkVideoAdString:String = "intertialMyWorkVideoAdString"
let intertialPagesVideoAdString:String = "intertialPagesVideoAdString"

var isBackFromHome = false
var currentOriendation:UIInterfaceOrientationMask = .portrait

var expirationTimeKey = "expirationTimeKey"
let isNotificationAllow:String = "isNotificationAllow"
let firstRegisterNotification : String = "First_Register_Notification"
let selectedBombCategory = "selected_Bomb_Category"

let reviewWindowX = 4
let reviewWindowY = 5
var isPagesFreeTrailButtonClick = false

let giftWindowsVisibleTime = "giftWindowsVisibleTime"
let giftTimeComponent: Calendar.Component = .minute //.day //.hour //.minute //.second
let giftTimeComponentZone: Calendar.Component = .timeZone
let giftTimeDelayValue = 1  // please set Gift Window dealy time
let giftClaimCountValue = "giftClaimCountValue"
let gift_day_5_Past = "gift_d5past"
let mysteryClaimCountValue = "mysteryClaimCountValue"
let mystery_day_5_Past = "mystery_d5past"
let mysteryWindowsVisibleTime = "mysteryWindowsVisibleTime"
let adDisplayTimeConstant = "adDisplayTimeConstant"

let hints3Reward = 3
let hints5Reward = 4
let hints7Reward = 5
let hints10Reward = 6
let hints12Reward = 7
let maxBoosterShareCount = 30
let maxBoosterReceivingCount = 1
let boosterTool = 30
let boosterShareDate = "BoosterShareDate"
let previousBoostShareCount = "previousBoostShareCount"
let BOOSTER_CLAIMED = "BoosterClaimed"
let boosterReceivingDate = "boosterReceivingDate"
let previousBoostRecevingCount = "previousBoostRecevingCount"

let boosterTimeComponent: Calendar.Component = .day  //.day //.hour //.minute //.second
let boosterTimeDelayValue = 1 // please set booster dealy time

var currentXValue = 5
var isBombBecomesActivefirstTime = "isBombBecomesActivefirstTime"
let color_number = "Color_number"
let color_numberActive = "Color_numberActive"
let bomb_s = "Bomb_s"
let bomb_sActive = "bomb_sActive"
let newWindow = "new_window"
let inactiveNewWindow = "inactive_new_window"



let mysteryWin1Paint = 15
let mysteryWin2Paint = 30
let mysteryWin3Hints = 15
let mysteryWin4Hints = 10
let mysteryWin5Reward = 15
let mysteryWin6Reward = 10
let mysteryWin7Hints = 5
let mysteryWin8Paint = 5
let mysteryWin = "Mystery_win"
let inactiveMysteryWindow = "inactive_mystery_window"

let editorBGColor:UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.00)
let journeyBGColor:UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.00)
let popularBGColor:UIColor = UIColor(red: 0.93, green: 0.91, blue: 0.91, alpha: 1.00)
let collectionBGColor:UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.00)
let RecentBGColor:UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)

let editorCollectionCount = 20
let popularCollectionCount = 30 //30
let collectionsCollectionCount = 25
var colorNumber = 0
var bomb_sNumber = 0
var new_windowNumber = 0

let gift_1_first = "gift_1_first"

let resultsInMyWork = "Result_In_MyWork"
let resultsInRecent = "Result_In_Recent"
let viewedInCollection = "Viewed_In_Collection"
let Completed_ID_Key = "mywork_completed_id"

let notificationStatus = "notificationStatus"
var isNotificationTap : Bool = false
var isFromHomeView : Bool = false

//Spacing variables for all collections screen

var middle_spacing_iphone = 15.0
var middle_spacing_ipad = 25.0

var side_spacing_landscape = 100.0
var side_spacing_potrait = 25.0
var side_spacing_ios = 10.0

// Device Orentation
var potraitOrientation : Bool = false
var landsacpeOrientation : Bool = false
var currentOrientation: Bool = true
var backgroundOrientation: Bool = true

var isFromPlayVC: Bool = false
let adsTimeDelayValue = 30  // please set Ads dealy time
let adsTimeComponent: Calendar.Component = .second //.day //.hour //.minute //.second

// Reward Ad Id's
var PAGES_MY_WORK_REWARD_Id = "ca-app-pub-7682495659460581/7532177252"
var DRAWING_SCREEN_REWARD_Id = "ca-app-pub-7682495659460581/4072315560"
var PLAY_VIDEO_SCREEN_REWARD_Id = "ca-app-pub-7682495659460581/7532177252"

var INTERSIAL_AD_Unit_Id = "ca-app-pub-7682495659460581/2271863322"
let REWARD_LOAD = "RewardAd"
let isSoundEnabled = "isSoundEnabled"
