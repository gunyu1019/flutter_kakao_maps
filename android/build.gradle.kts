group = "kr.yhs.flutter_kakao_maps"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "1.9.25"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.5.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://devrepo.kakao.com/nexus/repository/kakaomap-releases/")
        }
    }
}

apply(plugin = "com.android.library")
apply(plugin = "kotlin-android")

configure<com.android.build.gradle.LibraryExtension> {
    namespace = "kr.yhs.flutter_kakao_maps"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    sourceSets {
        named("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 23
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    "implementation"("com.kakao.maps.open:android:2.13.2")
    // "implementation"(files("libs/flutter.jar"))
}
