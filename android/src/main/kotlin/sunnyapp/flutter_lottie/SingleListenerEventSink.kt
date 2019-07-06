package sunnyapp.flutter_lottie

import io.flutter.plugin.common.EventChannel

/**
 * A [StreamHandler] that expects only a single listener, and plays back any events that
 * occur between the time this instance is created and the time the first subscription is
 * made
 */
class SingleListenerEventSink : EventChannel.StreamHandler, EventChannel.EventSink {
    private val existing: MutableList<Any?> = mutableListOf()
    private var sink: EventChannel.EventSink? = null

    override fun success(data: Any?) =
            when (val sink = this.sink) {
                null -> existing += data
                else -> sink.success(data)
            }

    override fun error(s: String?, s1: String?, o: Any?) {
        sink?.error(s, s1, o)
    }

    override fun endOfStream() {
        sink?.endOfStream()
    }

    override fun onListen(data: Any?, eventSink: EventChannel.EventSink) {
        this.sink = eventSink
        for (value in existing) {
            success(value)
        }
        existing.clear()
    }

    override fun onCancel(o: Any?) {
    }
}
