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

package org.connectbot.ui.theme

import androidx.compose.ui.graphics.Color

// Teal/Mint theme for VibeTTY
val md_theme_light_primary = Color(0xFF00897B)           // Teal 600
val md_theme_light_onPrimary = Color(0xFFFFFFFF)
val md_theme_light_primaryContainer = Color(0xFFA7FFEB)  // Teal accent 100
val md_theme_light_onPrimaryContainer = Color(0xFF002018)
val md_theme_light_secondary = Color(0xFF26A69A)         // Teal 400
val md_theme_light_onSecondary = Color(0xFFFFFFFF)
val md_theme_light_secondaryContainer = Color(0xFFB2DFDB) // Teal 100
val md_theme_light_onSecondaryContainer = Color(0xFF002018)
val md_theme_light_tertiary = Color(0xFF1DE9B6)          // Teal accent 400
val md_theme_light_onTertiary = Color(0xFF003829)
val md_theme_light_error = Color(0xFFBA1A1A)
val md_theme_light_errorContainer = Color(0xFFFFDAD6)
val md_theme_light_onError = Color(0xFFFFFFFF)
val md_theme_light_onErrorContainer = Color(0xFF410002)
val md_theme_light_background = Color(0xFFFAFDFB)        // Slight teal tint
val md_theme_light_onBackground = Color(0xFF191C1B)
val md_theme_light_surface = Color(0xFFFAFDFB)
val md_theme_light_onSurface = Color(0xFF191C1B)
val md_theme_light_surfaceVariant = Color(0xFFDAE5E1)    // Teal-tinted gray
val md_theme_light_onSurfaceVariant = Color(0xFF3F4946)
val md_theme_light_outline = Color(0xFF6F7976)
val md_theme_light_inverseOnSurface = Color(0xFFEFF1EF)
val md_theme_light_inverseSurface = Color(0xFF2D3130)
val md_theme_light_inversePrimary = Color(0xFF64FFDA)    // Teal accent 200

val md_theme_dark_primary = Color(0xFF64FFDA)            // Teal accent 200
val md_theme_dark_onPrimary = Color(0xFF00382B)
val md_theme_dark_primaryContainer = Color(0xFF00695C)   // Teal 700
val md_theme_dark_onPrimaryContainer = Color(0xFFA7FFEB)
val md_theme_dark_secondary = Color(0xFF80CBC4)          // Teal 200
val md_theme_dark_onSecondary = Color(0xFF003730)
val md_theme_dark_secondaryContainer = Color(0xFF004D44)
val md_theme_dark_onSecondaryContainer = Color(0xFFB2DFDB)
val md_theme_dark_tertiary = Color(0xFF1DE9B6)           // Teal accent 400
val md_theme_dark_onTertiary = Color(0xFF003829)
val md_theme_dark_error = Color(0xFFFFB4AB)
val md_theme_dark_errorContainer = Color(0xFF93000A)
val md_theme_dark_onError = Color(0xFF690005)
val md_theme_dark_onErrorContainer = Color(0xFFFFDAD6)
val md_theme_dark_background = Color(0xFF191C1B)         // Dark with teal undertone
val md_theme_dark_onBackground = Color(0xFFE1E3E1)
val md_theme_dark_surface = Color(0xFF191C1B)
val md_theme_dark_onSurface = Color(0xFFE1E3E1)
val md_theme_dark_surfaceVariant = Color(0xFF3F4946)
val md_theme_dark_onSurfaceVariant = Color(0xFFBEC9C5)
val md_theme_dark_outline = Color(0xFF89938F)
val md_theme_dark_inverseOnSurface = Color(0xFF191C1B)
val md_theme_dark_inverseSurface = Color(0xFFE1E3E1)
val md_theme_dark_inversePrimary = Color(0xFF00897B)

val KeyBackgroundNormal = Color(0x55F0F0F0)
val KeyBackgroundPressed = Color(0xAAA0A0FF)
val KeyBackgroundLayout = Color(0x55000000)
val KeyboardBackground = Color(0x55B0B0F0)

// Terminal-specific colors (used for overlays over terminal)
// These are independent of light/dark theme since terminal background is always dark
val TerminalOverlayBackground = Color(0x80000000) // Semi-transparent black
val TerminalOverlayText = Color(0xFFFFFFFF) // White
val TerminalOverlayTextSecondary = Color(0xB3FFFFFF) // White at 70% opacity
