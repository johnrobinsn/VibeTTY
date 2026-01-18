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

package org.connectbot.ui.screens.portforwardlist

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import org.connectbot.R
import org.connectbot.service.ConnectivityMonitor
import org.connectbot.util.AdbPortScanner

/**
 * Data class for pre-filled port forward values.
 */
data class AdbPortForwardParams(
    val nickname: String,
    val type: String,
    val sourcePort: String,
    val destination: String
)

/**
 * Dialog that scans for and displays the wireless ADB debugging port.
 */
@Composable
fun AdbDiscoveryDialog(
    connectivityMonitor: ConnectivityMonitor?,
    onDismiss: () -> Unit,
    onCreatePortForward: ((AdbPortForwardParams) -> Unit)? = null
) {
    var isScanning by remember { mutableStateOf(true) }
    var discoveredPort by remember { mutableStateOf<Int?>(null) }
    var wifiIp by remember { mutableStateOf<String?>(null) }
    val context = LocalContext.current

    LaunchedEffect(Unit) {
        wifiIp = connectivityMonitor?.getWifiIpAddress()
        discoveredPort = AdbPortScanner.findAdbPort()
        isScanning = false
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(stringResource(R.string.adb_discovery_title)) },
        text = {
            SelectionContainer {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    if (isScanning) {
                    CircularProgressIndicator(modifier = Modifier.size(48.dp))
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(stringResource(R.string.adb_discovery_scanning))
                } else if (discoveredPort != null) {
                    // Success - show port and IP
                    Text(
                        text = stringResource(R.string.adb_discovery_port, discoveredPort!!),
                        style = MaterialTheme.typography.titleMedium
                    )
                    Spacer(modifier = Modifier.height(8.dp))

                    if (wifiIp != null) {
                        Text(
                            text = stringResource(R.string.adb_discovery_ip, wifiIp!!),
                            style = MaterialTheme.typography.titleMedium
                        )
                        Spacer(modifier = Modifier.height(16.dp))

                        // Show copyable command
                        val command = "adb connect $wifiIp:$discoveredPort"
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                text = command,
                                style = MaterialTheme.typography.bodyMedium,
                                fontFamily = FontFamily.Monospace
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            IconButton(
                                onClick = {
                                    copyToClipboard(context, command)
                                }
                            ) {
                                Icon(
                                    Icons.Default.ContentCopy,
                                    contentDescription = stringResource(R.string.adb_discovery_copy)
                                )
                            }
                        }
                    } else {
                        Text(
                            text = stringResource(R.string.adb_discovery_no_wifi),
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.error
                        )
                    }
                } else {
                    // Not found
                    Text(
                        text = stringResource(R.string.adb_discovery_not_found),
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(vertical = 16.dp)
                    )
                }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text(stringResource(android.R.string.ok))
            }
        },
        dismissButton = {
            if (discoveredPort != null && onCreatePortForward != null) {
                TextButton(
                    onClick = {
                        onCreatePortForward(
                            AdbPortForwardParams(
                                nickname = "adb",
                                type = "remote",
                                sourcePort = "5550",
                                destination = "localhost:$discoveredPort"
                            )
                        )
                        onDismiss()
                    }
                ) {
                    Text(stringResource(R.string.adb_discovery_create_mapping))
                }
            }
        }
    )
}

private fun copyToClipboard(context: Context, text: String) {
    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    val clip = ClipData.newPlainText("ADB Command", text)
    clipboard.setPrimaryClip(clip)
    Toast.makeText(context, R.string.adb_discovery_copied, Toast.LENGTH_SHORT).show()
}
