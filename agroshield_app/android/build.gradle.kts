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

// Guarantee Java/Kotlin JVM-target consistency per module:
// each module's Kotlin target mirrors its own Java target.
subprojects {
    val align = {
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java)
            .configureEach {
                val javaTasks = tasks.withType(JavaCompile::class.java)
                if (javaTasks.isNotEmpty()) {
                    compilerOptions.jvmTarget.set(
                        org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(
                            javaTasks.first().targetCompatibility))
                }
            }
    }
    if (state.executed) align() else afterEvaluate { align() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
