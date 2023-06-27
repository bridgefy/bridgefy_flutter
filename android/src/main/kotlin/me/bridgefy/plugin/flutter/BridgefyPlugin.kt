package me.bridgefy.plugin.flutter

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import me.bridgefy.Bridgefy
import me.bridgefy.commons.TransmissionMode
import me.bridgefy.commons.exception.BridgefyException
import me.bridgefy.commons.listener.BridgefyDelegate
import me.bridgefy.commons.propagation.PropagationProfile
import java.util.UUID

/** BridgefyPlugin */
@Suppress("UNCHECKED_CAST")
class BridgefyPlugin : FlutterPlugin, MethodCallHandler {
    // / The MethodChannel that will the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var bridgefy: Bridgefy

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
        val args = call.arguments as HashMap<String, Any>
        val apiKey = args["apiKey"] as String
        val profileStr = args["propagationProfile"] as String
        val propagationProfile = propagationProfileFromString(profileStr)
        try {
            bridgefy.init(
                null,
                UUID.fromString(apiKey),
                propagationProfile!!,
                object : BridgefyDelegate {
                    override fun onConnected(userID: UUID) {
                        invokeDelegate(
                            "bridgefyDidConnect",
                            hashMapOf("userId" to userID.toString()),
                        )
                    }

                    override fun onConnectedPeers(connectedPeers: List<UUID>) {
                        connectedPeers.forEach {
                            onConnected(it)
                        }
                    }

                    override fun onConnectedSecurely(userID: UUID) {
                        invokeDelegate(
                            "bridgefyDidEstablishSecureConnection",
                            hashMapOf("userId" to userID.toString()),
                        )
                    }

                    override fun onDisconnected(userID: UUID) {
                        invokeDelegate(
                            "bridgefyDidDisconnect",
                            hashMapOf("userId" to userID.toString()),
                        )
                    }

                    // TODO: iOS provides BridgefyError
                    override fun onFailToSend(messageID: UUID) {
                        invokeDelegate(
                            "bridgefyDidFailSendingMessage",
                            hashMapOf("messageId" to messageID.toString(), "error" to null),
                        )
                    }

                    override fun onFailToStart(error: BridgefyException) {
                        invokeDelegate(
                            "bridgefyDidFailToStart",
                            hashMapOf("error" to mapFromBridgefyException(error)),
                        )
                    }

                    override fun onFailToStop(error: BridgefyException) {
                        invokeDelegate(
                            "bridgefyDidFailToStop",
                            hashMapOf("error" to mapFromBridgefyException(error)),
                        )
                    }

                    override fun onProgressOfSend(messageID: UUID, position: Int, of: Int) {
                        invokeDelegate(
                            "bridgefyDidSendDataProgress",
                            hashMapOf("messageId" to messageID.toString(), "position" to position, "of" to of),
                        )
                    }

                    override fun onReceive(
                        data: ByteArray,
                        messageID: UUID,
                        transmissionMode: TransmissionMode,
                    ) {
                        invokeDelegate(
                            "bridgefyDidReceiveData",
                            hashMapOf(
                                "data" to data,
                                "messageId" to messageID.toString(),
                                "transmissionMode" to mapFromTransmissionMode(transmissionMode),
                            ),
                        )
                    }

                    override fun onSend(messageID: UUID) {
                        invokeDelegate(
                            "bridgefyDidSendMessage",
                            hashMapOf("messageId" to messageID.toString()),
                        )
                    }

                    override fun onStarted(userID: UUID) {
                        invokeDelegate(
                            "bridgefyDidStart",
                            hashMapOf("userId" to userID.toString()),
                        )
                    }

                    // TODO: bridgefyDidFailToEstablishSecureConnection
                    // TODO: bridgefyDidDestroySession
                    // TODO: bridgefyDidFailToDestroySession

                    override fun onStopped() {
                        invokeDelegate("bridgefyDidStop", null)
                    }
                },
            )
            result.success(null)
        } catch (error: BridgefyException) {
            val map = mapFromBridgefyException(error)
            result.error(map["code"] as String, map["message"] as String, map["details"])
        }
    }

    private fun start(@NonNull call: MethodCall, @NonNull result: Result) {
        bridgefy.start()
        result.success(null)
    }

    private fun send(@NonNull call: MethodCall, @NonNull result: Result) {
        val args = call.arguments as HashMap<String, Any>
        val data = args["data"] as ByteArray
        val transmissionModeDict = args["transmissionMode"] as HashMap<String, String>
        val transmissionMode = transmissionModeFromHashMap(transmissionModeDict)!!
        try {
            val uuid = bridgefy.send(data, transmissionMode)
            result.success(hashMapOf("messageId" to uuid.toString()))
        } catch (error: BridgefyException) {
            val map = mapFromBridgefyException(error)
            result.error(map["code"] as String, map["message"] as String, map["details"])
        }
    }

    private fun stop(@NonNull call: MethodCall, @NonNull result: Result) {
        bridgefy.stop()
        result.success(null)
    }

    private fun connectedPeers(@NonNull call: MethodCall, @NonNull result: Result) {
        result.success(arrayOf<String>())
        TODO("Android impl")
    }

    private fun currentUserID(@NonNull call: MethodCall, @NonNull result: Result) {
        val userId = bridgefy.currentBridgefyUser()
        result.success(hashMapOf("userId" to userId.toString()))
    }

    private fun establishSecureConnection(@NonNull call: MethodCall, @NonNull result: Result) {
        val args = call.arguments as HashMap<String, Any>
        val uuid = UUID.fromString(args["userId"] as String)
        bridgefy.establishSecureConnection(uuid)
        result.success(null)
    }

    private fun licenseExpirationDate(@NonNull call: MethodCall, @NonNull result: Result) {
        val date = bridgefy.licenseExpirationDate()
        result.success(hashMapOf("licenseExpirationDate" to date?.time))
    }

    private fun mapFromBridgefyException(exception: BridgefyException): HashMap<String, Any?> {
        var code: String
        var details: Int? = null
        var message: String? = null
        when (exception) {
            is BridgefyException.AlreadyStartedException -> {
                code = "alreadyStarted"
            }
            is BridgefyException.DeviceCapabilitiesException -> {
                code = "deviceCapabilities"
                message = exception.error
            }
            is BridgefyException.ExpiredLicenseException -> {
                code = "expiredLicense"
                message = exception.error
            }
            is BridgefyException.GenericException -> {
                code = "genericException"
                message = exception.message
                details = exception.code
            }
            is BridgefyException.InconsistentDeviceTimeException -> {
                code = "inconsistentDeviceTimeException"
                message = exception.error
            }
            is BridgefyException.InternetConnectionRequiredException -> {
                code = "internetConnectionRequiredException"
                message = exception.error
            }
            is BridgefyException.InvalidAPIKeyFormatException -> {
                code = "invalidAPIKey"
                message = exception.error
            }
            is BridgefyException.MissingApplicationIdException -> {
                code = "missingApplicationId"
                message = exception.error
            }
            is BridgefyException.PermissionException -> {
                code = "permissionException"
                message = exception.error
            }
            is BridgefyException.RegistrationException -> {
                code = "registrationException"
                message = exception.error
            }
            is BridgefyException.SessionErrorException -> {
                code = "sessionError"
                message = exception.error
            }
            is BridgefyException.SimulatorIsNotSupportedException -> {
                code = "simulatorIsNotSupported"
                message = exception.error.toString()
            }
            is BridgefyException.SizeLimitExceededException -> {
                code = "sizeLimitExceeded"
                message = exception.error
            }
            is BridgefyException.UnknownException -> {
                code = "unknownException"
                message = exception.error.toString()
            }
        }
        return hashMapOf("code" to code, "message" to message, "details" to details)
    }

    private fun propagationProfileFromString(str: String): PropagationProfile? {
        return when (str) {
            "highDensityNetwork" -> PropagationProfile.HighDensityEnvironment
            "sparseNetwork" -> PropagationProfile.SparseEnvironment
            "longReach" -> PropagationProfile.LongReach
            "shortReach" -> PropagationProfile.ShortReach
            "standard" -> PropagationProfile.Standard
            else -> null
        }
    }

    private fun mapFromTransmissionMode(mode: TransmissionMode): HashMap<String, String> {
        return when (mode) {
            is TransmissionMode.Broadcast -> hashMapOf(
                "mode" to "broadcast",
                "uuid" to mode.sender.toString(),
            )
            is TransmissionMode.Mesh -> hashMapOf(
                "mode" to "mesh",
                "uuid" to mode.receiver.toString(),
            )
            is TransmissionMode.P2P -> hashMapOf(
                "mode" to "p2p",
                "uuid" to mode.receiver.toString(),
            )
            else -> hashMapOf<String, String>()
        }
    }

    private fun transmissionModeFromHashMap(map: HashMap<String, String>): TransmissionMode? {
        val uuid = UUID.fromString(map["uuid"])
        return when (map["mode"]) {
            "p2p" -> TransmissionMode.P2P(uuid)
            "mesh" -> TransmissionMode.Mesh(uuid)
            "broadcast" -> TransmissionMode.Broadcast(uuid)
            else -> null
        }
    }

    private fun invokeDelegate(method: String, args: Any?) {
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod(method, args)
        }
    }
}
