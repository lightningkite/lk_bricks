plugins {
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.lk.kiteui) apply false
    alias(libs.plugins.kotlin.kmp) apply false
    alias(libs.plugins.kotlin.jvm) apply false
    alias(libs.plugins.kotlinter) apply false
    alias(libs.plugins.maven.publish) apply false
    alias(libs.plugins.dokka) apply false
    alias(libs.plugins.api) apply false
    alias(libs.plugins.google.ksp) apply false
    alias(libs.plugins.kotlinx.serialization) apply false
    alias(libs.plugins.kotlin.cocoapods) apply false
}

buildscript {
    dependencies {
        classpath("com.lightningkite:lk-gradle-helpers:1.1.1")
    }
}
