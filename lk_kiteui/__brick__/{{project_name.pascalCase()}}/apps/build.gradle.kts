import com.lightningkite.kiteui.KiteUiPluginExtension
import org.jetbrains.kotlin.gradle.plugin.mpp.BitcodeEmbeddingMode
import org.jetbrains.kotlin.gradle.plugin.mpp.NativeBuildType
import java.util.Properties

plugins {
    alias(libs.plugins.kotlinMultiplatform) apply true
    alias(libs.plugins.kotlinxSerialization) apply true
    alias(libs.plugins.kotlinCocoapods) apply true
    alias(libs.plugins.androidApplication) apply true
    alias(libs.plugins.kiteui) apply true
    alias(libs.plugins.sentry) apply true
    alias(libs.plugins.viteKotlin) apply true
}

group = "{{package_id}}"
version = "1.0-SNAPSHOT"

kotlin {
    applyDefaultHierarchyTemplate()
    androidTarget()
    iosX64()
    jvm()
    iosArm64()
    iosSimulatorArm64()
    js {
        binaries.executable()
        browser {
            commonWebpackConfig {
                cssSupport {
                    enabled.set(true)
                }
            }
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                api(libs.photoview)
                api(libs.kiteui)
                api(libs.client)
                implementation(libs.koin.core)
                implementation(libs.kotlinx.coroutines.core)
            }
            kotlin {
                srcDir(file("build/generated/kiteui"))
            }
        }
        commonTest.dependencies {
            implementation(libs.kotlinx.coroutines.core)
        }
        val androidMain by getting {
            dependencies {
                api(libs.firebase.messaging.ktx)
            }
        }
        val iosMain by getting {
            dependencies {
                implementation(libs.sentry.kotlin.multiplatform)
            }
        }
        val jsMain by getting {
            dependencies {
                implementation(npm("firebase", "10.7.1"))
                implementation(npm("@sentry/browser", "8.0.0"))
            }
        }


        val commonTest by getting {
            dependencies {
                implementation("org.jetbrains.kotlin:kotlin-test")
            }
        }
    }

    cocoapods {
        // Required properties
        // Specify the required Pod version here. Otherwise, the Gradle project version is used.
        version = "1.0"
        summary = "Some description for a Kotlin/Native module"
        homepage = "Link to a Kotlin/Native module homepage"
        ios.deploymentTarget = "14.0"

        // Optional properties
        // Configure the Pod name here instead of changing the Gradle project name
        name = "apps"

        framework {
            baseName = "apps"
            export(libs.kiteui)
            embedBitcode(BitcodeEmbeddingMode.BITCODE)
//            embedBitcode(BitcodeEmbeddingMode.DISABLE)
//            podfile = project.file("../example-app-ios/Podfile")
        }
        pod("Sentry") {
            version = "~> 8.25"
            linkOnly = true
            extraOpts += listOf("-compiler-option", "-fmodules")
        }
        // Maps custom Xcode configuration to NativeBuildType
        xcodeConfigurationToNativeBuildType["CUSTOM_DEBUG"] = NativeBuildType.DEBUG
        xcodeConfigurationToNativeBuildType["CUSTOM_RELEASE"] = NativeBuildType.RELEASE
    }
}

android {
    namespace = "edu.shanethompson.hackernewsreader"
    compileSdk = 35

    defaultConfig {
        applicationId = "edu.shanethompson.hackernewsreader"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.0.1"

        testInstrumentationRunner = "android.support.test.runner.AndroidJUnitRunner"
    }

    packaging {
        resources.excludes.add("com/lightningkite/lightningserver/lightningdb.txt")
        resources.excludes.add("com/lightningkite/lightningserver/lightningdb-log.txt")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    val props = project.rootProject.file("local.properties").takeIf { it.exists() }?.inputStream()?.use { stream ->
        Properties().apply { load(stream) }
    }
    if (props != null && props.getProperty("signingKeystore") != null) {
        signingConfigs {
            this.create("release") {
                storeFile = project.rootProject.file(props.getProperty("signingKeystore"))
                storePassword = props.getProperty("signingPassword")
                keyAlias = props.getProperty("signingAlias")
                keyPassword = props.getProperty("signingAliasPassword")
            }
        }
        buildTypes {
            this.getByName("release") {
                this.isMinifyEnabled = false
                this.proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
                this.signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring(libs.desugar.jdk.libs)
}

configure<KiteUiPluginExtension> {
    this.packageName = "{{package_id}}"
    this.iosProjectRoot = project.file("./ios/")
}

fun env(name: String, profile: String) {
    tasks.create("deployWeb${name}Init", Exec::class.java) {
        group = "deploy"
        this.dependsOn("viteBuild")
        this.environment("AWS_PROFILE", profile)
        val props = Properties()
        props.entries.forEach { environment(it.key.toString().trim('"', ' '), it.value.toString().trim('"', ' ')) }
        this.executable = "terraform"
        this.args("init")
        this.workingDir = file("terraform/$name")
    }
    tasks.create("deployWeb${name}", Exec::class.java) {
        group = "deploy"
        this.dependsOn("deployWeb${name}Init")
        this.environment("AWS_PROFILE", profile)
        val props = Properties()
        props.entries.forEach { environment(it.key.toString().trim('"', ' '), it.value.toString().trim('"', ' ')) }
        this.executable = "terraform"
        this.args("apply", "-auto-approve")
        this.workingDir = file("terraform/$name")
    }
}

env("default", "default")