package fr.skyost.fundingchoices

import android.app.Activity
import androidx.annotation.NonNull
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

public class FlutterFundingChoicesPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
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

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "requestConsentInformation" -> requestConsentInformation(call.argument<Boolean>("tagForUnderAgeOfConsent")!!, result)
            "showConsentForm" -> showConsentForm(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
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
     * Request the consent information.
     *
     * @param tagForUnderAgeOfConsent Whether to tag for under age of consent.
     * @param result Allows to send the result to the Dart side.
     */

    private fun requestConsentInformation(tagForUnderAgeOfConsent: Boolean, result: Result) {
        if (activity == null) {
            result.error("activity_is_null", "Activity is null.", null)
            return
        }

        val params = ConsentRequestParameters.Builder()
                .setTagForUnderAgeOfConsent(tagForUnderAgeOfConsent)
                .build()
        consentInformation = UserMessagingPlatform.getConsentInformation(activity)

        consentInformation!!.requestConsentInfoUpdate(
                activity,
                params,
                {
                    result.success(mapOf(
                            "consentStatus" to consentInformation!!.consentStatus,
                            "consentType" to consentInformation!!.consentType,
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

    private fun showConsentForm(result: Result) {
        if (activity == null) {
            result.error("activity_is_null", "Activity is null.", null)
            return
        }

        UserMessagingPlatform.loadConsentForm(activity,
                { form ->
                    form.show(activity) { error ->
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
