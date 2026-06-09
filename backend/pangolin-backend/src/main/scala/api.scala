package pangolin

import cats.effect.IO
import cats.syntax.all.*
import fs2.Stream
import fs2.concurrent.Topic
import fs2.io.toInputStreamResource
import fs2.io.file.{Files, Path}
import org.http4s.HttpRoutes
import org.http4s.server.Router
import sttp.model.Part
import sttp.model.sse.ServerSentEvent
import sttp.tapir.{Endpoint, endpoint, path, stringToPath, multipartBody, stringBody, emptyOutput, query}
import sttp.tapir.generic.auto.*
import sttp.tapir.json.upickle.jsonBody
import sttp.tapir.server.http4s.{Http4sServerOptions, Http4sServerInterpreter, serverSentEventsBody}
import sttp.tapir.server.interceptor.RequestInterceptor
import sttp.tapir.server.interceptor.cors.{CORSConfig, CORSInterceptor}
import upickle.default.ReadWriter
import pangolin.repo.ProfileTextboxCreator
import scala.concurrent.duration.DurationInt

object api {
  case class Position(
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) derives ReadWriter

  case class Recommendation(
      userId: Int,
      name: String,
      location: String,
      bio: String,
      age: Int,
      profileImageUrl: String,
      rejected: Boolean,
  ) derives ReadWriter

  case class ProfileImage(
      url: String,
      position: Position,
  ) derives ReadWriter

  case class ProfileTextbox(
      title: String,
      body: String,
      font: Option[String],
      fontHexARGB: Long,
      backgroundHexARGB: Long,
      position: Position,
  ) derives ReadWriter

  case class ProfileSticker(
      name: String, // plain name. no extension
      position: Position,
  ) derives ReadWriter

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
  ) derives ReadWriter

  case class UploadRequest(
    image: Part[Array[Byte]]
  )
  case class UploadResponse(
    url: String
  ) derives ReadWriter

  case class NewUserResponse(
    userId: Int
  ) derives ReadWriter

  case class SharedBoard(
    elems: Vector[SharedBoardElement]
  ) derives ReadWriter

  case class SharedBoardElement(
    sharedElemId: Int,
    datetime: Long,
    messages: Vector[SharedBoardReply],
    url: Option[String],
    text: Option[String],
    read: Boolean,
  ) derives ReadWriter

  case class SharedBoardReply(
    datetime: Long,
    senderId: Int,
    text: String,
  ) derives ReadWriter

  sealed trait Message {
    val senderId: Int
    val receiverId: Int
    val datetime: Long
  }

  case class MessageImage(
    senderId: Int,
    receiverId: Int,
    url: String,
    datetime: Long,
  ) extends Message derives ReadWriter

  case class MessageText(
    senderId: Int,
    receiverId: Int,
    text: String,
    datetime: Long,
  ) extends Message derives ReadWriter

  case class MessageReply(
    sharedElementId: Int,
    senderId: Int,
    receiverId: Int,
    text: String,
    datetime: Long,
  ) extends Message derives ReadWriter

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

  private val sharedBoardEndpoint = endpoint.get
    .in("message" / "board")
    .in(query[Int]("user1Id"))
    .in(query[Int]("user2Id"))
    .out(jsonBody[SharedBoard])

  private val messageImageEndpoint = endpoint.post
    .in("message" / "send" / "image")
    .in(jsonBody[MessageImage])

  private val messageTextEndpoint = endpoint.post
    .in("message" / "send" / "text")
    .in(jsonBody[MessageText])

  private val messageReplyEndpoint = endpoint.post
    .in("message" / "send" / "reply")
    .in(jsonBody[MessageReply])

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

  private val sharedBoardRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    sharedBoardEndpoint.serverLogic { (user1Id, user2Id) =>
      repo.getSharedBoard(user1Id, user2Id).map(_.toRight(()))
    }
  )

  private def messageTextRoutes(topic: Topic[IO, Message]) = serverInterpreter.toRoutes(
    messageTextEndpoint.serverLogicSuccess { message =>
      // TODO: Add text message to database
      publishMessage(topic, message)
    }
  )

  private def messageImageRoutes(topic: Topic[IO, Message]) = serverInterpreter.toRoutes(
    messageImageEndpoint.serverLogicSuccess { message =>
      // TODO: Add image message to database
      publishMessage(topic, message)
    }
  )

  private def messageReplyRoutes(topic: Topic[IO, Message]) = serverInterpreter.toRoutes(
    messageReplyEndpoint.serverLogicSuccess { message =>
      // TODO: add rely message to database
      publishMessage(topic, message)
    }
  )

  private def publishMessage(topic: Topic[IO, Message], message: Message) = {
    topic.publish1(message).as(())
  }

  private def messageListenSseRoutes(topic: Topic[IO, Message]) = serverInterpreter.toRoutes(
    messageListenSseEndpoint.serverLogicSuccess { receiverId =>
      IO.pure {
        topic.subscribeUnbounded
          .filter(ids => ids.receiverId == receiverId || ids.senderId == receiverId)
          .map(_ => ServerSentEvent())
      }
    }
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

  def router(topic: Topic[IO, Message]) = Router(
    "/" -> newUserRoutes,
    "/" -> recommendationsRoutes,
    "/" -> profileViewRoutes,
    "/" -> profileEditRoutes,
    "/" -> uploadRoutes,
    "/" -> sharedBoardRoutes,
    "/" -> messageTextRoutes(topic),
    "/" -> messageImageRoutes(topic),
    "/" -> messageReplyRoutes(topic),
    "/" -> messageListenSseRoutes(topic),
  ).orNotFound
}
