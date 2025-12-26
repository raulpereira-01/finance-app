import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (name == "vosk_flutter") {
        plugins.withId("com.android.library") {
            // The plugin still ships a package attribute inside its manifest, which
            // is no longer supported when using the Android Gradle Plugin 8+.
            // Remove it at configuration time to prevent manifest processing from
            // failing during builds.
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val originalContent = manifestFile.readText()
                val sanitizedContent = originalContent.replaceFirst(
                    Regex("""package\s*=\s*\"[^\"]+\"\s*"""),
                    ""
                )

                if (originalContent != sanitizedContent) {
                    manifestFile.writeText(sanitizedContent)
                }
            }

            extensions.configure<LibraryExtension>("android") {
                namespace = "org.vosk_flutter"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
