package sunnyapp.flutter_lottie

import sunnyapp.flutter_lottie.LottieView.Companion.lottiePluginBase
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterLottiePlugin {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            registrar.platformViewRegistry().registerViewFactory(
                    lottiePluginBase,
                    LottieViewFactory(registrar)
            )
        }
    }

}

