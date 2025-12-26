import com.android.build.gradle.LibraryExtension
import javax.xml.parsers.DocumentBuilderFactory

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
    afterEvaluate {
        if (name == "vosk_flutter") {
            extensions.findByType<LibraryExtension>()?.let { extension ->
                if (extension.namespace.isNullOrBlank()) {
                    val manifestFile = extension.sourceSets.getByName("main").manifest.srcFile
                    if (manifestFile.exists()) {
                        val packageName = manifestFile.inputStream().use { stream ->
                            DocumentBuilderFactory
                                .newInstance()
                                .newDocumentBuilder()
                                .parse(stream)
                                .documentElement
                                .getAttribute("package")
                        }
                        if (packageName.isNotBlank()) {
                            extension.namespace = packageName
                        }
                    }
                }
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
