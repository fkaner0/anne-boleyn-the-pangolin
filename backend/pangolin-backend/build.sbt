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
    libraryDependencies += "com.softwaremill.sttp.client4" %% "core" % "4.0.0-RC3"
  )
