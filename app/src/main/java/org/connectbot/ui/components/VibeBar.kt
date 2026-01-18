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

package org.connectbot.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Keyboard
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.KeyboardHide
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.connectbot.R
import org.connectbot.service.TerminalBridge
import org.connectbot.terminal.VTermKey

private const val UI_OPACITY = 1.0f

/**
 * VibeBar - A compact alternate keyboard panel optimized for vibe coding.
 * Contains: Esc, Tab, Enter, Up, Down, Ctrl+Alt+Up, Ctrl+Alt+Down, IME toggle
 */
@Composable
fun VibeBar(
    bridge: TerminalBridge,
    onInteraction: () -> Unit,
    modifier: Modifier = Modifier,
    onHideIme: () -> Unit = {},
    onShowIme: () -> Unit = {},
    imeVisible: Boolean = false
) {
    val keyHandler = bridge.keyHandler

    VibeBarContent(
        onEscPress = {
            keyHandler.sendEscape()
            onInteraction()
        },
        onTabPress = {
            keyHandler.sendTab()
            onInteraction()
        },
        onEnterPress = {
            keyHandler.sendEnter()
            onInteraction()
        },
        onUpPress = {
            keyHandler.sendPressedKey(VTermKey.UP)
            onInteraction()
        },
        onDownPress = {
            keyHandler.sendPressedKey(VTermKey.DOWN)
            onInteraction()
        },
        onCtrlUpPress = {
            keyHandler.sendKeyWithModifiers(VTermKey.UP, ctrl = true)
            onInteraction()
        },
        onCtrlDownPress = {
            keyHandler.sendKeyWithModifiers(VTermKey.DOWN, ctrl = true)
            onInteraction()
        },
        onInteraction = onInteraction,
        onHideIme = onHideIme,
        onShowIme = onShowIme,
        imeVisible = imeVisible,
        modifier = modifier
    )
}

/**
 * Stateless UI component for the VibeBar.
 * Separated from [VibeBar] to enable preview without TerminalBridge dependency.
 */
@Composable
private fun VibeBarContent(
    onEscPress: () -> Unit,
    onTabPress: () -> Unit,
    onEnterPress: () -> Unit,
    onUpPress: () -> Unit,
    onDownPress: () -> Unit,
    onCtrlUpPress: () -> Unit,
    onCtrlDownPress: () -> Unit,
    onInteraction: () -> Unit,
    onHideIme: () -> Unit,
    onShowIme: () -> Unit,
    imeVisible: Boolean,
    modifier: Modifier = Modifier
) {
    val borderColor = MaterialTheme.colorScheme.outline
    Surface(
        modifier = modifier
            .drawBehind {
                // Draw top border line
                drawLine(
                    color = borderColor,
                    start = Offset(0f, 0f),
                    end = Offset(size.width, 0f),
                    strokeWidth = 1.dp.toPx()
                )
            }
            .pointerInput(Unit) {
                // Reset timer on any touch interaction
                detectTapGestures(
                    onPress = {
                        onInteraction()
                        tryAwaitRelease()
                    }
                )
            },
        color = MaterialTheme.colorScheme.surface.copy(alpha = UI_OPACITY),
        tonalElevation = 8.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(TERMINAL_KEYBOARD_HEIGHT_DP.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            // Esc key
            VibeBarKeyButton(
                text = stringResource(R.string.button_key_esc),
                contentDescription = stringResource(R.string.image_description_send_escape_character),
                onClick = onEscPress
            )

            // Tab key
            VibeBarKeyButton(
                text = "⇥",
                contentDescription = stringResource(R.string.image_description_send_tab_character),
                onClick = onTabPress
            )

            // Enter key
            VibeBarKeyButton(
                text = "↵",
                contentDescription = "Send Enter",
                onClick = onEnterPress
            )

            // Up arrow (repeatable)
            VibeBarRepeatableKeyButton(
                icon = Icons.Default.KeyboardArrowUp,
                contentDescription = stringResource(R.string.image_description_up),
                onPress = onUpPress
            )

            // Down arrow (repeatable)
            VibeBarRepeatableKeyButton(
                icon = Icons.Default.KeyboardArrowDown,
                contentDescription = stringResource(R.string.image_description_down),
                onPress = onDownPress
            )

            // Ctrl+Up
            VibeBarKeyButton(
                text = "C+↑",
                contentDescription = "Send Ctrl+Up",
                onClick = onCtrlUpPress
            )

            // Ctrl+Down
            VibeBarKeyButton(
                text = "C+↓",
                contentDescription = "Send Ctrl+Down",
                onClick = onCtrlDownPress
            )

            // Keyboard toggle button
            Surface(
                onClick = {
                    if (imeVisible) {
                        onHideIme()
                    } else {
                        onShowIme()
                    }
                    onInteraction()
                },
                modifier = Modifier.size(
                    width = TERMINAL_KEYBOARD_WIDTH_DP.dp,
                    height = TERMINAL_KEYBOARD_HEIGHT_DP.dp
                ),
                shape = RectangleShape,
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline),
                color = MaterialTheme.colorScheme.surface.copy(alpha = UI_OPACITY)
            ) {
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.fillMaxSize()
                ) {
                    Icon(
                        if (imeVisible) Icons.Default.KeyboardHide else Icons.Default.Keyboard,
                        contentDescription = stringResource(
                            if (imeVisible)
                                R.string.image_description_hide_keyboard
                            else
                                R.string.image_description_show_keyboard
                        ),
                        modifier = Modifier.height(TERMINAL_KEYBOARD_CONTENT_SIZE_DP.dp)
                    )
                }
            }
        }
    }
}

