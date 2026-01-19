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
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Callable
import java.util.concurrent.Executors

/**
 * Scans localhost ports to discover the Android wireless debugging (ADB) port.
 *
 * Android 11+ wireless debugging uses dynamic ports in the 37000-44000 range.
 * This scanner verifies ADB by performing a protocol handshake, filtering out
 * other services that might be listening on ports in the range.
 *
 * See: https://android.googlesource.com/platform/packages/modules/adb/+/refs/heads/main/docs/dev/protocol.md
 */
object AdbPortScanner {
    private const val THREAD_COUNT = 50
    private const val CONNECT_TIMEOUT_MS = 100
    private const val READ_TIMEOUT_MS = 500

    // Android wireless debugging uses dynamic ports in the range 30000-49999
    // See: https://xdaforums.com/t/adb-wifi-how-to-specify-port-and-have-it-fix.4321669/
    private val PORT_RANGE = 30000..49999

    // ADB protocol commands (little-endian)
    private const val A_CNXN = 0x4e584e43  // "CNXN"
    private const val A_AUTH = 0x48545541  // "AUTH"
    private const val A_STLS = 0x534c5453  // "STLS" - Start TLS (wireless debugging)

    // ADB protocol version and max payload
    private const val ADB_VERSION = 0x01000000
    private const val MAX_PAYLOAD = 256 * 1024

    /**
     * Scans localhost for the ADB port.
     *
     * @param verifyProtocol If true (default), verifies each port using ADB protocol
     *                       handshake. If false, just checks if port is open.
     * @return The discovered ADB port, or null if not found
     */
    suspend fun findAdbPort(verifyProtocol: Boolean = true): Int? = withContext(Dispatchers.IO) {
        scanForAdbPort(verifyProtocol)
    }

    /**
     * Performs a full port scan to find ADB.
     *
     * Uses ADB protocol handshake to verify each port is actually ADB,
     * not just any open port. Returns the highest ADB port found.
     */
    private fun scanForAdbPort(verifyProtocol: Boolean): Int? {
        val executor = Executors.newFixedThreadPool(THREAD_COUNT)
        try {
            val futures = PORT_RANGE.map { port ->
                executor.submit(
                    Callable {
                        val isValid = if (verifyProtocol) isAdbPort(port) else isPortOpen(port)
                        if (isValid) port else null
                    }
                )
            }
            // Collect all ADB ports and return the highest one
            val adbPorts = futures.mapNotNull { it.get() }
            return adbPorts.maxOrNull()
        } finally {
            executor.shutdown()
        }
    }

    /**
     * Simple check if a port is open (without protocol verification).
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

    /**
     * Verifies a port is actually ADB by performing a protocol handshake.
     *
     * Sends an ADB CNXN packet and checks if the response is a valid
     * ADB message (CNXN or AUTH).
     */
    private fun isAdbPort(port: Int): Boolean {
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", port), CONNECT_TIMEOUT_MS)
                socket.soTimeout = READ_TIMEOUT_MS

                val output = socket.getOutputStream()
                val input = socket.getInputStream()

                // Send ADB CNXN packet
                val connectPacket = buildAdbConnectPacket()
                output.write(connectPacket)
                output.flush()

                // Read response header (24 bytes)
                // Must loop since read() may return fewer bytes than requested
                val header = ByteArray(24)
                var totalRead = 0
                while (totalRead < 24) {
                    val bytesRead = input.read(header, totalRead, 24 - totalRead)
                    if (bytesRead == -1) break
                    totalRead += bytesRead
                }

                if (totalRead >= 24) {
                    val buffer = ByteBuffer.wrap(header).order(ByteOrder.LITTLE_ENDIAN)
                    val cmd = buffer.getInt(0)
                    val magic = buffer.getInt(20)

                    // Validate both the command and the magic field
                    // Magic must equal command XOR 0xFFFFFFFF
                    val isValidCommand = cmd == A_CNXN || cmd == A_AUTH || cmd == A_STLS
                    val isValidMagic = magic == (cmd xor 0xFFFFFFFF.toInt())

                    isValidCommand && isValidMagic
                } else {
                    false
                }
            }
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Builds an ADB CNXN (connect) packet.
     *
     * Packet format (24-byte header + payload):
     * - command (4 bytes): A_CNXN
     * - arg0 (4 bytes): protocol version
     * - arg1 (4 bytes): max payload size
     * - data_length (4 bytes): payload length
     * - data_crc32 (4 bytes): checksum of payload
     * - magic (4 bytes): command XOR 0xFFFFFFFF
     * - payload: system identity string
     */
    private fun buildAdbConnectPacket(): ByteArray {
        val payload = "host::\u0000".toByteArray(Charsets.UTF_8)
        val checksum = payload.sumOf { (it.toInt() and 0xFF) }

        return ByteBuffer.allocate(24 + payload.size)
            .order(ByteOrder.LITTLE_ENDIAN)
            .putInt(A_CNXN)
            .putInt(ADB_VERSION)
            .putInt(MAX_PAYLOAD)
            .putInt(payload.size)
            .putInt(checksum)
            .putInt(A_CNXN xor 0xFFFFFFFF.toInt())
            .put(payload)
            .array()
    }
}
