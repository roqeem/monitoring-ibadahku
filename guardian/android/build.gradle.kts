allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newLibsDir by extra(repositories {
    google()
})
