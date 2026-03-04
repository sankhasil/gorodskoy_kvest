import com.adarshr.gradle.testlogger.theme.ThemeType
import com.bmuschko.gradle.docker.tasks.image.Dockerfile
import org.apache.tools.ant.filters.ReplaceTokens
import org.sonarqube.gradle.SonarTask

plugins {
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.spring)
    alias(libs.plugins.kotlin.jpa)
    alias(libs.plugins.ktlint)
    alias(libs.plugins.test.logger)
    alias(libs.plugins.docker.spring.boot.application)
    alias(libs.plugins.sonarqube)
    alias(libs.plugins.kover)
    `maven-publish`
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

ktlint {
    version = "1.5.0" // set because of https://github.com/JLLeitschuh/ktlint-gradle/issues/809
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(libs.bundles.kotlin)
    implementation(libs.bundles.spring)
    implementation(libs.bundles.logbook)
    implementation(libs.bundles.prometheus)
    implementation(libs.bundles.datamongo)
    implementation(platform(libs.micrometer.tracing.bom))
    implementation(libs.micrometer.core)
    implementation(libs.micrometer.tracing.bridge.brave) {
        exclude(group = "io.zipkin.reporter2", module = "zipkin-reporter-brave")
    }
    testImplementation(libs.junit.container)
    testImplementation(libs.bundles.test) {
        exclude(module = "mockito-core")
    }
}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll("-Xjsr305=strict")
    }
}

tasks {
    withType<Dockerfile> {
        dependsOn(bootJar)
        instruction("RUN apk add openjdk21-jre")
        instruction("RUN adduser -u 4711 --disabled-password -h /home/java -s /bin/ash java")
        instruction("USER 4711")
    }

    build {
        dependsOn(ktlintFormat)
        finalizedBy(dockerCreateDockerfile)
    }
}

tasks.bootBuildImage {
    imageName.set("${rootProject.name}:latest")
    environment.set(
        mapOf(
            "BP_JVM_VERSION" to "21",
            "BPE_APPEND_JAVA_TOOL_OPTIONS" to "-Xmx2048m"
        )
    )
}

tasks.withType<Test> {
    useJUnitPlatform()
}

testlogger {
    theme = ThemeType.MOCHA
}

tasks.withType<SonarTask> {
    dependsOn(tasks.koverXmlReport)
}

sonarqube {
    properties {
        property("sonar.coverage.jacoco.xmlReportPaths", "build/reports/kover/report.xml")
        property("sonar.exclusions", "prism/oscare-mock.yaml")
    }
}


val gradlePropertiesMap: Map<String, String> =
    project.properties
        .filterValues { it != null }
        .flatMap { (key, value) ->
            listOf(key to value.toString(), "project.$key" to value.toString())
        }.toMap()

// replace all '@variable@' values in application.yaml
tasks.named<ProcessResources>("processResources").configure {
    filesMatching(listOf("**/application*.yaml", "**/application*.yml")) {
        filter<ReplaceTokens>("tokens" to gradlePropertiesMap)
    }
}

publishing {
    repositories {
    }
}
