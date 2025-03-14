import com.lightningkite.kiteui.KiteUiPluginExtension
import java.util.Properties

// Template variable
group = "com.lightningkite.template"
version = "1.0-SNAPSHOT"

plugins {
    alias(libs.plugins.android.application) apply true
    alias(libs.plugins.lk.kiteui) apply true
    alias(libs.plugins.kotlin.kmp) apply true
    alias(libs.plugins.kotlinter) apply true
    alias(libs.plugins.maven.publish) apply true
    alias(libs.plugins.dokka) apply true
    alias(libs.plugins.kotlin.cocoapods) apply true
}

kotlin {
    applyDefaultHierarchyTemplate()
    androidTarget()
    iosX64()
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
                api(libs.kotlinx.coroutines.core)
                api(libs.com.lightningkite.kiteui.library)
                api(project(":shared"))
            }
            kotlin {
                srcDir(file("build/generated/kiteui"))
            }
        }
        val androidMain by getting {
            dependencies {
                api(libs.firebase.messaging)
            }
        }
        val iosMain by getting {
            dependencies {
                implementation(libs.sentry.kmp)
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
            export(project(":shared"))
            export(libs.com.lightningkite.kiteui.library)
//            export(lk.kiteUi(4))
//            export(lk.lightningServerKiteUiClient(4))
//            embedBitcode(BitcodeEmbeddingMode.BITCODE)
//            embedBitcode(BitcodeEmbeddingMode.DISABLE)
//            podfile = project.file("../example-app-ios/Podfile")
        }
        pod("Sentry") {
            version = "~> 8.25"
            linkOnly = true
            extraOpts += listOf("-compiler-option", "-fmodules")
        }
//        pod("Library") {
//            version = "1.0"
//            source = path(project.file("../library"))
//        }

        // Maps custom Xcode configuration to NativeBuildType
//        xcodeConfigurationToNativeBuildType["CUSTOM_DEBUG"] = NativeBuildType.DEBUG
//        xcodeConfigurationToNativeBuildType["CUSTOM_RELEASE"] = NativeBuildType.RELEASE
    }

}

configure<KiteUiPluginExtension> {
    //Replace with template variable
    this.packageName = "com.lightningkite.template"
    this.iosProjectRoot = project.file("./ios/Template")
}

android {
    namespace = "com.lightningkite.template"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.lightningkite.template"
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
    coreLibraryDesugaring(libs.android.desugar)
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
//
//
//repositories {
//    maven("https://jitpack.io")
//}
//
//
//val lk = lk {
//    kiteUiPlugin(4)
//}
//val coroutines: String by project
//kotlin {
//    applyDefaultHierarchyTemplate()
//    androidTarget()
//    iosX64()
//    iosArm64()
//    iosSimulatorArm64()
//    js {
//        binaries.executable()
//        browser {
//            commonWebpackConfig {
//                cssSupport {
//                    enabled.set(true)
//                }
//            }
//        }
//    }
//
//    sourceSets {
//        val commonMain by getting {
//            dependencies {
//                api(lk.kiteUi(4))
//                api(lk.lightningServerKiteUiClient(4))
//                api("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutines")
//                api(project(":shared"))
//            }
//            kotlin {
//                srcDir(file("build/generated/kiteui"))
//            }
//        }
//        val androidMain by getting {
//            dependencies {
//                api("com.google.firebase:firebase-messaging-ktx:24.1.0")
//            }
//        }
//        val iosMain by getting {
//            dependencies {
//                implementation("io.sentry:sentry-kotlin-multiplatform:0.9.0")
//            }
//        }
//        val jsMain by getting {
//            dependencies {
//                implementation(npm("firebase", "10.7.1"))
//                implementation(npm("@sentry/browser", "8.0.0"))
//            }
//        }
//
//
//        val commonTest by getting {
//            dependencies {
//                implementation("org.jetbrains.kotlin:kotlin-test")
//            }
//        }
//    }
//
//
//
//
//
//env("lk", "lk")