/**
 * Width of the VibeBar keys in dp.
 */
private const val TERMINAL_KEYBOARD_WIDTH_DP = 45

/**
 * Size of the content (icons and text) for the VibeBar keys in dp.
 */
private const val TERMINAL_KEYBOARD_CONTENT_SIZE_DP = 20

/**
 * A button for single-press keys in VibeBar.
 */
@Composable
private fun VibeBarKeyButton(
    modifier: Modifier = Modifier,
    text: String? = null,
    icon: ImageVector? = null,
    contentDescription: String?,
    onClick: (() -> Unit)? = null,
    backgroundColor: Color = MaterialTheme.colorScheme.surface.copy(alpha = UI_OPACITY),
    tint: Color = MaterialTheme.colorScheme.onSurface
) {
    val surfaceModifier = modifier
        .size(width = TERMINAL_KEYBOARD_WIDTH_DP.dp, height = TERMINAL_KEYBOARD_HEIGHT_DP.dp)

    val content: @Composable () -> Unit = {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            if (text != null) {
                Text(
                    text = text,
                    style = MaterialTheme.typography.labelSmall,
                    color = tint
                )
            } else if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = contentDescription,
                    tint = tint,
                    modifier = Modifier.height(TERMINAL_KEYBOARD_CONTENT_SIZE_DP.dp),
                )
            }
        }
    }

    if (onClick != null) {
        Surface(
            onClick = onClick,
            modifier = surfaceModifier,
            shape = RectangleShape,
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline),
            color = backgroundColor,
            content = content
        )
    } else {
        Surface(
            modifier = surfaceModifier,
            shape = RectangleShape,
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline),
            color = backgroundColor,
            content = content
        )
    }
}

/**
 * A button for repeatable keys (arrow keys) in VibeBar.
 * Starts repeating after initial delay when held down.
 */
@Composable
private fun VibeBarRepeatableKeyButton(
    icon: ImageVector,
    contentDescription: String?,
    onPress: () -> Unit,
    modifier: Modifier = Modifier
) {
    val coroutineScope = rememberCoroutineScope()
    var isPressed by remember { mutableStateOf(false) }
    var repeatJob by remember { mutableStateOf<Job?>(null) }

    // Cleanup on unmount
    DisposableEffect(Unit) {
        onDispose {
            repeatJob?.cancel()
        }
    }

    val backgroundColor =
        if (isPressed) MaterialTheme.colorScheme.primaryContainer
        else MaterialTheme.colorScheme.surface

    VibeBarKeyButton(
        icon = icon,
        contentDescription = contentDescription,
        onClick = null,
        modifier = modifier.pointerInput(Unit) {
            detectTapGestures(
                onPress = {
                    isPressed = true
                    // Single press
                    onPress()

                    // Start repeat after initial delay
                    repeatJob = coroutineScope.launch {
                        delay(500) // Initial delay before repeat
                        while (isPressed) {
                            onPress()
                            delay(50) // Repeat interval
                        }
                    }

                    // Wait for release
                    tryAwaitRelease()
                    isPressed = false
                    repeatJob?.cancel()
                }
            )
        },
        backgroundColor = backgroundColor
    )
}

@Preview(name = "VibeBar - Default State", showBackground = true)
@Composable
private fun VibeBarPreview() {
    MaterialTheme {
        VibeBarContent(
            onEscPress = {},
            onTabPress = {},
            onEnterPress = {},
            onUpPress = {},
            onDownPress = {},
            onCtrlUpPress = {},
            onCtrlDownPress = {},
            onInteraction = {},
            onHideIme = {},
            onShowIme = {},
            imeVisible = false
        )
    }
}

@Preview(name = "VibeBar - IME Visible", showBackground = true)
@Composable
private fun VibeBarImeVisiblePreview() {
    MaterialTheme {
        VibeBarContent(
            onEscPress = {},
            onTabPress = {},
            onEnterPress = {},
            onUpPress = {},
            onDownPress = {},
            onCtrlUpPress = {},
            onCtrlDownPress = {},
            onInteraction = {},
            onHideIme = {},
            onShowIme = {},
            imeVisible = true
        )
    }
}
