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

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.InetSocketAddress
import java.net.Socket
import java.util.concurrent.Callable
import java.util.concurrent.Executors

/**
 * Scans localhost ports to discover the Android wireless debugging (ADB) port.
 *
 * Android 11+ wireless debugging uses dynamic ports in the 37000-44000 range.
 * This scanner checks which port is open on localhost to find the ADB service.
 */
object AdbPortScanner {
    private const val THREAD_COUNT = 50
    private const val CONNECT_TIMEOUT_MS = 100

    // Android wireless debugging uses dynamic ports, typically 30000-44000
    private val PORT_RANGE = 30000..44000

    /**
     * Scans localhost for the ADB port.
     *
     * @return The discovered ADB port, or null if not found
     */
    suspend fun findAdbPort(): Int? = withContext(Dispatchers.IO) {
        val executor = Executors.newFixedThreadPool(THREAD_COUNT)
        try {
            val futures = PORT_RANGE.map { port ->
                executor.submit(
                    Callable {
                        if (isPortOpen(port)) port else null
                    }
                )
            }
            // Return the first open port found
            futures.forEach { future ->
                val result = future.get()
                if (result != null) {
                    return@withContext result
                }
            }
            null
        } finally {
            executor.shutdown()
        }
    }

    /**
     * Checks if a port is open on localhost.
     */
    private fun isPortOpen(port: Int): Boolean {
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", port), CONNECT_TIMEOUT_MS)
                true
            }
        } catch (e: Exception) {
            false
        }
    }
}
