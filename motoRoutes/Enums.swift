//
//  Enums.swift
//  motoRoutes
//
//  Created by Peter Pohlmann on 18.12.16.
//  Copyright © 2016 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit

enum FuncTypes: String {
    case Recording
    case PrintMarker
    case PrintBaseHeight
    case PrintAltitude
    case PrintCircles
    case PrintStartEnd
    case Default
    
    init(){
        self = .Default
    }
}

enum LabelType {
    case duration
    case altitude
    case speed
    
    var image: UIImage {
        switch self {
        case .duration: return UIImage(named: "durationIcon.png")!
        case .altitude: return UIImage(named: "altitudeIcon.png")!
        case .speed: return UIImage(named: "speedIcon.png")!
        }
    }
    
    var label: String{
        switch self {
        case .duration: return durationLabelText
        case .altitude: return highestAltitudeLabelText
        case .speed: return highspeedLabelText
        }
    }
}

enum ActionButtonType {
    case DefState
    case Details
    case DeleteRoute
    case DeleteRouteFIR
    case ShareRoute
    case DownloadRoute
    case ConfirmDelete
    case ConfirmDeleteFIR
    case ConfirmShare
    case ConfirmDownload
    case ProgressShare
    case ProgressDelete
    case ProgressDeleteFIR
    case ProgressDownload
    case Cancel
    case Done
    case ActionMenuMyRoutes
    case MenuInfoLabels
    case MenuActionButton
    case MenuConfirm
    case CloseMarkerView
    
    var buttonText: String {
        switch self {
        case .DefState: return "defState"
        case .Details: return actionButtonDetailsText
        case .DeleteRoute: return actionButtonDeleteRouteText
        case .DeleteRouteFIR: return actionButtonDeleteRouteFIRText
        case .ShareRoute: return actionButtonShareRouteText
        case .DownloadRoute: return actionButtonDownloadRouteText
        case .ConfirmDelete: return "OK"
        case .ConfirmDeleteFIR: return "OK"
        case .ConfirmShare: return "OK"
        case .ConfirmDownload : return "OK"
        case .ProgressShare: return actionButtonProgressShare
        case .ProgressDelete: return actionButtonProgressDelete
        case .ProgressDeleteFIR: return actionButtonProgressDeleteFIR
        case .ProgressDownload: return actionButtonProgressDownload
        case .Cancel: return "Cancel"
        case .Done: return actionButtonProgressDone
        case .ActionMenuMyRoutes: return "ActionMenuMyRoutes"
        case .MenuInfoLabels: return "MenuInfoLabels"
        case .MenuActionButton: return "MenuActionButton"
        case .MenuConfirm: return "MenuConfirm"
        case .CloseMarkerView: return ""
        }
    }
    
    var confirmText: String {
        switch self {
        case .DefState: return "defState Confirm"
        case .Details: return "show details"
        case .DeleteRoute: return actionButtonConfirmDeleteText
        case .DeleteRouteFIR: return actionButtonConfirmDeleteFIRText
        case .ShareRoute: return actionButtonConfirmShareText
        case .DownloadRoute: return actionButtonConfirmDownloadText
        case .ConfirmDelete: return "---"
        case .ConfirmDeleteFIR: return "---"
        case .ConfirmShare: return "--"
        case .ConfirmDownload: return "--"
        case .ProgressShare: return "--"
        case .ProgressDelete: return "--"
        case .ProgressDeleteFIR: return "--"
        case .ProgressDownload: return "--"
        case .Cancel: return "---"
        case .Done: return "---"
        case .ActionMenuMyRoutes: return "---"
        case .MenuInfoLabels: return "MenuInfoLabels"
        case .MenuActionButton: return "MenuActionButton"
        case .MenuConfirm: return "MenuConfirm"
        case .CloseMarkerView: return "--"
        }
    }
    
    var confirmAction: ActionButtonType{
        switch self {
        case .DefState: return ActionButtonType.DefState
        case .Details: return ActionButtonType.Details
        case .DeleteRoute: return ActionButtonType.ConfirmDelete
        case .DeleteRouteFIR: return ActionButtonType.ConfirmDeleteFIR
        case .ShareRoute: return ActionButtonType.ConfirmShare
        case .DownloadRoute: return ActionButtonType.ConfirmDownload
        case .ConfirmDelete: return ActionButtonType.ConfirmDelete
        case .ConfirmDeleteFIR: return ActionButtonType.ConfirmDeleteFIR
        case .ConfirmShare: return ActionButtonType.ConfirmShare
        case .ConfirmDownload: return ActionButtonType.ConfirmDownload
        case .ProgressShare: return ActionButtonType.DefState
        case .ProgressDelete: return ActionButtonType.DefState
        case .ProgressDeleteFIR: return ActionButtonType.DefState
        case .ProgressDownload: return ActionButtonType.DefState
        case .Cancel: return ActionButtonType.DefState
        case .Done: return ActionButtonType.DefState
        case .ActionMenuMyRoutes: return ActionButtonType.DefState
        case .MenuInfoLabels: return ActionButtonType.DefState
        case .MenuActionButton: return ActionButtonType.DefState
        case .MenuConfirm: return ActionButtonType.DefState
        case .CloseMarkerView: return ActionButtonType.DefState
        }
    }
    
    var buttonImage: UIImage{
        switch self {
        case .DefState: return UIImage()
        case .Details: return UIImage()
        case .DeleteRoute: return UIImage()
        case .DeleteRouteFIR: return UIImage()
        case .ShareRoute: return UIImage()
        case .DownloadRoute: return UIImage()
        case .ConfirmDelete: return UIImage()
        case .ConfirmDeleteFIR: return UIImage()
        case .ConfirmShare: return UIImage()
        case .ConfirmDownload: return UIImage()
        case .ProgressShare: return UIImage()
        case .ProgressDelete: return UIImage()
        case .ProgressDeleteFIR: return UIImage()
        case .ProgressDownload: return UIImage()
        case .Cancel: return UIImage()
        case .Done: return UIImage()
        case .ActionMenuMyRoutes: return (UIImage(named: "menuBtn") as UIImage?)!
        case .MenuInfoLabels: return (UIImage(named: "backBtn") as UIImage?)!
        case .MenuActionButton: return (UIImage(named: "cancelBtn") as UIImage?)!
        case .MenuConfirm: return UIImage()
        case .CloseMarkerView: return (UIImage(named: "closeBtn") as UIImage?)!
        }
    }
    
    init(){
        self = .DefState
    }
}

enum MarkerViewType {
    case MyRoute
    case FirRoute
    case DotView
    
    init(){
        self = .MyRoute
    }
}

enum AnimationType {
    case offToRight
    case offToLeft
    case onFromLeft
    case onFromLeftSimultan
    case offToRightSimultan
    
    init(){
        self = .onFromLeft
    }
}

enum MarkerViewState{
    case InfoLabelState
    case ActionButtonsState
    case ConfirmViewState
    
    init(){
        self = .InfoLabelState
    }
}

enum ProgressDoneType{
    case ProgressDoneDelete
    case ProgressDoneShare
    case ProgressDoneDownload
    case ProgressDoneDef
    
    init(){
        self = .ProgressDoneDef
    }
}
