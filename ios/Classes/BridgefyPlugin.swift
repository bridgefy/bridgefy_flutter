import Flutter
import UIKit
import BridgefySDK

public class BridgefyPlugin: NSObject, FlutterPlugin, BridgefyDelegate {
  private var channel: FlutterMethodChannel
  private var bridgefy: Bridgefy?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bridgefy", binaryMessenger: registrar.messenger())
    let instance = BridgefyPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "initialize":
      initialize(call, result: result)
      break
    case "start":
      start(call, result: result)
      break
    case "send":
      send(call, result: result)
      break
    case "stop":
      stop(call, result: result)
      break
    case "connectedPeers":
      connectedPeers(call, result: result)
      break
    case "currentUserID":
      currentUserID(call, result: result)
      break
    case "establishSecureConnection":
      establishSecureConnection(call, result: result)
      break
    case "licenseExpirationDate":
      licenseExpirationDate(call, result: result)
      break
    case "destroySession":
      destroySession(call, result: result)
      break
    case "updateLicense":
      updateLicense(call, result: result)
      break
    default:
      result(FlutterMethodNotImplemented)
      break
    }
  }

  // MARK: Delegate

  public func bridgefyDidStart(with userId: UUID) {
    channel.invokeMethod("bridgefyDidStart",
                         arguments: ["userId": userId.uuidString])
  }

  public func bridgefyDidFailToStart(with error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToStart",
                         arguments: ["error": errorDictionary(from: error)])
  }

  public func bridgefyDidStop() {
    channel.invokeMethod("bridgefyDidStop",
                         arguments: nil)
  }

  public func bridgefyDidFailToStop(with error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToStop",
                         arguments: ["error": errorDictionary(from: error)])
  }

  public func bridgefyDidDestroySession() {
    channel.invokeMethod("bridgefyDidDestroySession",
                         arguments: nil)
  }

  public func bridgefyDidFailToDestroySession(with error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToDestroySession",
                         arguments: ["error": errorDictionary(from: error)])
  }

  public func bridgefyDidConnect(with userId: UUID) {
    channel.invokeMethod("bridgefyDidConnect",
                         arguments: ["userId": userId.uuidString])
  }

  public func bridgefyDidDisconnect(from userId: UUID) {
    channel.invokeMethod("bridgefyDidDisconnect",
                         arguments: ["userId": userId.uuidString])
  }

  public func bridgefyDidEstablishSecureConnection(with userId: UUID) {
    channel.invokeMethod("bridgefyDidEstablishSecureConnection",
                         arguments: ["userId": userId.uuidString])
  }

  public func bridgefyDidFailToEstablishSecureConnection(with userId: UUID,
                                                         error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToEstablishSecureConnection",
                         arguments: [
                          "userId": userId.uuidString,
                          "error": errorDictionary(from: error)
                         ] as [String : Any])
  }

  public func bridgefyDidSendMessage(with messageId: UUID) {
    channel.invokeMethod("bridgefyDidSendMessage",
                         arguments: ["messageId": messageId.uuidString])
  }

  public func bridgefyDidFailSendingMessage(with messageId: UUID,
                                            withError error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailSendingMessage",
                         arguments: [
                          "messageId": messageId.uuidString,
                          "error": errorDictionary(from: error)
                         ] as [String : Any])
  }

  public func bridgefyDidReceiveData(_ data: Data,
                                     with messageId: UUID,
                                     using transmissionMode: BridgefySDK.TransmissionMode) {
    channel.invokeMethod("bridgefyDidReceiveData",
                         arguments: [
                          "data": data,
                          "messageId": messageId.uuidString,
                          "transmissionMode": transmissionModeDictionary(from: transmissionMode)
                         ] as [String : Any])
  }

  // MARK: Methods

  private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as! Dictionary<String, Any>
    let apiKey = args["apiKey"] as! String
    let verboseLogging = args["verboseLogging"] as! Bool
    do {
      bridgefy = try Bridgefy(withApiKey: apiKey,
                              delegate: self,
                              verboseLogging: verboseLogging)
      result(nil)
    } catch let error {
      result(flutterError(from: error as! BridgefyError))
    }
  }

  private func start(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as! Dictionary<String, Any>
    let userId = args["userId"] as? String
    let profileStr = args["propagationProfile"] as! String
    let propagationProfile = propagationProfile(from: profileStr)!
    if let userId = userId {
        let uuid = UUID(uuidString: userId)!
        bridgefy?.start(withUserId: uuid, andPropagationProfile: propagationProfile)
    }else{
        bridgefy?.start(withUserId: nil,
                      andPropagationProfile: propagationProfile)
    }
    result(nil)
  }

  private func send(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as! Dictionary<String, Any>
    let data = args["data"] as! FlutterStandardTypedData
    let transmissionModeDict = args["transmissionMode"] as! Dictionary<String, String>;
    let transmissionMode = transmissionMode(from: transmissionModeDict)!
    do {
      let uuid = try bridgefy!.send(data.data, using: transmissionMode)
      result(["messageId": uuid.uuidString])
    } catch let error {
      result(flutterError(from: error as! BridgefyError))
    }
  }

  private func stop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    bridgefy!.stop()
    result(nil)
  }

  private func connectedPeers(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(["connectedPeers": bridgefy!.connectedPeers!.map({ uuid in
      uuid.uuidString
    })])
  }

  private func currentUserID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(["userId": bridgefy!.currentUserId!.uuidString])
  }

  private func establishSecureConnection(_ call: FlutterMethodCall,
                                         result: @escaping FlutterResult) {
    let args = call.arguments as! Dictionary<String, Any>
    let uuidStr = args["userId"] as! String
    let uuid = UUID(uuidString: uuidStr)!
    bridgefy!.establishSecureConnection(with: uuid)
    result(nil)
  }

  private func licenseExpirationDate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let interval = bridgefy!.licenseExpirationDate?.timeIntervalSince1970 {
      result(["licenseExpirationDate": interval * 1000])
    } else {
      result(nil)
    }
  }

  private func destroySession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    bridgefy!.destroySession()
    result(nil)
  }

  private func updateLicense(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    //bridgefy!.updateLicense()
    result(nil)
  }

  // MARK: Utils

  private func propagationProfile(from string: String) -> PropagationProfile? {
    switch (string) {
    case "highDensityNetwork":
      return .highDensityNetwork
    case "sparseNetwork":
      return .sparseNetwork
    case "longReach":
      return .longReach
    case "shortReach":
      return .shortReach
    case "standard":
      return .standard
    default:
      return nil
    }
  }

  private func transmissionMode(from dict: Dictionary<String, String>) -> TransmissionMode? {
    if let mode = dict["mode"],
       let uuidStr = dict["uuid"],
       let uuid = UUID(uuidString: uuidStr) {
      switch mode {
      case "p2p":
        return .p2p(userId: uuid)
      case "mesh":
        return .mesh(userId: uuid)
      case "broadcast":
        return .broadcast(senderId: uuid)
      default:
        return nil
      }
    }
    return nil;
  }

  private func transmissionModeDictionary(from transmissionMode: TransmissionMode)
    -> Dictionary<String, String> {
    switch transmissionMode {
    case .p2p(userId: let uuid):
      return ["mode": "p2p", "uuid": uuid.uuidString]
    case .mesh(userId: let uuid):
      return ["mode": "mesh", "uuid": uuid.uuidString]
    case .broadcast(senderId: let uuid):
      return ["mode": "broadcast", "uuid": uuid.uuidString]
    @unknown default:
      return [:]
    }
  }

  private func errorDictionary(from bridgefyError: BridgefyError) -> Dictionary<String, Any?> {
    var type: String
    var details: Int?
    switch bridgefyError {
    case .licenseError(code: let code):
      type = "licenseError"
      details = code
      break
    case .simulatorIsNotSupported:
      type = "simulatorIsNotSupported"
      break
    case .notStarted:
      type = "notStarted"
      break;
    case .alreadyInstantiated:
      type = "alreadyInstantiated"
      break;
    case .startInProgress:
      type = "startInProgress"
      break;
    case .alreadyStarted:
      type = "alreadyStarted"
      break;
    case .serviceNotStarted:
      type = "serviceNotStarted"
      break;
    case .missingBundleID:
      type = "missingBundleID"
      break;
    case .invalidApiKey:
      type = "invalidAPIKey"
      break;
    case .internetConnectionRequired:
      type = "internetConnectionRequired"
      break
    case .sessionError:
      type = "sessionError"
      break
    case .expiredLicense:
      type = "expiredLicense"
      break
    case .inconsistentDeviceTime:
      type = "inconsistentDeviceTime"
      break
    case .BLEUsageNotGranted:
      type = "BLEUsageNotGranted"
      break
    case .BLEUsageRestricted:
      type = "BLEUsageRestricted"
      break
    case .BLEPoweredOff:
      type = "BLEPoweredOff"
      break
    case .BLEUnsupported:
      type = "BLEUnsupported"
      break
    case .BLEUnknownError:
      type = "BLEUnknownError"
      break
    case .inconsistentConnection:
      type = "inconsistentConnection"
      break
    case .connectionIsAlreadySecure:
      type = "connectionIsAlreadySecure"
      break
    case .cannotCreateSecureConnection:
      type = "cannotCreateSecureConnection"
      break
    case .dataLengthExceeded:
      type = "dataLengthExceeded"
      break
    case .dataValueIsEmpty:
      type = "dataValueIsEmpty"
      break
    case .peerIsNotConnected:
      type = "peerIsNotConnected"
      break
    case .internalError:
      type = "internalError"
      break
    case .storageError(code: let code):
      type = "storageError"
      details = code
      break
    case .encodingError(code: let code):
      type = "encodingError"
      details = code
      break
    case .encryptionError(code: let code):
      type = "encryptionError"
      details = code
      break;
    @unknown default:
      return [:]
    }
    return ["code": type, "message": bridgefyError.localizedDescription, "details": details]
  }

  private func flutterError(from bridgefyError: BridgefyError) -> FlutterError {
    let dict = errorDictionary(from: bridgefyError)
    return FlutterError(
      code: dict["code"] as! String,
      message: dict["message"] as? String,
      details: dict["details"] as? Int
    )
  }
}
