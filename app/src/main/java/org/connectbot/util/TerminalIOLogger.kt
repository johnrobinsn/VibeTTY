/*
 * ConnectBot: simple, powerful, open-source SSH client for Android
 * Copyright 2025 Kenny Root
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.connectbot.util

import android.util.Log

/**
 * Debug logging utility for terminal I/O.
 * Disabled by default. Can be enabled via:
 *   adb shell setprop debug.vibetty.terminal_io true
 *
 * When enabled, logs all terminal input/output to logcat with tag "TerminalIO".
 * This is useful for debugging keyboard protocol issues and automated testing.
 *
 * Usage in tests:
 *   adb shell setprop debug.vibetty.terminal_io true
 *   adb logcat -s TerminalIO:V
 */
object TerminalIOLogger {
    private const val TAG = "TerminalIO"
    private const val PROP_NAME = "debug.vibetty.terminal_io"

    // Cache the enabled state (check on first use)
    private var enabledChecked = false
    private var enabled = false

    /**
     * Check if terminal I/O logging is enabled.
     * Caches the result after first check.
     */
    @JvmStatic
    fun isEnabled(): Boolean {
        if (!enabledChecked) {
            enabled = try {
                // Check system property
                val value = System.getProperty(PROP_NAME)
                    ?: getSystemProperty(PROP_NAME)
                value?.equals("true", ignoreCase = true) == true
            } catch (e: Exception) {
                false
            }
            enabledChecked = true
            if (enabled) {
                Log.i(TAG, "Terminal I/O logging ENABLED")
            }
        }
        return enabled
    }

    /**
     * Force enable/disable logging (useful for tests).
     */
    @JvmStatic
    fun setEnabled(enable: Boolean) {
        enabled = enable
        enabledChecked = true
        Log.i(TAG, "Terminal I/O logging ${if (enable) "ENABLED" else "DISABLED"}")
    }

    /**
     * Reset the enabled check (useful if property changed at runtime).
     */
    @JvmStatic
    fun resetEnabledCheck() {
        enabledChecked = false
    }

    /**
     * Log data received from the remote host (incoming).
     */
    @JvmStatic
    fun logReceived(data: ByteArray, offset: Int, length: Int) {
        if (!isEnabled()) return

        val subset = data.copyOfRange(offset, offset + length)
        val hex = subset.joinToString(" ") { "%02x".format(it) }
        val printable = subset.map { b ->
            val c = b.toInt().toChar()
            when {
                c == '\u001b' -> "ESC"
                c.isISOControl() -> "^${(c.code + 64).toChar()}"
                else -> c.toString()
            }
        }.joinToString("")

        Log.v(TAG, "RECV [$length bytes]: $hex")
        Log.v(TAG, "RECV readable: $printable")
    }

    /**
     * Log data sent to the remote host (outgoing keyboard input).
     */
    @JvmStatic
    fun logSent(data: ByteArray) {
        if (!isEnabled()) return

        val hex = data.joinToString(" ") { "%02x".format(it) }
        val printable = data.map { b ->
            val c = b.toInt().toChar()
            when {
                c == '\u001b' -> "ESC"
                c.isISOControl() -> "^${(c.code + 64).toChar()}"
                else -> c.toString()
            }
        }.joinToString("")

        Log.v(TAG, "SEND [${data.size} bytes]: $hex")
        Log.v(TAG, "SEND readable: $printable")
    }

    /**
     * Log a single character sent.
     */
    @JvmStatic
    fun logSent(c: Int) {
        if (!isEnabled()) return

        val char = c.toChar()
        val readable = when {
            char == '\u001b' -> "ESC"
            char.isISOControl() -> "^${(c + 64).toChar()}"
            else -> char.toString()
        }

        Log.v(TAG, "SEND [1 byte]: %02x".format(c))
        Log.v(TAG, "SEND readable: $readable")
    }

    /**
     * Log a key event.
     */
    @JvmStatic
    fun logKeyEvent(keyCode: Int, modifiers: Int, description: String) {
        if (!isEnabled()) return
        Log.d(TAG, "KEY: $description (keyCode=$keyCode, modifiers=$modifiers)")
    }

    /**
     * Get system property using reflection (works on Android).
     */
    private fun getSystemProperty(name: String): String? {
        return try {
            val clazz = Class.forName("android.os.SystemProperties")
            val method = clazz.getMethod("get", String::class.java)
            method.invoke(null, name) as? String
        } catch (e: Exception) {
            null
        }
    }
}
