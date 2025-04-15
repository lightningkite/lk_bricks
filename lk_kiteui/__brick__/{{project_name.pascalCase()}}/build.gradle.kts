plugins {
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.kotlinJvm) apply false
    alias(libs.plugins.androidLibrary) apply false
    alias(libs.plugins.kiteui) apply false
    alias(libs.plugins.kotlinxSerialization) apply false
    alias(libs.plugins.ksp) apply false
    alias(libs.plugins.kotlinCocoapods) apply false
    alias(libs.plugins.sentry) apply false
    alias(libs.plugins.viteKotlin) apply false
}

buildscript {
    dependencies {
        classpath(libs.lightningkite.gradle.helpers)
    }
}

//androidLibrary = { id = "com.android.library", version.ref = "agp" }
//androidApplication = { id = "com.android.application", version.ref = "agp" }
//kotlinMultiplatform = { id = "org.jetbrains.kotlin.multiplatform", version.ref = "kotlin" }
//kiteui = { id = "com.lightningkite.kiteui", version.ref = "kiteui" }
//kotlinxSerialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
//ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }