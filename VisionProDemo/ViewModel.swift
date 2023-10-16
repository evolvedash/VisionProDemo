//
//  ViewModel.swift
//  WallArt
//
//  Created by macmini on 13/10/2023.
//

import Foundation
import Observation

enum FlowState {
    case idle
    case into
    case projectileFlying
    case updateWallArt
}


@Observable
class ViewModel {
    var flowState = FlowState.idle
}
