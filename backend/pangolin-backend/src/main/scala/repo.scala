package pangolin

import cats.syntax.all.*
import cats.effect.IO
import com.augustnagro.magnum.{
  DbCodec,
  Id,
  PostgresDbType,
  Repo,
  Spec,
  Table,
  TableInfo,
  connect, transact,
  sql,
}
import io.github.cdimascio.dotenv.Dotenv
import org.postgresql.ds.PGSimpleDataSource
import com.augustnagro.magnum.DbCon

object repo {

  trait Positioned {
    val x: Int
    val y: Int
    val rotation: Double
    val aspectRatio: Double
    val scale: Double
  }

  case class ProfileImageCreator(
      profileId: Int,
      url: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class ProfileImage(
      @Id id: Int,
      profileId: Int,
      url: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object ProfileImage {
    val Table = TableInfo[ProfileImageCreator, ProfileImage, Int]
  }

  case class ProfileTextboxCreator(
      profileId: Int,
      title: String,
      body: String,
      font: Option[String],
      fontARGB: Long,
      backgroundARGB: Long,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class ProfileTextbox(
      @Id id: Int,
      profileId: Int,
      title: String,
      body: String,
      font: Option[String],
      fontARGB: Long,
      backgroundARGB: Long,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object ProfileTextbox {
    val Table = TableInfo[ProfileTextboxCreator, ProfileTextbox, Int]
  }

  case class ProfileStickerCreator(
      profileId: Int,
      name: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class ProfileSticker(
      @Id id: Int,
      profileId: Int,
      name: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object ProfileSticker {
    val Table = TableInfo[ProfileStickerCreator, ProfileSticker, Int]
  }

  /// We should really just make this a deriving type.
  /// god I hate my code.
  case class ProfileImageCreatorBuilder (
    url: String,
    x: Int,
    y: Int,
    rotation: Double,
    aspectRatio: Double,
    scale: Double,
  ) {
    def build(profileId: Int) = ProfileImageCreator(
      profileId = profileId,
      url = url,
      x = x,
      y = y,
      rotation = rotation,
      aspectRatio = aspectRatio,
      scale = scale,
    )
  }
  case class ProfileTextboxCreatorBuilder(
    title: String,
    body: String,
    font: Option[String],
    fontARGB: Long,
    backgroundARGB: Long,
    x: Int,
    y: Int,
    rotation: Double,
    aspectRatio: Double,
    scale: Double,
  ) {
    def build(profileId: Int) = ProfileTextboxCreator(
      profileId = profileId,
      title = title,
      body = body,
      font = font,
      fontARGB = fontARGB,
      backgroundARGB = backgroundARGB,
      x = x,
      y = y,
      rotation = rotation,
      aspectRatio = aspectRatio,
      scale = scale,
    )
  }
  case class ProfileStickerCreatorBuilder (
    name: String,
    x: Int,
    y: Int,
    rotation: Double,
    aspectRatio: Double,
    scale: Double,
  ) {
    def build(profileId: Int) = ProfileStickerCreator(
      profileId = profileId,
      name = name,
      x = x,
      y = y,
      rotation = rotation,
      aspectRatio = aspectRatio,
      scale = scale,
    )
  }


  case class ProfileCreator(
      accountId: Int,
      name: String,
      location: String,
      bio: String,
      wallBackgroundHexARGB: Long,
      profileImageUrl: String,
      age: Int,
  ) derives DbCodec {
    def toProfile(profileId: Int): Profile = Profile(
      id = profileId,
      accountId = accountId,
      name = name,
      location = location,
      bio = bio,
      wallBackgroundHexARGB = wallBackgroundHexARGB,
      profileImageUrl = profileImageUrl,
      age = age,
    )
  }

  @Table(PostgresDbType)
  case class Profile(
      @Id id: Int,
      accountId: Int,
      name: String,
      location: String,
      bio: String,
      wallBackgroundHexARGB: Long,
      profileImageUrl: String,
      age: Int,
  ) derives DbCodec

  object Profile {
    val Table = TableInfo[ProfileCreator, Profile, Int]
  }

  case class AccountCreator(
      username: String,
  ) derives DbCodec

  @Table(PostgresDbType)
  case class Account(
      @Id id: Int,
      username: String,
  ) derives DbCodec

  object Account {
    val Table = TableInfo[AccountCreator, Account, Int]
  }
  
  case class SharedBoardCreator(
    user1Id: Int,
    user2Id: Int,
  )

  @Table(PostgresDbType)
  case class SharedBoard(
    @Id id: Int,
    user1Id: Int,
    user2Id: Int,
  ) derives DbCodec

  object SharedBoard {
    val Table = TableInfo[SharedBoardCreator, SharedBoard, Int]
  }

  case class SharedBoardElementCreator(
    boardId: Int,
    timestamp: Long,
    url: Option[String],
    text: Option[String],
    senderId: Int,
    read: Boolean,
  )

  @Table(PostgresDbType)
  case class SharedBoardElement(
    @Id id: Int,
    boardId: Int,
    url: Option[String],
    text: Option[String],
    timestamp: Long,
    senderId: Int,
    read: Boolean,
  ) derives DbCodec

  object SharedBoardElement {
    val Table = TableInfo[SharedBoardElementCreator, SharedBoardElement, Int]
  }

  case class SharedBoardReplyCreator(
    sharedBoardElementId: Int,
    text: String,
    timestamp: Long,
    senderId: Int,
    read: Boolean,
  )

  @Table(PostgresDbType)
  case class SharedBoardReply(
    @Id id: Int,
    sharedBoardElementId: Int,
    text: String,
    timestamp: Long,
    senderId: Int,
    read: Boolean,
  )

  object SharedBoardReply {
    val Table = TableInfo[SharedBoardReplyCreator, SharedBoardReply, Int]
  }

  case class ButtonLogCreator(
    userId: Int,
    buttonId: String,
    pressTimestamp: Long,
  )

  @Table(PostgresDbType)
  case class ButtonLog(
    @Id id: Int,
    userId: Int,
    buttonId: String,
    pressTimestamp: Long,
  )

  object ButtonLog {
    val table = TableInfo[ButtonLogCreator, ButtonLog, Int]
  }

  private val dataSource: javax.sql.DataSource = {
    val ds = PGSimpleDataSource()
    ds.setDatabaseName("pangolindb")
    ds.setUser("pangolindbuser")
    ds.setPassword(
      sys.env.getOrElse("DB_PASSWORD", Dotenv.load().get("DB_PASSWORD")),
    )
    ds.setPortNumber(5432)
    ds.setUrl(
      "jdbc:postgresql://dpg-d8cbgu3eo5us73eq2hl0-a.frankfurt-postgres.render.com/",
    )
    ds
  }


  private val profileImageRepo = Repo[ProfileImageCreator, ProfileImage, Int]
  private val profileTextboxRepo = Repo[ProfileTextboxCreator, ProfileTextbox, Int]
  private val profileStickerRepo = Repo[ProfileStickerCreator, ProfileSticker, Int]
 
  private val profileRepo = Repo[ProfileCreator, Profile, Int]
  private val accountRepo = Repo[AccountCreator, Account, Int]

  private val sharedBoardRepo = Repo[SharedBoardCreator, SharedBoard, Int]
  private val sharedBoardElementsRepo = Repo[SharedBoardElementCreator, SharedBoardElement, Int]
  private val sharedBoardReplyRepo = Repo[SharedBoardReplyCreator, SharedBoardReply, Int]

  private val buttonLogRepo = Repo[ButtonLogCreator, ButtonLog, Int]

  private def userIdFromUsernameSpec(username: String) = Spec[Account]
    .where(sql"${Account.Table.username} = $username")

  private def profileImagesSpec(profileId: Int) = Spec[ProfileImage]
    .where(sql"${ProfileImage.Table.profileId} = $profileId")

  private def profileTextboxesSpec(profileId: Int) = Spec[ProfileTextbox]
    .where(sql"${ProfileTextbox.Table.profileId} = $profileId")

  private def profileStickersSpec(profileId: Int) = Spec[ProfileSticker]
    .where(sql"${ProfileSticker.Table.profileId} = $profileId")

  val getRecommendations = inDatabase {
    profileRepo.findAll.asRight
  }

  /// Yes, this should be a much better query. Believe in the power of query optimisation!
  def getProfile(accountId: Int) = inDatabaseWithRollback {
    getProfileIdFromUserId(accountId) match {
      case None => Left("Could not find a profile for the given accoundId")
      case Some(profileId) => profileRepo
        .findById(profileId)
        .map { profile =>
          val images = profileImageRepo.findAll(profileImagesSpec(profileId))
          val textboxes =
            profileTextboxRepo.findAll(profileTextboxesSpec(profileId))
          val stickers =
            profileStickerRepo.findAll(profileStickersSpec(profileId))
          (profile, images, textboxes, stickers)
        }
        .toRight(s"error getting profile information from profileId $profileId")
    }
  }

  def newUser(username: String): IO[Either[Throwable, Int]] = inDatabaseWithRollback {
    try {
      accountRepo.insertReturning(AccountCreator(
      username = username
      )).id.asRight
    } catch {
      case e => Left(e) // I have no idea what sort of error gets thrown
    }
  }

  def getUser(username: String): IO[Either[Throwable, Int]] = inDatabaseWithRollback {
    try {
      accountRepo.findAll(userIdFromUsernameSpec(username)).head.id.asRight
    } catch {
      case e => Left(e) // I have no idea what sort of error gets thrown
    }
  }

  private def removeBySpec[EC, E, I](table: Repo[EC, E, I], spec: Spec[E], getId: E => I)(using DbCon)
    = table.deleteAllById(table.findAll(spec).map(getId))
    
  private def addAll[EC, E, I](table: Repo[EC, E, I])(elems: Iterable[EC])(using DbCon)
    = table.insertAll(elems)

  private def removeTextboxes(profileId: Int)(using DbCon) = removeBySpec(profileTextboxRepo, profileTextboxesSpec(profileId), _.id)
  private def removeImages(profileId: Int)(using DbCon) = removeBySpec(profileImageRepo, profileImagesSpec(profileId), _.id)
  private def removeStickers(profileId: Int)(using DbCon) = removeBySpec(profileStickerRepo, profileStickersSpec(profileId), _.id)
  private def addTextboxes(using DbCon) = addAll(profileTextboxRepo)
  private def addImages(using DbCon) = addAll(profileImageRepo)
  private def addStickers(using DbCon) = addAll(profileStickerRepo)

  private def getProfileIdFromUserId(accountId: Int)(using DbCon): Option[Int] = sql"""
    SELECT ${Profile.Table.id}
      FROM ${Profile.Table}
    WHERE ${Profile.Table.accountId} = $accountId
    LIMIT 1
  """.query[Int].run().headOption

  /// TODO: actually write out the sql for this. will be nicer than the hell below.
  // def updateProfileByAccountId(accountId: Int)(using DbCon) = sql"""
  //   UPDATE
  // """.query[Unit].run()

  def updateFullProfile(
        profileCreator: ProfileCreator,
        textboxCreators: Iterable[ProfileTextboxCreatorBuilder],
        imageCreators: Iterable[ProfileImageCreatorBuilder],
        stickerCreators: Iterable[ProfileStickerCreatorBuilder],
  ) = repo.inDatabaseWithRollback {
    val profileId: Option[Int] = getProfileIdFromUserId(profileCreator.accountId)
    profileId match {
      case Some(pid) => {
        /// TODO: change this so its plain sql!!
        repo.profileRepo.update(profileCreator.toProfile(pid))
        repo.removeTextboxes(pid)
        repo.addTextboxes(textboxCreators.map(_.build(pid)))
        repo.removeImages(pid)
        repo.addImages(imageCreators.map(_.build(pid)))
        repo.removeStickers(pid)
        repo.addStickers(stickerCreators.map(_.build(pid)))
        Right(())
        /// TODO: obviously this is the jankiest most disgusting code ever
        /// but apparently it makes the frontend easier so we will leave as-is for now
        /// (because the frontend can't use our element ids. doesn't help that we have an ugly DB structure)  
      }
      case None => Left("No profileId matches the given accountId. No profile to update.")
    }
  }

  def newSharedBoard(user1Id: Int, user2Id: Int) = inDatabase {
    sharedBoardRepo.insert(SharedBoardCreator(user1Id, user2Id))
  }

  def getSharedBoard(user1Id: Int, user2Id: Int) = {
    inDatabase {
      val elements = sharedBoardRepo.findAll(boardSpec(user1Id, user2Id)).headOption.map { sharedBoard =>
        sharedBoardElementsRepo.findAll(elementsSpec(sharedBoard.id)).map { element =>
          val replies = sharedBoardReplyRepo.findAll(repliesSpec(element.id)).map { reply =>
            api.SharedBoardReply(
              datetime = reply.timestamp,
              senderId = reply.senderId,
              text = reply.text,
            )
          }
          api.SharedBoardElement(
            sharedElemId = element.id,
            datetime = element.timestamp,
            messages = replies,
            url = element.url,
            text = element.text,
            read = element.read,
          )
        }
      }
      elements.map(api.SharedBoard(_))
    }
  }

  private def boardSpec(user1Id: Int, user2Id: Int) = Spec[SharedBoard].where(sql"${SharedBoard.Table.user1Id} = $user1Id AND ${SharedBoard.Table.user2Id} = $user2Id OR ${SharedBoard.Table.user1Id} = $user2Id AND ${SharedBoard.Table.user2Id} = $user1Id")
  private def elementsSpec(sharedBoardId: Int) = Spec[SharedBoardElement].where(sql"${SharedBoardElement.Table.boardId} = $sharedBoardId")
  private def repliesSpec(elementId: Int) = Spec[SharedBoardReply].where(sql"${SharedBoardReply.Table.sharedBoardElementId} = $elementId")

  def sendImageMessage(message: api.MessageImage): IO[Unit] = sendElement(
    senderId = message.senderId,
    receiverId = message.receiverId,
    timestamp = message.datetime,
    text = None,
    url = Some(message.url)
  )

  def sendTextMessage(message: api.MessageText): IO[Unit] = sendElement(
    senderId = message.senderId,
    receiverId = message.receiverId,
    timestamp = message.datetime,
    text = Some(message.text),
    url = None
  )

  private def sendElement(senderId: Int, receiverId: Int, timestamp: Long, text: Option[String], url: Option[String])(using (text.type, url.type) <:< ((Some[String], None.type) | (None.type, Some[String]))) = inDatabase {
    val board = getBoard(senderId, receiverId).getOrElse(insertBoard(senderId, receiverId))
    sharedBoardElementsRepo.insert(
      SharedBoardElementCreator(
        boardId = board.id,
        timestamp = timestamp,
        url = url,
        text = text,
        senderId = senderId,
        read = false,
      )
    )
  }

  def sendReply(message: api.MessageReply) = inDatabase {
    sharedBoardReplyRepo.insert(
      SharedBoardReplyCreator(
        sharedBoardElementId = message.sharedElementId,
        text = message.text,
        timestamp = message.datetime,
        senderId = message.senderId,
        read = false,
      )
    )
  }

  private def getBoard(user1Id: Int, user2Id: Int)(using DbCon): Option[SharedBoard] = {
    sharedBoardRepo.findAll(boardSpec(user1Id, user2Id)).headOption
  }

  private def insertBoard(user1Id: Int, user2Id: Int)(using DbCon): SharedBoard = {
    sharedBoardRepo.insertReturning(SharedBoardCreator(user1Id, user2Id))
  }

  def newSharedBoard(user1Id: Int, user2Id: Int) = inDatabase {
    sharedBoardRepo.insert(SharedBoardCreator(user1Id, user2Id))
  }

  def getSharedBoard(user1Id: Int, user2Id: Int) = {
    inDatabase {
      val elements = sharedBoardRepo.findAll(boardSpec(user1Id, user2Id)).headOption.map { sharedBoard =>
        sharedBoardElementsRepo.findAll(elementsSpec(sharedBoard.id)).map { element =>
          val replies = sharedBoardReplyRepo.findAll(repliesSpec(element.id)).map { reply =>
            api.SharedBoardReply(
              datetime = reply.timestamp,
              senderId = reply.senderId,
              text = reply.text,
            )
          }
          api.SharedBoardElement(
            sharedElemId = element.id,
            datetime = element.timestamp,
            messages = replies,
            url = element.url,
            text = element.text,
            read = element.read,
          )
        }
      }
      elements.map(api.SharedBoard(_))
    }
  }

  private def boardSpec(user1Id: Int, user2Id: Int) = Spec[SharedBoard].where(sql"${SharedBoard.Table.user1Id} = $user1Id AND ${SharedBoard.Table.user2Id} = $user2Id OR ${SharedBoard.Table.user1Id} = $user2Id AND ${SharedBoard.Table.user2Id} = $user1Id")
  private def elementsSpec(sharedBoardId: Int) = Spec[SharedBoardElement].where(sql"${SharedBoardElement.Table.boardId} = $sharedBoardId")
  private def repliesSpec(elementId: Int) = Spec[SharedBoardReply].where(sql"${SharedBoardReply.Table.sharedBoardElementId} = $elementId")

  def sendImageMessage(message: api.MessageImage): IO[Unit] = sendElement(
    senderId = message.senderId,
    receiverId = message.receiverId,
    timestamp = message.datetime,
    text = None,
    url = Some(message.url)
  )

  def sendTextMessage(message: api.MessageText): IO[Unit] = sendElement(
    senderId = message.senderId,
    receiverId = message.receiverId,
    timestamp = message.datetime,
    text = Some(message.text),
    url = None
  )

  private def sendElement(senderId: Int, receiverId: Int, timestamp: Long, text: Option[String], url: Option[String])(using (text.type, url.type) <:< ((Some[String], None.type) | (None.type, Some[String]))) = inDatabase {
    val board = getBoard(senderId, receiverId).getOrElse(insertBoard(senderId, receiverId))
    sharedBoardElementsRepo.insert(
      SharedBoardElementCreator(
        boardId = board.id,
        timestamp = timestamp,
        url = url,
        text = text,
        senderId = senderId,
        read = false,
      )
    )
  }

  def sendReply(message: api.MessageReply) = inDatabase {
    sharedBoardReplyRepo.insert(
      SharedBoardReplyCreator(
        sharedBoardElementId = message.sharedElementId,
        text = message.text,
        timestamp = message.datetime,
        senderId = message.senderId,
        read = false,
      )
    )
  }

  private def getBoard(user1Id: Int, user2Id: Int)(using DbCon): Option[SharedBoard] = {
    sharedBoardRepo.findAll(boardSpec(user1Id, user2Id)).headOption
  }

  private def insertBoard(user1Id: Int, user2Id: Int)(using DbCon): SharedBoard = {
    sharedBoardRepo.insertReturning(SharedBoardCreator(user1Id, user2Id))
  }

  private def inDatabase[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    connect(dataSource) {
      f
    }
  }

  private def inDatabaseWithRollback[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    transact(dataSource) {
      f
      // rolls back when f throws an error
      // oh how I wish we had a nice lil effect system to indicate error thowing
    }
  }
}


