package com.gaaftbll.game

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity - bagian native Kotlin dari GAAFTBLL.
 * Menyediakan MethodChannel "gaaftbll/native" agar sisi Dart (Flutter)
 * bisa memicu efek getar (haptic feedback) native Android saat:
 * - gol dicetak
 * - tekel berhasil / gagal
 * - kartu diberikan
 *
 * Ini adalah contoh integrasi Flutter + Kotlin ("campuran") yang bisa
 * dikembangkan lebih lanjut (misal: leaderboard lokal, notifikasi, IAP, dll).
 */
class MainActivity : FlutterActivity() {

    private val CHANNEL = "gaaftbll/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val type = call.argument<String>("type") ?: "default"
                    vibrateForEvent(type)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun vibrateForEvent(type: String) {
        val durationMs: Long = when (type) {
            "shoot" -> 40L
            "pass" -> 15L
            "tackle_success" -> 60L
            "tackle_fail" -> 25L
            "goal" -> 200L
            "card" -> 120L
            else -> 30L
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            val vibrator = vibratorManager.defaultVibrator
            vibrator.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(durationMs)
            }
        }
    }
}
