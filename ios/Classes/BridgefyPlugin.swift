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
    if (call.method == "start") {
      if let apiKey = call.arguments as? String {
        do {
          bridgefy = try Bridgefy(withApiKey: apiKey, delegate: self)
          bridgefy?.start()
        } catch let error as BridgefyError {
          bridgefyDidFailToStart(with: error)
        } catch {
          //
        }
      }
    } else if let bridgefy = bridgefy {
      switch (call.method) {
      case "stop":
        bridgefy.stop()
        break
      default:
        break
      }
    }
  }

  public func bridgefyDidStart(with userId: UUID) {
    channel.invokeMethod("bridgefyDidStart", arguments: userId)
  }

  public func bridgefyDidFailToStart(with error: BridgefySDK.BridgefyError) {
    channel.invokeMethod("bridgefyDidFailToStart", arguments: error)
  }

  public func bridgefyDidStop() {
//
  }
  
  public func bridgefyDidFailToStop(with error: BridgefySDK.BridgefyError) {
//
  }
  
  public func bridgefyDidDestroySession() {
//
  }
  
  public func bridgefyDidFailToDestroySession() {
//
  }
  
  public func bridgefyDidConnect(with userId: UUID) {
//
  }
  
  public func bridgefyDidDisconnect(from userId: UUID) {
//
  }
  
  public func bridgefyDidEstablishSecureConnection(with userId: UUID) {
//
  }
  
  public func bridgefyDidFailToEstablishSecureConnection(with userId: UUID, error: BridgefySDK.BridgefyError) {
//
  }
  
  public func bridgefyDidSendMessage(with messageId: UUID) {
//
  }
  
  public func bridgefyDidFailSendingMessage(with messageId: UUID, withError error: BridgefySDK.BridgefyError) {
//
  }
  
  public func bridgefyDidReceiveData(_ data: Data, with messageId: UUID, using transmissionMode: BridgefySDK.TransmissionMode) {
//
  }
}
