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
    default:
      break
    }
  }

  public func bridgefyDidStart(with userId: UUID) {
    channel.invokeMethod("bridgefyDidStart",
                         arguments: ["userId": userId])
  }

  public func bridgefyDidFailToStart(with error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToStart",
                         arguments: ["error": error])
  }

  public func bridgefyDidStop() {
    channel.invokeMethod("bridgefyDidStop",
                         arguments: nil)
  }

  public func bridgefyDidFailToStop(with error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToStop",
                         arguments: ["error": error])
  }

  public func bridgefyDidDestroySession() {
    channel.invokeMethod("bridgefyDidDestroySession",
                         arguments: nil)
  }

  public func bridgefyDidFailToDestroySession() {
    channel.invokeMethod("bridgefyDidFailToDestroySession",
                         arguments: nil)
  }

  public func bridgefyDidConnect(with userId: UUID) {
    channel.invokeMethod("bridgefyDidConnect",
                         arguments: ["userId": userId])
  }

  public func bridgefyDidDisconnect(from userId: UUID) {
    channel.invokeMethod("bridgefyDidDisconnect",
                         arguments: ["userId": userId])
  }

  public func bridgefyDidEstablishSecureConnection(with userId: UUID) {
    channel.invokeMethod("bridgefyDidEstablishSecureConnection",
                         arguments: ["userId": userId])
  }

  public func bridgefyDidFailToEstablishSecureConnection(with userId: UUID,
                                                         error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToEstablishSecureConnection",
                         arguments: ["userId": userId, "error": error] as [String : Any])
  }

  public func bridgefyDidSendMessage(with messageId: UUID) {
    channel.invokeMethod("bridgefyDidSendMessage",
                         arguments: ["messageId": messageId])
  }

  public func bridgefyDidFailSendingMessage(with messageId: UUID,
                                            withError error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailSendingMessage",
                         arguments: ["messageId": messageId, "error": error] as [String : Any])
  }

  public func bridgefyDidReceiveData(_ data: Data,
                                     with messageId: UUID,
                                     using transmissionMode: BridgefySDK.TransmissionMode) {
    channel.invokeMethod("bridgefyDidReceiveData",
                         arguments: [
                          "data": data,
                          "messageId": messageId,
                          "transmissionMode": transmissionMode
                         ] as [String : Any])
  }

  private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let args = call.arguments as? Dictionary<String, Any>,
       let apiKey = args["apiKey"] as? String,
       let profileStr = args["propagationProfile"] as? String,
       let verboseLogging = args["verboseLogging"] as? Bool {
      do {
        bridgefy = try Bridgefy(withApiKey: apiKey,
                                propagationProfile: propagationProfile(from: profileStr),
                                delegate: self,
                                verboseLogging: verboseLogging)
        result(true)
      } catch let e as BridgefyError {
        result(error(from: e))
      } catch {
        result(false)
      }
    }
  }

  private func start(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    bridgefy?.start()
  }

  private func send(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let bridgefy = bridgefy,
       let args = call.arguments as? Dictionary<String, Any>,
       let data = args["data"] as? Data,
       let transmissionMode = args["transmissionMode"] as? TransmissionMode {
      do {
        let uuid = try bridgefy.send(data, using: transmissionMode)
        result(uuid.uuidString)
      } catch {
        //
      }
    }
  }

  private func stop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    bridgefy?.stop()
  }

  private func propagationProfile(from string: String) -> PropagationProfile {
    switch (string) {
    case "highDensityNetwork":
      return .highDensityNetwork
    case "sparseNetwork":
      return .sparseNetwork
    case "longReach":
      return .longReach
    case "shortReach":
      return .shortReach
    default:
      return .standard
    }
  }

//  private func transmissionMode(from string: String) -> TransmissionMode {
//    switch (string) {
//    case "p2p":
//      return .p2p(userId: <#T##UUID#>)
//    default:
//      return .broadcast(senderId: <#T##UUID#>)
//    }
//  }

  private func error(from bridgefyError: BridgefyError) -> Dictionary<String, Any> {
    switch bridgefyError {
    case .licenseError(code: let code):
      return ["error": "licenseError", "code": code]
    case .simulatorIsNotSupported:
      return ["error": "simulatorIsNotSupported"]
    case .notStarted:
      return ["error": "notStarted"]
    case .alreadyInstantiated:
      return ["error": "alreadyInstantiated"]
    case .startInProgress:
      return ["error": "startInProgress"]
    case .alreadyStarted:
      return ["error": "alreadyStarted"]
    case .serviceNotStarted:
      return ["error": "serviceNotStarted"]
    case .missingBundleID:
      return ["error": "missingBundleID"]
    case .invalidAPIKey:
      return ["error": "invalidAPIKey"]
    case .internetConnectionRequired:
      return ["error": "internetConnectionRequired"]
    case .sessionError:
      return ["error": "sessionError"]
    case .expiredLicense:
      return ["error": "expiredLicense"]
    case .inconsistentDeviceTime:
      return ["error": "inconsistentDeviceTime"]
    case .BLEUsageNotGranted:
      return ["error": "BLEUsageNotGranted"]
    case .BLEUsageRestricted:
      return ["error": "BLEUsageRestricted"]
    case .BLEPoweredOff:
      return ["error": "BLEPoweredOff"]
    case .BLEUnsupported:
      return ["error": "BLEUnsupported"]
    case .BLEUnknownError:
      return ["error": "BLEUnknownError"]
    case .inconsistentConnection:
      return ["error": "inconsistentConnection"]
    case .connectionIsAlreadySecure:
      return ["error": "connectionIsAlreadySecure"]
    case .cannotCreateSecureConnection:
      return ["error": "cannotCreateSecureConnection"]
    case .dataLengthExceeded:
      return ["error": "dataLengthExceeded"]
    case .dataValueIsEmpty:
      return ["error": "dataValueIsEmpty"]
    case .peerIsNotConnected:
      return ["error": "peerIsNotConnected"]
    case .internalError:
      return ["error": "internalError"]
    case .storageError(code: let code):
      return ["error": "storageError", "code": code]
    case .encodingError(code: let code):
      return ["error": "encodingError", "code": code]
    case .encryptionError(code: let code):
      return ["error": "encryptionError", "code": code]
    @unknown default:
      return [:]
    }
  }
}
