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
import pangolin.repo.WallTextboxCreator
import com.augustnagro.magnum.SqlException //oops
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

  case class WallImage(
      url: String,
      position: Position,
  ) derives ReadWriter

  case class WallTextbox(
      title: String,
      body: String,
      font: Option[String],
      fontHexARGB: Long,
      backgroundHexARGB: Long,
      position: Position,
  ) derives ReadWriter

  case class WallSticker(
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
      wallImages: Vector[WallImage],
      wallTextboxes: Vector[WallTextbox],
      wallStickers: Vector[WallSticker],
  ) derives ReadWriter

  case class UploadRequest(
    image: Part[Array[Byte]]
  )
  case class UploadResponse(
    url: String
  ) derives ReadWriter

  case class NewUserRequest(
    username: String
  ) derives ReadWriter

  case class NewUserResponse(
    userId: Int
  ) derives ReadWriter

  case class LoginRequest(
    username: String
  ) derives ReadWriter

  case class LoginResponse(
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

  case class MessageImage(
    senderId: Int,
    receiverId: Int,
    url: String,
    datetime: Long,
  ) derives ReadWriter

  case class MessageText(
    senderId: Int,
    receiverId: Int,
    text: String,
    datetime: Long,
  ) derives ReadWriter

  case class MessageReply(
    sharedElementId: Int,
    senderId: Int,
    receiverId: Int,
    text: String,
    datetime: Long,
  )  derives ReadWriter

  case class ButtonLog(
    userId: Int,
    buttonId: String,
    datetime: Long,
  ) derives ReadWriter

  private val profileViewEndpoint = endpoint.get
    .in("profile" / "view" / path[Int]("userId"))
    .errorOut(stringBody)
    .out(jsonBody[FullProfile])

  private val profileEditEndpoint = endpoint.put
    .in("profile" / "edit" / path[Int]("userId"))
    .in(jsonBody[FullProfile])
    .errorOut(stringBody)
    .out(emptyOutput) /// TODO: or do we want something?

  private val imageUploadEndpoint = endpoint.post
    .in("image" / "upload")
    .in(multipartBody[UploadRequest])
    .errorOut(stringBody)
    .out(jsonBody[UploadResponse])

  private val signUpEndpoint = endpoint.post
    .in("auth" / path[String]("username"))
    .errorOut(stringBody)
    .out(jsonBody[NewUserResponse])

  private val loginEndpoint = endpoint.get
    .in("auth" / path[String]("username"))
    .errorOut(stringBody)
    .out(jsonBody[LoginResponse])

  private val buttonLogEndpoint = endpoint.post
    .in("debug" / "button-click")
    .in(jsonBody[ButtonLog])

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
      userId = user.accountId,
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
        request.fromApi(accountId = userId),
        request.wallTextboxes.map(_.fromApi),
        request.wallImages.map(_.fromApi),
        request.wallStickers.map(_.fromApi),
      )
    }
  )

  private val imageUploadRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    imageUploadEndpoint.serverLogic { request =>
      IO.blocking {
        imageservice.uploadImage(request.image.body)
      }.attempt.map {
        case Right(Some(imageUploaderAPI.ImageURL(url))) => Right(UploadResponse(url))
        case Right(None) => Left("Error in image upload")
        case Left(err)  => Left(err.getMessage)
      }
    }
  )

  private val signUpRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    signUpEndpoint.serverLogic { username =>
      val newUserId: IO[Either[Throwable, Int]] = repo.newUser(username)
      newUserId.map { _ match {
          case Left(err: SqlException) => Left(
            s"Error inserting new user with username ${username}. Perhaps this user already exists.\n${err.toString}"
          )
          case Left(err) => Left(err.getMessage)
          case Right(userId) => Right(NewUserResponse(userId))
      }}
    }
  )

  private val loginRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    loginEndpoint.serverLogic { username =>
      val userId: IO[Either[Throwable, Int]] = repo.getUser(username)
      userId.map { _ match {
          case Left(err: SqlException) => Left(
            s"Error getting userId from username ${username}. User might not exist.\n${err.toString}"
          )
          case Left(err) => Left(err.getMessage)
          case Right(userId) => Right(LoginResponse(userId))
      }}
    }
  )

  private val sharedBoardRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    sharedBoardEndpoint.serverLogic { (user1Id, user2Id) =>
      repo.getSharedBoard(user1Id, user2Id).map(_.toRight(()))
    }
  )

  private def messageTextRoutes(topic: Topic[IO, (Int, Int)]) = serverInterpreter.toRoutes(
    messageTextEndpoint.serverLogicSuccess { message =>
      repo.sendTextMessage(message) >> publishMessage(topic, message.senderId, message.receiverId)
    }
  )

  private def messageImageRoutes(topic: Topic[IO, (Int, Int)]) = serverInterpreter.toRoutes(
    messageImageEndpoint.serverLogicSuccess { message =>
      repo.sendImageMessage(message) >> publishMessage(topic, message.senderId, message.receiverId)
    }
  )

  private def messageReplyRoutes(topic: Topic[IO, (Int, Int)]) = serverInterpreter.toRoutes(
    messageReplyEndpoint.serverLogicSuccess { message =>
      repo.sendReply(message) >> publishMessage(topic, message.senderId, message.receiverId)
    }
  )

  private def publishMessage(topic: Topic[IO, (Int, Int)], senderId: Int, receiverId: Int) = {
    topic.publish1((senderId, receiverId)).as(())
  }

  private def messageListenSseRoutes(topic: Topic[IO, (Int, Int)]) = serverInterpreter.toRoutes(
    messageListenSseEndpoint.serverLogicSuccess { receiverId =>
      IO.pure {
        topic.subscribeUnbounded
          .filter((id1, id2) => id1 == receiverId || id2 == receiverId)
          .map(_ => ServerSentEvent())
      }
    }
  )

  private val buttonLogRoutes: HttpRoutes[IO] = serverInterpreter.toRoutes(
    buttonLogEndpoint.serverLogic { case ButtonLog(userId, buttonId, datetime) => 
      repo.logButtonPress(userId, buttonId, datetime)
    }
  )

  extension (image: repo.WallImage) {
    private def toApi = WallImage(
      url = image.url,
      position = image.position,
    )
  }

  extension (textbox: repo.WallTextbox) {
    private def toApi = WallTextbox(
      title = textbox.title,
      body = textbox.body,
      font = textbox.font,
      fontHexARGB = textbox.fontARGB,
      backgroundHexARGB = textbox.backgroundARGB,
      position = textbox.position,
    )
  }


  extension (sticker: WallSticker) {
    private def fromApi = repo.WallStickerCreatorBuilder(
      name = sticker.name,
      x = sticker.position.x,
      y = sticker.position.y,
      rotation = sticker.position.rotation,
      aspectRatio = sticker.position.aspectRatio,
      scale = sticker.position.scale,
    )
  }

  extension (image: WallImage) {
    private def fromApi = repo.WallImageCreatorBuilder(
      url = image.url,
      x = image.position.x,
      y = image.position.y,
      rotation = image.position.rotation,
      aspectRatio = image.position.aspectRatio,
      scale = image.position.scale,
    )
  }
  
  extension (textbox: WallTextbox) {
    private def fromApi = repo.WallTextboxCreatorBuilder(
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
    private def fromApi(accountId: Int) = repo.ProfileCreator(
      accountId = accountId,
      name = profile.name,
      location = profile.location,
      bio = profile.bio,
      age = profile.age,
      profileImageUrl = profile.profileImageUrl,
      wallBackgroundHexARGB = profile.wallBackgroundHexARGB,
    )
  }

  extension (sticker: repo.WallSticker) {
    private def toApi = WallSticker(
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

  def router(topic: Topic[IO, (Int, Int)]) = Router(
    "/" -> loginRoutes,
    "/" -> signUpRoutes,
    "/" -> recommendationsRoutes,
    "/" -> profileViewRoutes,
    "/" -> profileEditRoutes,
    "/" -> imageUploadRoutes,
    "/" -> sharedBoardRoutes,
    "/" -> messageTextRoutes(topic),
    "/" -> messageImageRoutes(topic),
    "/" -> messageReplyRoutes(topic),
    "/" -> messageListenSseRoutes(topic),
    "/" -> buttonLogRoutes,
  ).orNotFound
}
