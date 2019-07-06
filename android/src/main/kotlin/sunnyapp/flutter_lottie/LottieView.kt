@file:Suppress("UNCHECKED_CAST")

package sunnyapp.flutter_lottie

import android.animation.Animator
import android.content.Context
import android.graphics.Color
import android.view.View
import com.airbnb.lottie.LottieAnimationView
import com.airbnb.lottie.LottieDrawable
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.model.KeyPath
import com.airbnb.lottie.value.LottieValueCallback
import sunnyapp.flutter_lottie.LottieValueType.*

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformView

class LottieView(mContext: Context,
                 mId: Int,
                 rawArgs: Any?,
                 mRegistrar: Registrar) : PlatformView, MethodChannel.MethodCallHandler {

    private val animationView: LottieAnimationView = LottieAnimationView(mContext)
    private var maxFrame: Float = 0.toFloat()

    private val onPlaybackFinishEvent = SingleListenerEventSink()
    private val onInitializedEvent = SingleListenerEventSink()

    private val channel: MethodChannel = MethodChannel(mRegistrar.messenger(), "${lottiePluginBase}_$mId")
    init {
        channel.setMethodCallHandler(this)

        val onPlaybackCompleteEventChannel = EventChannel(mRegistrar.messenger(), "${lottiePluginBase}_stream_playfinish_$mId")
        val onInitializedEventChannel = EventChannel(mRegistrar.messenger(), "${lottiePluginBase}_stream_initialized_$mId")

        onPlaybackCompleteEventChannel.setStreamHandler(onPlaybackFinishEvent)
        onInitializedEventChannel.setStreamHandler(onInitializedEvent)

        val args = rawArgs as? Map<String, Any> ?: mapOf()

        val url: Any? by args
        val filePath: Any? by args

        when {
            url != null -> animationView.setAnimationFromUrl("$url")
            filePath != null -> {
                val key = mRegistrar.lookupKeyForAsset("$filePath")
                animationView.setAnimation(key)
            }
        }

        onInitializedEvent.success(true)

        val loop = args["loop"].toBool()
        val reverse = args["reverse"].toBool()
        val autoPlay = args["autoPlay"].toBool()

        animationView.repeatCount = if (loop) -1 else 0
        maxFrame = animationView.maxFrame

        if (reverse) {
            animationView.repeatMode = LottieDrawable.REVERSE
        } else {
            animationView.repeatMode = LottieDrawable.RESTART
        }

        if (autoPlay) {
            animationView.playAnimation()
        }


        animationView.addAnimatorListener(object : Animator.AnimatorListener {
            override fun onAnimationStart(animation: Animator) {}
            override fun onAnimationEnd(animation: Animator) {
                onPlaybackFinishEvent.success(true)
            }

            override fun onAnimationCancel(animation: Animator) {
                onPlaybackFinishEvent.success(false)
            }

            override fun onAnimationRepeat(animation: Animator) {}
        })

    }

    override fun getView(): View = animationView

    override fun dispose() {
        animationView.cancelAnimation()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<String, Any> ?: mapOf()
        when (call.method) {
            "play" -> {
                animationView.setMinAndMaxFrame(0, maxFrame.toInt())
                animationView.setMinAndMaxProgress(0f, 1f)
                animationView.playAnimation()
            }
            "resume" -> animationView.resumeAnimation()
            "playWithProgress" -> {
                args.withValue("fromProgress") { value: Number ->
                    animationView.setMinProgress(value.toFloat())
                }

                args.withValue("toProgress") { value: Number ->
                    animationView.setMaxProgress(value.toFloat())
                }
                animationView.playAnimation()
            }

            "playWithFrames" -> {
                args.withValue("fromFrame") { value: Number ->
                    animationView.setMinFrame(value.toInt())
                }
                args.withValue("toFrame") { value: Number ->
                    animationView.setMaxFrame(value.toInt())
                }

                animationView.playAnimation()
            }
            "stop" -> {
                animationView.cancelAnimation()
                animationView.progress = 0.0f
                val mode = animationView.repeatMode
                animationView.repeatMode = LottieDrawable.RESTART
                animationView.repeatMode = mode
            }
            "pause" -> animationView.pauseAnimation()
            "setAnimationSpeed" -> args.withValue("speed") { value: Number ->
                animationView.speed = value.toFloat()
            }
            "setLoopAnimation" -> {
                val loop = args["loop"].toBool()
                animationView.repeatCount = if (loop) -1 else 0
            }
            "setAutoReverseAnimation" -> {
                val reverse = args["reverse"].toBool()
                animationView.repeatCount = when (reverse) {
                    true -> 2
                    false -> 1
                }
            }
            "setAnimationProgress" -> {
                animationView.pauseAnimation() // TODO Make sure its consistant with iOS
                animationView.progress = args["progress"].toNumber().toFloat()
            }
            "setProgressWithFrame" -> animationView.frame = args["progress"].toNumber().toInt()
            "isAnimationPlaying" -> result.success(animationView.isAnimating)
            "getAnimationDuration" -> result.success(animationView.duration.toDouble())
            "getAnimationProgress" -> result.success(animationView.progress.toDouble())
            "getAnimationSpeed" -> result.success(animationView.speed.toDouble())
            "getLoopAnimation" -> result.success(animationView.repeatCount == -1)
            "getAutoReverseAnimation" -> result.success(animationView.repeatMode == 2)
            "setValue" -> {
                val value by args
                val keyPath by args
                val type by args

                setValue(type.toLottieValueType(), "$value", "$keyPath")
            }
            else -> result.notImplemented()
        }
    }

    private fun setValue(type: LottieValueType?, value: String, keyPath: String) {
        val valueType = type ?: return
        val keyPaths = keyPath.split('.').dropLastWhile { it.isEmpty() }.toTypedArray()
        when (valueType) {
            LOTColorValue, ColorValue -> animationView.addValueCallback(
                    KeyPath(*keyPaths),
                    LottieProperty.COLOR,
                    LottieValueCallback(value.toColor())
            )
            LOTOpacityValue, OpacityValue -> {
                val v = java.lang.Float.parseFloat(value) * 100
                animationView.addValueCallback(
                        KeyPath(*keyPaths),
                        LottieProperty.OPACITY,
                        LottieValueCallback(Math.round(v))
                )
            }
        }
    }


    companion object {
        const val lottiePluginBase = "sunnyapp/flutter_lottie"
    }
}

enum class LottieValueType {
    LOTColorValue, LOTOpacityValue, ColorValue, OpacityValue;
}

private fun String.toColor(): Int {
    val value = this
    val red = value.substring(4, 6).toInt(16)
    val green = value.substring (6, 8).toInt(16)
    val blue = value.substring(8, 10).toInt(16)
    return Color.argb(255, red, green, blue)
}

private fun Any?.toLottieValueType(): LottieValueType? =
        values().firstOrNull { it.name == this?.toString() }

private fun Any?.toBool(): Boolean {
    return this?.toString()?.toBoolean() ?: false
}

private fun Any?.toNumber(): Number {
    return this?.toString()?.toDouble() ?: 0.0
}

private fun <T : Any> Map<String, Any>.withValue(name: String, block: (T) -> Unit) {
    val value = this[name] as T?
    if (value != null) {
        block(value)
    }
}