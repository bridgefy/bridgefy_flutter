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
    default:
      break
    }
  }

  // MARK: Delegate

  public func bridgefyDidStart(with userId: UUID) {
    channel.invokeMethod("bridgefyDidStart",
                         arguments: ["userId": userId])
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
                         arguments: [
                          "userId": userId,
                          "error": errorDictionary(from: error)
                         ] as [String : Any])
  }

  public func bridgefyDidSendMessage(with messageId: UUID) {
    channel.invokeMethod("bridgefyDidSendMessage",
                         arguments: ["messageId": messageId])
  }

  public func bridgefyDidFailSendingMessage(with messageId: UUID,
                                            withError error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailSendingMessage",
                         arguments: [
                          "messageId": messageId,
                          "error": errorDictionary(from: error)
                         ] as [String : Any])
  }

  public func bridgefyDidReceiveData(_ data: Data,
                                     with messageId: UUID,
                                     using transmissionMode: BridgefySDK.TransmissionMode) {
    channel.invokeMethod("bridgefyDidReceiveData",
                         arguments: [
                          "data": data,
                          "messageId": messageId,
                          "transmissionMode": transmissionModeDictionary(from: transmissionMode)
                         ] as [String : Any])
  }

  // MARK: Methods

  private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let args = call.arguments as? Dictionary<String, Any>,
       let apiKey = args["apiKey"] as? String,
       let profileStr = args["propagationProfile"] as? String,
       let propagationProfile = propagationProfile(from: profileStr),
       let verboseLogging = args["verboseLogging"] as? Bool {
      do {
        bridgefy = try Bridgefy(withApiKey: apiKey,
                                propagationProfile: propagationProfile,
                                delegate: self,
                                verboseLogging: verboseLogging)
        result(nil)
      } catch let error as BridgefyError {
        result(["error": errorDictionary(from: error)])
      } catch {
        result(nil)
      }
    } else {
      result(nil)
    }
  }

  private func start(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    bridgefy?.start()
    result(nil)
  }

  private func send(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let bridgefy = bridgefy,
       let args = call.arguments as? Dictionary<String, Any>,
       let data = args["data"] as? Data,
       let transmissionMode = args["transmissionMode"] as? TransmissionMode {
      do {
        let uuid = try bridgefy.send(data, using: transmissionMode)
        result(["messageID": uuid.uuidString])
      } catch let error as BridgefyError {
        result(["error": errorDictionary(from: error)])
      } catch {
        result(nil)
      }
    } else {
      result(nil)
    }
  }

  private func stop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    bridgefy?.stop()
    result(nil)
  }

  private func connectedPeers(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // TODO
  }

  private func currentUserID(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // TODO
  }

  private func establishSecureConnection(_ call: FlutterMethodCall,
                                         result: @escaping FlutterResult) {
    // TODO
  }

  private func licenseExpirationDate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // TODO
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

  private func errorDictionary(from bridgefyError: BridgefyError) -> Dictionary<String, Any> {
    switch bridgefyError {
    case .licenseError(code: let code):
      return ["type": "licenseError", "code": code]
    case .simulatorIsNotSupported:
      return ["type": "simulatorIsNotSupported"]
    case .notStarted:
      return ["type": "notStarted"]
    case .alreadyInstantiated:
      return ["type": "alreadyInstantiated"]
    case .startInProgress:
      return ["type": "startInProgress"]
    case .alreadyStarted:
      return ["type": "alreadyStarted"]
    case .serviceNotStarted:
      return ["type": "serviceNotStarted"]
    case .missingBundleID:
      return ["type": "missingBundleID"]
    case .invalidAPIKey:
      return ["type": "invalidAPIKey"]
    case .internetConnectionRequired:
      return ["type": "internetConnectionRequired"]
    case .sessionError:
      return ["type": "sessionError"]
    case .expiredLicense:
      return ["type": "expiredLicense"]
    case .inconsistentDeviceTime:
      return ["type": "inconsistentDeviceTime"]
    case .BLEUsageNotGranted:
      return ["type": "BLEUsageNotGranted"]
    case .BLEUsageRestricted:
      return ["type": "BLEUsageRestricted"]
    case .BLEPoweredOff:
      return ["type": "BLEPoweredOff"]
    case .BLEUnsupported:
      return ["type": "BLEUnsupported"]
    case .BLEUnknownError:
      return ["type": "BLEUnknownError"]
    case .inconsistentConnection:
      return ["type": "inconsistentConnection"]
    case .connectionIsAlreadySecure:
      return ["type": "connectionIsAlreadySecure"]
    case .cannotCreateSecureConnection:
      return ["type": "cannotCreateSecureConnection"]
    case .dataLengthExceeded:
      return ["type": "dataLengthExceeded"]
    case .dataValueIsEmpty:
      return ["type": "dataValueIsEmpty"]
    case .peerIsNotConnected:
      return ["type": "peerIsNotConnected"]
    case .internalError:
      return ["type": "internalError"]
    case .storageError(code: let code):
      return ["type": "storageError", "code": code]
    case .encodingError(code: let code):
      return ["type": "encodingError", "code": code]
    case .encryptionError(code: let code):
      return ["type": "encryptionError", "code": code]
    @unknown default:
      return [:]
    }
  }
}
