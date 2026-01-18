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

package org.connectbot.ui.screens.settings

import android.graphics.Typeface
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.connectbot.R
import org.connectbot.ui.ScreenPreviews
import org.connectbot.ui.theme.ConnectBotTheme
import org.connectbot.util.TerminalTypefaceResult
import org.connectbot.util.rememberTerminalTypefaceResultFromStoredValue

/**
 * Data class representing a font entry for display in the picker.
 */
data class FontEntry(
    val displayName: String,
    val storedValue: String
)

/**
 * Default sample code shown in the font preview area.
 */
private val DEFAULT_SAMPLE_CODE = """
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
""".trimIndent()

/**
 * Dialog for selecting a terminal font with live preview.
 *
 * @param currentFontValue The currently selected font's stored value
 * @param fontEntries List of available fonts to choose from
 * @param onFontSelected Callback when a font is selected and confirmed
 * @param onDismiss Callback when the dialog is dismissed
 */
@Composable
fun FontPickerDialog(
    currentFontValue: String,
    fontEntries: List<FontEntry>,
    onFontSelected: (String) -> Unit,
    onDismiss: () -> Unit
) {
    var selectedValue by remember { mutableStateOf(currentFontValue) }
    var sampleText by remember { mutableStateOf(DEFAULT_SAMPLE_CODE) }

    // Load typeface for sample text preview
    val selectedTypefaceResult = rememberTerminalTypefaceResultFromStoredValue(selectedValue)

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(stringResource(R.string.pref_fontfamily_title)) },
        text = {
            Column(
                modifier = Modifier.fillMaxWidth()
            ) {
                // Font list (scrollable)
                LazyColumn(
                    modifier = Modifier
                        .fillMaxWidth()
                        .heightIn(max = 250.dp)
                ) {
                    items(fontEntries) { entry ->
                        FontListItem(
                            fontEntry = entry,
                            isSelected = entry.storedValue == selectedValue,
                            onSelect = { selectedValue = entry.storedValue }
                        )
                    }
                }

                HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp))

                // Sample text label
                Text(
                    text = stringResource(R.string.font_sample_text_label),
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(bottom = 8.dp)
                )

                // Sample text area
                OutlinedTextField(
                    value = sampleText,
                    onValueChange = { sampleText = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(150.dp),
                    textStyle = TextStyle(
                        fontFamily = selectedTypefaceResult.typeface.toFontFamily(),
                        fontSize = 12.sp
                    ),
                    shape = RoundedCornerShape(8.dp)
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    onFontSelected(selectedValue)
                    onDismiss()
                }
            ) {
                Text(stringResource(android.R.string.ok))
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text(stringResource(android.R.string.cancel))
            }
        }
    )
}

/**
 * A single font item in the font list.
 */
@Composable
private fun FontListItem(
    fontEntry: FontEntry,
    isSelected: Boolean,
    onSelect: () -> Unit,
    modifier: Modifier = Modifier
) {
    val typefaceResult = rememberTerminalTypefaceResultFromStoredValue(fontEntry.storedValue)

    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = modifier
            .fillMaxWidth()
            .clickable { onSelect() }
            .background(
                if (isSelected) {
                    MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.3f)
                } else {
                    MaterialTheme.colorScheme.surface
                }
            )
            .padding(horizontal = 8.dp, vertical = 4.dp)
    ) {
        RadioButton(
            selected = isSelected,
            onClick = onSelect
        )

        Spacer(modifier = Modifier.width(8.dp))

        if (typefaceResult.isLoading) {
            // Show loading indicator and name in default font
            Text(
                text = fontEntry.displayName,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.weight(1f)
            )
            CircularProgressIndicator(
                modifier = Modifier.size(16.dp),
                strokeWidth = 2.dp
            )
        } else {
            // Show font name rendered in that font
            Text(
                text = fontEntry.displayName,
                style = MaterialTheme.typography.bodyMedium,
                fontFamily = typefaceResult.typeface.toFontFamily(),
                modifier = Modifier.weight(1f)
            )
            if (typefaceResult.loadFailed) {
                Text(
                    text = "(unavailable)",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

/**
 * Extension function to convert Android Typeface to Compose FontFamily.
 */
private fun Typeface.toFontFamily(): FontFamily {
    return if (this == Typeface.MONOSPACE) {
        FontFamily.Monospace
    } else {
        FontFamily(this)
    }
}

@ScreenPreviews
@Composable
private fun FontPickerDialogPreview() {
    ConnectBotTheme {
        FontPickerDialog(
            currentFontValue = "JETBRAINS_MONO",
            fontEntries = listOf(
                FontEntry("Default (Monospace)", "SYSTEM_DEFAULT"),
                FontEntry("JetBrains Mono", "JETBRAINS_MONO"),
                FontEntry("Fira Code", "FIRA_CODE"),
                FontEntry("Source Code Pro", "SOURCE_CODE_PRO"),
                FontEntry("Roboto Mono", "ROBOTO_MONO"),
                FontEntry("My Custom Font", "local:my_font.ttf")
            ),
            onFontSelected = {},
            onDismiss = {}
        )
    }
}
