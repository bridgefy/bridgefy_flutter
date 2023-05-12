package me.bridgefy.bridgefy

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.bridgefy.Bridgefy
import me.bridgefy.commons.TransmissionMode
import me.bridgefy.commons.exception.BridgefyException
import me.bridgefy.commons.listener.BridgefyDelegate
import me.bridgefy.commons.propagation.PropagationProfile
import java.util.Dictionary
import java.util.UUID

/** BridgefyPlugin */
@Suppress("UNCHECKED_CAST")
class BridgefyPlugin: FlutterPlugin, MethodCallHandler, BridgefyDelegate {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var bridgefy : Bridgefy

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bridgefy")
    channel.setMethodCallHandler(this)
    bridgefy = Bridgefy(flutterPluginBinding.applicationContext)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> initialize(call, result)
      "start" -> start(call, result)
      "send" -> send(call, result)
      "stop" -> stop(call, result)
      "connectedPeers" -> connectedPeers(call, result)
      "currentUserID" -> currentUserID(call, result)
      "establishSecureConnection" -> establishSecureConnection(call, result)
      "licenseExpirationDate" -> licenseExpirationDate(call, result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun initialize(@NonNull call: MethodCall, @NonNull result: Result) {
    val args = call.arguments as Dictionary<String, Any>
    val apiKey = args["apiKey"] as String
    val profileStr = args["propagationProfile"] as String
    val propagationProfile = propagationProfileFromString(profileStr)
    try {
      bridgefy.init(UUID.fromString(apiKey), propagationProfile!!, this)
      result.success(null)
    } catch (error: BridgefyException) {
      result.error("test", "x", "y");
    }
  }

  private fun start(@NonNull call: MethodCall, @NonNull result: Result) {
    //
  }

  private fun send(@NonNull call: MethodCall, @NonNull result: Result) {
    //
  }

  private fun stop(@NonNull call: MethodCall, @NonNull result: Result) {
    //
  }

  private fun connectedPeers(@NonNull call: MethodCall, @NonNull result: Result) {
    //
  }

  private fun currentUserID(@NonNull call: MethodCall, @NonNull result: Result) {
    //
  }

  private fun establishSecureConnection(@NonNull call: MethodCall, @NonNull result: Result) {
    //
  }

  private fun licenseExpirationDate(@NonNull call: MethodCall, @NonNull result: Result) {
    //
  }

  override fun onConnected(userID: UUID) {
    TODO("Not yet implemented")
  }

  override fun onConnectedPeers(connectedPeers: List<UUID>) {
    TODO("Not yet implemented")
  }

  override fun onConnectedSecurely(userID: UUID) {
    TODO("Not yet implemented")
  }

  override fun onDisconnected(userID: UUID) {
    TODO("Not yet implemented")
  }

  override fun onFailToSend(messageID: UUID) {
    TODO("Not yet implemented")
  }

  override fun onFailToStart(error: BridgefyException) {
    TODO("Not yet implemented")
  }

  override fun onFailToStop(error: BridgefyException) {
    TODO("Not yet implemented")
  }

  override fun onProgressOfSend(messageID: UUID, position: Int, of: Int) {
    TODO("Not yet implemented")
  }

  override fun onReceive(data: ByteArray, messageID: UUID, transmissionMode: TransmissionMode) {
    TODO("Not yet implemented")
  }

  override fun onSend(messageID: UUID) {
    TODO("Not yet implemented")
  }

  override fun onStarted(userID: UUID) {
    TODO("Not yet implemented")
  }

  override fun onStopped() {
    TODO("Not yet implemented")
  }

  private fun propagationProfileFromString(str: String) : PropagationProfile? {
    return when (str) {
      "highDensityNetwork" -> PropagationProfile.HighDensityEnvironment
      "sparseNetwork" -> PropagationProfile.SparseEnvironment
      "longReach" -> PropagationProfile.LongReach
      "shortReach" -> PropagationProfile.ShortReach
      "standard" -> PropagationProfile.Standard
      else -> null
    }
  }
}
