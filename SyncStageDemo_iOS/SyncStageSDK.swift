//
//  SyncStageSDK.swift
//  SyncStageDemo_iOS
//
//  Created by Bilal Mahfouz on 01/06/2022.
//

import Foundation
import SyncStageSDK

protocol SyncStageDelegate {
    func onOperationError(errorCode: SyncStageErrorCode, message: String)
    func onConnectionDataChange(connectionData: ConnectionData)
    func onStreamListChange(connectionData: ConnectionData)
}

class SyncStageManager {

    public static let shared = SyncStageManager()
    private var syncStage: SyncStage!

    var delegate: SyncStageDelegate?

    func initSDK(accessToken: String, userId: Int, completion: @escaping (_ error: SyncStageSDK.SyncStageError?) -> Void) {
        syncStage = SyncStage(accessToken: accessToken, userId: userId) { [weak self] errorCode, message in
            self?.delegate?.onOperationError(errorCode: errorCode, message: message)
        } onConnectionDataChange: { [weak self] connectionData in
            self?.delegate?.onConnectionDataChange(connectionData: connectionData)
        } onStreamListChange: { [weak self] connectionData in
            self?.delegate?.onStreamListChange(connectionData: connectionData)
        } completion: { error in
            completion(error)
        }
    }

    func connect(_ completion: @escaping (SyncStageSDK.SyncStageError?) -> Void) {
        syncStage.connect(completion)
    }

    func disconnect(_ completion: @escaping (SyncStageSDK.SyncStageError?) -> Void) {
        syncStage.disconnect(completion)
    }

    func getExpirationTime() -> Int64? {
        return syncStage.getExpirationTime()
    }

    func isInitialized() -> Bool {
        return syncStage.isInitialized()
    }

    func getConnectionData() -> ConnectionData? {
        return syncStage.getConnectionData()
    }

    func changeStreamVolume(with streamId: String, volume: Int) -> SyncStageErrorCode {
        return syncStage.changeStreamVolume(with: streamId, volume: volume)
    }
    
    func getSDKVersion() -> String {
        return syncStage.getSDKVersion()
    }
}
