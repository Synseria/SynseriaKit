plugins {
    id("com.android.library")
    id("maven-publish")
}

android {
    namespace = "com.synseria.kit"
    compileSdk = 35
    defaultConfig { minSdk = 26 }
    publishing { singleVariant("release") }
}

afterEvaluate {
    publishing {
        publications {
            register<MavenPublication>("release") {
                from(components["release"])
                groupId = "com.github.Synseria"
                artifactId = "SynseriaKit"
            }
        }
    }
}
