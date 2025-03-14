import com.lightningkite.deployhelpers.*

plugins {
    alias(libs.plugins.kotlin.kmp) apply true
    alias(libs.plugins.kotlinx.serialization) apply true
    alias(libs.plugins.android.library) apply true
    alias(libs.plugins.google.ksp) apply true
}
//Template var
group = "com.lightningkite.template"
version = "1.0-SNAPSHOT"

val kotlinVersion: String by project

kotlin {
    applyDefaultHierarchyTemplate()
    androidTarget()
    jvm()
    js(IR) {
        browser()
    }
    iosX64()
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        val commonMain by getting {
            dependencies {
                api(libs.com.lightningkite.server.shared)
            }
            kotlin {
                srcDir(file("build/generated/ksp/common/commonMain/kotlin"))
            }
        }
    }
}

dependencies {
    configurations.filter { it.name.startsWith("ksp") && it.name != "ksp" }.forEach {
        add(it.name, libs.com.lightningkite.server.processor)
    }
}

android {
    namespace = "com.lightningkite.template.shared"
    compileSdk = 34

    defaultConfig {
        minSdk = 26
    }
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    dependencies {
        coreLibraryDesugaring(libs.android.desugar)
    }
}