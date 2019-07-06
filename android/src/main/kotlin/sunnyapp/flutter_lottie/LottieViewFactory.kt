@file:Suppress("UNCHECKED_CAST")

package sunnyapp.flutter_lottie

import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import android.content.Context

class LottieViewFactory(private val mPluginRegistrar: Registrar) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView =
            LottieView(context, id, args, mPluginRegistrar)
}
