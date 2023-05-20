package fr.skyost.fundingchoices

import android.app.Activity
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentDebugSettings.Builder
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

public class FlutterFundingChoicesPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    companion object {
        /// The method channel name.
        const val channelName: String = "flutter_funding_choices"
    }

    /// The MethodChannel that will the communication between Flutter and native Android.
    private lateinit var channel: MethodChannel

    /// The current activity.
    private var activity: Activity? = null

    /// The current consent information state.
    private var consentInformation: ConsentInformation? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestConsentInformation" -> requestConsentInformation(
                    call.argument<Boolean>("tagForUnderAgeOfConsent")!!,
                    call.argument<List<String>>("testDevicesHashedIds"),
                    call.argument<Int>("debugGeography"),
                    result)
            "showConsentForm" -> showConsentForm(result)
            "reset" -> {
                consentInformation?.reset()
                result.success(consentInformation != null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    /**
     * Requests the consent information.
     *
     * @param tagForUnderAgeOfConsent Whether to tag for under age of consent.
     * @param testDevicesHashedIds Provide test devices id in order to force geography to the EEA.
     * @param debugGeography orce geography to be in EEA or not EEA.
     * @param result Allows to send the result to the Dart side.
     */

    private fun requestConsentInformation(tagForUnderAgeOfConsent: Boolean, testDevicesHashedIds: List<String>?, debugGeography: Int?, result: MethodChannel.Result) {
        if (activity == null) {
            result.error("activity_is_null", "Activity is null.", null)
            return
        }

        var debugSettingsBuilder: Builder? = null
        if (testDevicesHashedIds != null) {
            debugSettingsBuilder = Builder(activity!!).setDebugGeography(debugGeography ?: ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_DISABLED)
            for (testDeviceHashedId in testDevicesHashedIds) {
                debugSettingsBuilder.addTestDeviceHashedId(testDeviceHashedId)
            }
        }

        val params = ConsentRequestParameters.Builder()
                .setTagForUnderAgeOfConsent(tagForUnderAgeOfConsent)
                .setConsentDebugSettings(debugSettingsBuilder?.build())
                .build()

        consentInformation = UserMessagingPlatform.getConsentInformation(activity!!)

        consentInformation!!.requestConsentInfoUpdate(
                activity!!,
                params,
                {
                    result.success(mapOf(
                            "consentStatus" to consentInformation!!.consentStatus,
                            "isConsentFormAvailable" to consentInformation!!.isConsentFormAvailable
                    ))
                },
                {
                    result.error(it.errorCode.toString(), it.message, null)
                }
        )
    }

    /**
     * Shows the consent form.
     *
     * @param result Allows to send the result to the Dart side.
     */

    private fun showConsentForm(result: MethodChannel.Result) {
        if (activity == null) {
            result.error("activity_is_null", "Activity is null.", null)
            return
        }

        UserMessagingPlatform.loadConsentForm(activity!!,
                { form ->
                    form.show(activity!!) { error ->
                        if (error == null) {
                            result.success(true)
                        } else {
                            result.error(error.errorCode.toString(), error.message, null)
                        }
                    }
                },
                {
                    result.error(it.errorCode.toString(), it.message, null)
                }
        )
    }
}
