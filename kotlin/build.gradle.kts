plugins {
    kotlin("jvm") version "1.9.22"
    kotlin("plugin.serialization") version "1.9.22"
    `maven-publish`
}

group = "ai.ensoul"
version = "0.2.5"

repositories {
    mavenCentral()
}

dependencies {
    // Ktor client
    implementation("io.ktor:ktor-client-core:2.3.8")
    implementation("io.ktor:ktor-client-cio:2.3.8")
    implementation("io.ktor:ktor-client-content-negotiation:2.3.8")
    implementation("io.ktor:ktor-serialization-kotlinx-json:2.3.8")

    // Serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.0")

    // Testing
    testImplementation("io.kotest:kotest-runner-junit5:5.8.0")
    testImplementation("io.kotest:kotest-assertions-core:5.8.0")
    testImplementation("io.ktor:ktor-client-mock:2.3.8")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.0")
}

kotlin {
    jvmToolchain(17)
}

tasks.withType<Test>().configureEach {
    useJUnitPlatform()
}

publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])
            groupId = "ai.ensoul"
            artifactId = "ensoul-sdk"
            version = project.version.toString()
        }
    }
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/ensoul-ai/ensoul-sdk")
            credentials {
                username = System.getenv("GITHUB_ACTOR") ?: ""
                password = System.getenv("GITHUB_TOKEN") ?: ""
            }
        }
    }
}
