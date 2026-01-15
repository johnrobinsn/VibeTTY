/*
 * ConnectBot: simple, powerful, open-source SSH client for Android
 * Copyright 2025 Kenny Root, Jeffrey Sharkey
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

package org.connectbot.ui

/**
 * Test tags for UI automation and Compose UI testing.
 * These tags are applied via Modifier.testTag() and appear in uiautomator dumps.
 *
 * Naming convention: {screen}_{element_type}_{name}
 */
object TestTags {
    object HostList {
        const val FAB_ADD = "hostlist_fab_add"
        const val MENU_OPTIONS = "hostlist_menu_options"
        const val MENU_SORT = "hostlist_menu_sort"
        const val MENU_SETTINGS = "hostlist_menu_settings"
        const val MENU_COLORS = "hostlist_menu_colors"
        const val MENU_PROFILES = "hostlist_menu_profiles"
        const val MENU_PUBKEYS = "hostlist_menu_pubkeys"
        const val MENU_DISCONNECT_ALL = "hostlist_menu_disconnect_all"
        fun item(hostId: Long) = "hostlist_item_$hostId"
        fun itemMenu(hostId: Long) = "hostlist_item_${hostId}_menu"
        fun itemEdit(hostId: Long) = "hostlist_item_${hostId}_edit"
        fun itemDelete(hostId: Long) = "hostlist_item_${hostId}_delete"
        fun itemDisconnect(hostId: Long) = "hostlist_item_${hostId}_disconnect"
    }

    object HostEditor {
        const val BUTTON_SAVE = "hosteditor_button_save"
        const val FIELD_QUICKCONNECT = "hosteditor_field_quickconnect"
        const val TOGGLE_ADVANCED = "hosteditor_toggle_advanced"
        const val FIELD_NICKNAME = "hosteditor_field_nickname"
        const val FIELD_HOSTNAME = "hosteditor_field_hostname"
        const val FIELD_PORT = "hosteditor_field_port"
        const val FIELD_USERNAME = "hosteditor_field_username"
        const val DROPDOWN_PROTOCOL = "hosteditor_dropdown_protocol"
        const val DROPDOWN_COLOR = "hosteditor_dropdown_color"
        const val DROPDOWN_PUBKEY = "hosteditor_dropdown_pubkey"
        const val DROPDOWN_PROFILE = "hosteditor_dropdown_profile"
        const val DROPDOWN_JUMPHOST = "hosteditor_dropdown_jumphost"
        const val SWITCH_COMPRESSION = "hosteditor_switch_compression"
        const val SWITCH_AUTHAGENT = "hosteditor_switch_authagent"
        const val SWITCH_STAYCONNECTED = "hosteditor_switch_stayconnected"
    }

    object Console {
        const val BUTTON_BACK = "console_button_back"
        const val BUTTON_INPUT = "console_button_input"
        const val BUTTON_PASTE = "console_button_paste"
        const val BUTTON_MENU = "console_button_menu"
        const val MENU_DISCONNECT = "console_menu_disconnect"
        const val MENU_URLSCAN = "console_menu_urlscan"
        const val MENU_RESIZE = "console_menu_resize"
        const val MENU_PORTFORWARDS = "console_menu_portforwards"
        const val TERMINAL = "console_terminal"
        fun tab(index: Int) = "console_tab_$index"
    }

    object Prompt {
        const val BUTTON_YES = "prompt_button_yes"
        const val BUTTON_NO = "prompt_button_no"
        const val BUTTON_OK = "prompt_button_ok"
        const val BUTTON_CANCEL = "prompt_button_cancel"
        const val BUTTON_RECONNECT = "prompt_button_reconnect"
        const val BUTTON_STAY = "prompt_button_stay"
        const val BUTTON_CLOSE = "prompt_button_close"
        const val FIELD_PASSWORD = "prompt_field_password"
        const val FIELD_RESPONSE = "prompt_field_response"
    }

    object Dialog {
        const val BUTTON_CONFIRM = "dialog_button_confirm"
        const val BUTTON_DISMISS = "dialog_button_dismiss"
    }
}
