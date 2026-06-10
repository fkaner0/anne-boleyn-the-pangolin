val scala3Version = "3.8.3"

lazy val root = project
  .in(file("."))
  .settings(
    name := "pangolin-backend",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    cancelable in Global := true,

    libraryDependencies += "com.softwaremill.sttp.tapir" %% "tapir-core" % "1.13.19",
    libraryDependencies += "com.softwaremill.sttp.tapir" %% "tapir-netty-server-sync" % "1.13.19",
    libraryDependencies += "com.softwaremill.sttp.tapir" %% "tapir-http4s-server" % "1.13.19",
    libraryDependencies += "com.softwaremill.sttp.tapir" %% "tapir-json-upickle" % "1.13.19",
    libraryDependencies += "com.lihaoyi" %% "upickle" % "4.4.3",
    libraryDependencies += "org.scalameta" %% "munit" % "1.3.0" % Test,
    libraryDependencies += "org.http4s" %% "http4s-blaze-server" % "0.23.16",
    libraryDependencies += "com.softwaremill.sttp.client4" %% "core" % "4.0.0-RC3",
    libraryDependencies += "com.augustnagro" %% "magnum" % "1.3.0",
    libraryDependencies += "com.augustnagro" %% "magnumpg" % "1.3.0", // allows for arrays in db
    libraryDependencies += "org.postgresql" % "postgresql" % "42.7.11",
    libraryDependencies += "com.lihaoyi" %% "os-lib" % "0.11.7",

  // cloudinary java sdk
    libraryDependencies += "com.cloudinary" % "cloudinary-http5" % "2.0.0",   // general
    // libraryDependencies += "com.cloudinary" %% "cloudinary-taglib" % "2.0.0", // J2EE
    // libraryDependencies += "io.github.cdimascio" %% "dotenv-java" % "2.2.4",  // Android
    libraryDependencies += "io.github.cdimascio" % "java-dotenv" % "5.2.2",
  // end cloudinary

    assembly / assemblyJarName := "app.jar",

    assembly / assemblyMergeStrategy := {
      case PathList("module-info.class") =>
        MergeStrategy.discard
      case PathList("META-INF", "versions", "11", "module-info.class") =>
        MergeStrategy.discard
      case PathList("META-INF", "io.netty.versions.properties") =>
        MergeStrategy.first
      case PathList("META-INF", xs @ _*) =>
        MergeStrategy.discard
      case _ =>
        MergeStrategy.first
    }
  )
