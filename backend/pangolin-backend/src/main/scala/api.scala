package pangolin

import cats.effect.IO
import org.http4s.HttpRoutes
import org.http4s.server.Router
import sttp.tapir.{Endpoint, endpoint, path, stringToPath}
import sttp.tapir.generic.auto.*
import sttp.tapir.json.upickle.jsonBody
import sttp.tapir.server.http4s.{Http4sServerOptions, Http4sServerInterpreter}
import sttp.tapir.server.interceptor.RequestInterceptor
import sttp.tapir.server.interceptor.cors.{CORSConfig, CORSInterceptor}
import upickle.default.{ReadWriter, macroRW}

object api {
  case class Position(
      x: Int,
      y: Int,
      rotation: Int,
      aspectRatio: Double,
      scale: Double,
  )
  object Position {
    given ReadWriter[Position] = macroRW
  }

  case class Recommendation(
      userId: Int,
      name: String,
      location: String,
      bio: String,
      profileImageUrl: String,
      rejected: Boolean,
  )
  object Recommendation {
    given ReadWriter[Recommendation] = macroRW
  }

  case class ProfileImage(
      url: String,
      position: Position,
  )
  object ProfileImage {
    given ReadWriter[ProfileImage] = macroRW
  }

  case class ProfileTextBox(
      title: String,
      body: String,
      position: Position,
  )
  object ProfileTextBox {
    given ReadWriter[ProfileTextBox] = macroRW
  }

  case class Profile(
      userId: Int,
      name: String,
      location: String,
      profileImageUrl: String,
      images: Vector[ProfileImage],
      textBoxes: Vector[ProfileTextBox],
  )
  object Profile {
    given ReadWriter[Profile] = macroRW
  }

  private val profileEndpoint = endpoint.get
    .in("profile" / path[Int]("userId"))
    .out(jsonBody[Profile])

  private val reccomendationsEndpoint = endpoint.get
    .in("recommendations")
    .out(jsonBody[Vector[Recommendation]])

  private val rejectProfileEndpoint = endpoint.put
    .in("profile" / path[Int]("userId"))
    .in(jsonBody[Boolean])

  private val http4sOptions: Http4sServerOptions[IO] = Http4sServerOptions
    .customiseInterceptors[IO]
    .corsInterceptor(
      CORSInterceptor.customOrThrow(
        CORSConfig.default.allowAllHeaders.allowAllOrigins.allowAllMethods,
      ),
    )
    .options

  private val serverInterpreter = Http4sServerInterpreter[IO](http4sOptions)

  val recommendationsRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    reccomendationsEndpoint.serverLogic { _ =>
      repo.getRecommendations.map(_.map(_.map(_.toRecommendation)))
    },
  )

  extension (user: repo.Profile) {
    def toRecommendation = Recommendation(
      userId = user.id,
      name = user.name,
      location = user.location,
      bio = "",
      profileImageUrl = user.profileImageUrl,
      rejected = false,
    )
  }

  private val profileRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    profileEndpoint.serverLogic { userId =>
      repo
        .getProfile(userId)
        .map(_.map { (user, images, textBoxes) =>
          Profile(
            userId = user.id,
            name = user.name,
            location = user.location,
            profileImageUrl = user.profileImageUrl,
            images = images.map(_.toApi),
            textBoxes = textBoxes.map(_.toApi),
          )
        })
    },
  )

  extension (image: repo.ProfileImage) {
    private def toApi = ProfileImage(
      url = image.url,
      position = image.position,
    )
  }

  extension (textBox: repo.ProfileTextBox) {
    private def toApi = ProfileTextBox(
      title = textBox.title,
      body = textBox.body,
      position = textBox.position,
    )
  }

  extension (positioned: repo.Positioned) {
    private def position = Position(
      positioned.x,
      positioned.y,
      positioned.rotation,
      positioned.aspectRatio,
      positioned.scale,
    )
  }

  val router = Router(
    "/" -> api.recommendationsRoutes,
    "/" -> api.profileRoutes,
  ).orNotFound
}
