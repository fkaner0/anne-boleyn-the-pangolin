package pangolin

import cats.effect.IO
import cats.syntax.all.*
import fs2.Stream
import fs2.concurrent.Channel
import fs2.io.toInputStreamResource
import fs2.io.file.{Files, Path}
import org.http4s.HttpRoutes
import org.http4s.server.Router
import sttp.model.Part
import sttp.model.sse.ServerSentEvent
import sttp.tapir.{Endpoint, endpoint, path, stringToPath, multipartBody, stringBody, emptyOutput}
import sttp.tapir.generic.auto.*
import sttp.tapir.json.upickle.jsonBody
import sttp.tapir.server.http4s.{Http4sServerOptions, Http4sServerInterpreter, serverSentEventsBody}
import sttp.tapir.server.interceptor.RequestInterceptor
import sttp.tapir.server.interceptor.cors.{CORSConfig, CORSInterceptor}
import upickle.default.{ReadWriter, macroRW}
import pangolin.repo.ProfileTextboxCreator
import scala.concurrent.duration.DurationInt

object api {
  case class Position(
      x: Int,
      y: Int,
      rotation: Double,
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
      age: Int,
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

  case class ProfileTextbox(
      title: String,
      body: String,
      font: Option[String],
      fontHexARGB: Long,
      backgroundHexARGB: Long,
      position: Position,
  )
  object ProfileTextbox {
    given ReadWriter[ProfileTextbox] = macroRW
  }

  case class ProfileSticker(
      name: String, // plain name. no extension
      position: Position,
  )
  object ProfileSticker {
    given ReadWriter[ProfileSticker] = macroRW
  }

  case class FullProfile(
      name: String,
      location: String,
      profileImageUrl: String,
      bio: String,
      age: Int,
      wallBackgroundHexARGB: Long,
      wallImages: Vector[ProfileImage],
      wallTextboxes: Vector[ProfileTextbox],
      wallStickers: Vector[ProfileSticker],
  )
  object FullProfile {
    given ReadWriter[FullProfile] = macroRW
  }

  case class UploadRequest(
    image: Part[Array[Byte]]
  )
  case class UploadResponse(
    url: String
  )
  object UploadResponse {
    given ReadWriter[UploadResponse] = macroRW
  }

  case class NewUserResponse(
    userId: Int
  )
  object NewUserResponse {
    given ReadWriter[NewUserResponse] = macroRW
  }

  case class Message(
    senderId: Int,
    receiverId: Int,
    message: String,
  )
  object Message {
    given ReadWriter[Message] = macroRW
  }

  private val profileViewEndpoint = endpoint.get
    .in("profile" / "view" / path[Int]("userId"))
    .out(jsonBody[FullProfile])

  private val profileEditEndpoint = endpoint.put
    .in("profile" / "edit" / path[Int]("userId"))
    .in(jsonBody[FullProfile])
    .errorOut(stringBody)
    .out(emptyOutput) /// TODO: or do we want something?

  private val uploadWallImageEndpoint = endpoint.post
    .in("wallImage")
    .in(multipartBody[UploadRequest])
    .errorOut(stringBody)
    .out(jsonBody[UploadResponse])

  private val newUserEndpoint = endpoint.post
    .in("user")
    .out(jsonBody[NewUserResponse])

  private val reccomendationsEndpoint = endpoint.get
    .in("recommendations")
    .out(jsonBody[Vector[Recommendation]])

  private val messageSendEndpoint = endpoint.post
    .in("message" / "send")
    .in(jsonBody[Message])

  private val messageListenSseEndpoint = endpoint.get
    .in("message" / "listen" / path[Int]("receiverId"))
    .out(serverSentEventsBody[IO])

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
      bio = user.bio,
      age = user.age,
      profileImageUrl = user.profileImageUrl,
      rejected = false,
    )
  }

  private val profileViewRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    profileViewEndpoint.serverLogic { userId =>
      repo
        .getProfile(userId)
        .map(_.map { (user, images, textboxes, stickers) =>
          FullProfile(
            name = user.name,
            location = user.location,
            bio = user.bio,
            age = user.age,
            profileImageUrl = user.profileImageUrl,
            wallBackgroundHexARGB = user.wallBackgroundHexARGB,
            wallImages = images.map(_.toApi),
            wallTextboxes = textboxes.map(_.toApi),
            wallStickers = stickers.map(_.toApi),
          )
        })
    },
  )

  private val profileEditRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    profileEditEndpoint.serverLogic { (userId, request) =>
      repo.updateFullProfile(
        request.fromApi(userId),
        request.wallTextboxes.map(_.fromApi(userId)),
        request.wallImages.map(_.fromApi(userId)),
        request.wallStickers.map(_.fromApi(userId)),
      )
    }
  )

  private val uploadRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    uploadWallImageEndpoint.serverLogic { request =>
      IO.blocking {
        imageservice.uploadBedroomWallImage(request.image.body)
      }.attempt.map {
        case Right(Some(imageUploaderAPI.ImageURL(url))) => Right(UploadResponse(url))
        case Right(None) => Left("Error in image upload")
        case Left(err)  => Left(err.getMessage)
      }
    }
  )

  private val newUserRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    newUserEndpoint.serverLogic { _ =>
      val newUserId: IO[Either[Nothing, Int]] = repo.newProfile()
      newUserId.map(_.map(NewUserResponse(_)))
    }
  )

  private def messageSendRoutes(channel: Channel[IO, Message]) = serverInterpreter.toRoutes(
    messageSendEndpoint.serverLogicSuccess { message =>
      // TODO: add message to database
      channel.send(message).as(())
    }
  )

  private def messageListenSseRoutes(channel: Channel[IO, Message]) = serverInterpreter.toRoutes(
    messageListenSseEndpoint.serverLogicSuccess { receiverId => IO.pure(channel.stream.filter(_.receiverId == receiverId).map(msg => ServerSentEvent(Some(msg.message)))) }
  )

  extension (image: repo.ProfileImage) {
    private def toApi = ProfileImage(
      url = image.url,
      position = image.position,
    )
  }

  extension (textbox: repo.ProfileTextbox) {
    private def toApi = ProfileTextbox(
      title = textbox.title,
      body = textbox.body,
      font = textbox.font,
      fontHexARGB = textbox.fontARGB,
      backgroundHexARGB = textbox.backgroundARGB,
      position = textbox.position,
    )
  }


  extension (sticker: ProfileSticker) {
    private def fromApi(userId: Int) = repo.ProfileStickerCreator(
      userId = userId,
      name = sticker.name,
      x = sticker.position.x,
      y = sticker.position.y,
      rotation = sticker.position.rotation,
      aspectRatio = sticker.position.aspectRatio,
      scale = sticker.position.scale,
    )
  }

  extension (image: ProfileImage) {
    private def fromApi(userId: Int) = repo.ProfileImageCreator(
      userId = userId,
      url = image.url,
      x = image.position.x,
      y = image.position.y,
      rotation = image.position.rotation,
      aspectRatio = image.position.aspectRatio,
      scale = image.position.scale,
    )
  }
  
  extension (textbox: ProfileTextbox) {
    private def fromApi(userId: Int) = repo.ProfileTextboxCreator(
      userId = userId,
      title = textbox.title,
      body = textbox.body,
      font = textbox.font,
      fontARGB = textbox.fontHexARGB,
      backgroundARGB = textbox.backgroundHexARGB,
      x = textbox.position.x,
      y = textbox.position.y,
      rotation = textbox.position.rotation,
      aspectRatio = textbox.position.aspectRatio,
      scale = textbox.position.scale,
    )
  }

  extension (profile: FullProfile) {
    private def fromApi(userId: Int) = repo.Profile(
      id = userId,
      name = profile.name,
      location = profile.location,
      bio = profile.bio,
      age = profile.age,
      profileImageUrl = profile.profileImageUrl,
      wallBackgroundHexARGB = profile.wallBackgroundHexARGB,
    )
  }

  extension (sticker: repo.ProfileSticker) {
    private def toApi = ProfileSticker(
      name = sticker.name,
      position = sticker.position,
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

  def router(channel: Channel[IO, Message]) = Router(
    "/" -> api.newUserRoutes,
    "/" -> api.recommendationsRoutes,
    "/" -> api.profileViewRoutes,
    "/" -> api.profileEditRoutes,
    "/" -> api.uploadRoutes,
    "/" -> api.messageSendRoutes(channel),
    "/" -> api.messageListenSseRoutes(channel),
  ).orNotFound
}
