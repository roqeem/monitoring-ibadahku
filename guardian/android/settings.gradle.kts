pluginManagement {
    val flutterGradlePluginPrefix = "dev.flutter"
    repositories {
        google()
        gradle()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("dev.flutter.flutter-version") version "3.0.0" apply false
    }
}

include(":app")

val localProperties = java.util.Properties()
file("../local.properties").inputStream().use { localProperties.load(it) }

val flutterDirPath = localProperties.getProperty("flutter.sdk")
    ?: throw RuntimeException("flutter.sdk not set in local.properties")

// Flutter Gradle Plugin
includeBuild("$flutterDirPath/packages/flutter_tools/gradle")

dependencyResolutionManagement(
   .repositoriesMode = RepositoriesMode.FAIL_ON_PROJECT_REPOS
) {
    repositories {
        google()
        mavenCentral()
    }
}
