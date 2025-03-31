rootProject.name = "hacker_news_reader"

pluginManagement {
    val kotlinVersion: String by settings
    val kspVersion: String by settings
    val kiteuiVersion: String by settings
    repositories {
        mavenLocal()
        maven(url = "https://s01.oss.sonatype.org/content/repositories/snapshots/")
        maven(url = "https://s01.oss.sonatype.org/content/repositories/releases/")
        google()
        gradlePluginPortal()
        maven("https://lightningkite-maven.s3.us-west-2.amazonaws.com")
        mavenCentral()
    }

    plugins {
        kotlin("jvm") version kotlinVersion
        kotlin("multiplatform") version kotlinVersion
        kotlin("plugin.serialization") version kotlinVersion
        id("com.google.devtools.ksp") version kspVersion
        id("com.lightningkite.kiteui") version kiteuiVersion
    }
}

@Suppress("UnstableApiUsage")
dependencyResolutionManagement {
    repositories {
        google {
            mavenContent {
                includeGroupAndSubgroups("androidx")
                includeGroupAndSubgroups("com.android")
                includeGroupAndSubgroups("com.google")
            }
        }
        mavenLocal()
        mavenCentral()
        repositories {
            maven(url = "https://www.jitpack.io")
        }
        maven("https://lightningkite-maven.s3.us-west-2.amazonaws.com")
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.8.0"
}

include(":apps")
