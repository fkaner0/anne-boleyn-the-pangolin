val scala3Version = "3.8.3"

lazy val root = project
  .in(file("."))
  .settings(
    name := "pangolin-backend",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    libraryDependencies += "com.softwaremill.sttp.tapir" %% "tapir-core" % "1.13.19",
    libraryDependencies += "com.softwaremill.sttp.tapir" %% "tapir-netty-server-sync" % "1.13.19",
    libraryDependencies += "com.softwaremill.sttp.tapir" %% "tapir-json-upickle" % "1.13.19",
    libraryDependencies += "com.lihaoyi" %% "upickle" % "4.4.3"
  )
