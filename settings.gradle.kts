@file:Suppress("ktlint:standard:property-naming")

pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
    }
}

// Composite build: use local termlib if available (for development or CI)
// Check both ../termlib (local dev) and ./termlib (CI workspace)
val termlibPath = when {
    file("../termlib").exists() -> "../termlib"
    file("termlib").exists() -> "termlib"
    else -> null
}
if (termlibPath != null) {
    includeBuild(termlibPath) {
        dependencySubstitution {
            substitute(module("com.github.johnrobinsn:termlib")).using(project(":lib"))
        }
    }
}

val TRANSLATIONS_ONLY: String? by settings

if (TRANSLATIONS_ONLY.isNullOrBlank()) {
    include(":app")
}
include(":translations")
