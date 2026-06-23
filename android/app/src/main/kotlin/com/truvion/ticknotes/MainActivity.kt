package com.truvion.ticknotes

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode

class MainActivity : FlutterActivity() {
    // Use TextureView instead of SurfaceView (the default).
    // SurfaceView surface creation runs on the Android main thread and
    // can block for 5–10 seconds on certain GPU drivers (e.g., OPPO CPH2269),
    // causing the OS ANR watchdog to kill the process with SIGQUIT.
    // TextureView creates the GPU surface off the main thread, avoiding the hang.
    override fun getRenderMode(): RenderMode = RenderMode.texture
}
