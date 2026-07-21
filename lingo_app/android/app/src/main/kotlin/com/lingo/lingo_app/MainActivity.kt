package com.lingo.lingo_app

import android.content.res.AssetManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    companion object {
        private const val TTS_MODEL_CHANNEL = "lingo/tts_model_assets"
        private const val FLUTTER_ASSET_ROOT = "flutter_assets/"
        private const val TTS_ASSET_PREFIX = "assets/tts_model/"
        private const val BUFFER_SIZE = 64 * 1024
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TTS_MODEL_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "copyAssetToFile") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val assetPath = call.argument<String>("assetPath")
                val destinationPath = call.argument<String>("destinationPath")
                if (assetPath == null || destinationPath == null ||
                    !assetPath.startsWith(TTS_ASSET_PREFIX)) {
                    result.error("invalid_arguments", "Invalid model asset request.", null)
                    return@setMethodCallHandler
                }

                thread {
                    try {
                        copyAssetToFile(assetPath, destinationPath)
                        runOnUiThread { result.success(null) }
                    } catch (error: Exception) {
                        runOnUiThread {
                            result.error("asset_copy_failed", error.message, null)
                        }
                    }
                }
            }
    }

    private fun copyAssetToFile(assetPath: String, destinationPath: String) {
        val target = File(destinationPath)
        target.parentFile?.mkdirs()
        val temporary = File("${target.path}.part")
        if (temporary.exists()) temporary.delete()

        assets.open(FLUTTER_ASSET_ROOT + assetPath, AssetManager.ACCESS_STREAMING)
            .use { input ->
                temporary.outputStream().buffered(BUFFER_SIZE).use { output ->
                    input.copyTo(output, BUFFER_SIZE)
                }
            }

        if (target.exists()) target.delete()
        if (!temporary.renameTo(target)) {
            temporary.delete()
            throw IllegalStateException("Could not finalize local model file.")
        }
    }
}
