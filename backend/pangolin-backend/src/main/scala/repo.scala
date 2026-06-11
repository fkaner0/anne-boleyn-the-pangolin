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
  DbCon
}
import io.github.cdimascio.dotenv.Dotenv
import org.postgresql.ds.PGSimpleDataSource
// import org.postgresql.geometric.*
import com.augustnagro.magnum.pg.PgCodec.given
import com.augustnagro.magnum.SortOrder

object repo {

  trait Positioned {
    val x: Int
    val y: Int
    val rotation: Double
    val aspectRatio: Double
    val scale: Double
  }

  case class WallImageCreator(
      profileId: Int,
      url: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class WallImage(
      @Id id: Int,
      profileId: Int,
      url: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object WallImage {
    val Table = TableInfo[WallImageCreator, WallImage, Int]
  }

  case class WallTextboxCreator(
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
  case class WallTextbox(
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

  object WallTextbox {
    val Table = TableInfo[WallTextboxCreator, WallTextbox, Int]
  }

  case class WallStickerCreator(
      profileId: Int,
      name: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  @Table(PostgresDbType)
  case class WallSticker(
      @Id id: Int,
      profileId: Int,
      name: String,
      x: Int,
      y: Int,
      rotation: Double,
      aspectRatio: Double,
      scale: Double,
  ) extends Positioned derives DbCodec

  object WallSticker {
    val Table = TableInfo[WallStickerCreator, WallSticker, Int]
  }

  /// We should really just make this a deriving type.
  /// god I hate my code.
  case class WallImageCreatorBuilder (
    url: String,
    x: Int,
    y: Int,
    rotation: Double,
    aspectRatio: Double,
    scale: Double,
  ) {
    def build(profileId: Int) = WallImageCreator(
      profileId = profileId,
      url = url,
      x = x,
      y = y,
      rotation = rotation,
      aspectRatio = aspectRatio,
      scale = scale,
    )
  }
  case class WallTextboxCreatorBuilder(
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
    def build(profileId: Int) = WallTextboxCreator(
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
  case class WallStickerCreatorBuilder (
    name: String,
    x: Int,
    y: Int,
    rotation: Double,
    aspectRatio: Double,
    scale: Double,
  ) {
    def build(profileId: Int) = WallStickerCreator(
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
  
  @Table(PostgresDbType)
  case class UserHobbyInfo(
    @Id id: Int,
    accountId: Int,
    hobby: String,
    passionLevel: Double,
    subInterests: Vector[String],
    otherInterests: Vector[String],
  ) derives DbCodec
  case class UserHobbyInfoCreator(
    accountId: Int,
    hobby: String,
    passionLevel: Double,
    subInterests: Vector[String],
    otherInterests: Vector[String],
  ) derives DbCodec

  object UserHobbyInfo {
    val Table = TableInfo[UserHobbyInfoCreator, UserHobbyInfo, Int]
  }
  
  /// MESSAGING BOARDS ///

  case class ConnectionRemovedCreator(
    boardId: Int,
    removedByUser: Int, // user id
    reason: String,
  )

  @Table(PostgresDbType)
  case class ConnectionRemoved(
    @Id id: Int,
    boardId: Int,
    removedByUser: Int, // user id
    // reason should be an enum really. haven't decided what goes in it yet tho
    reason: String,
  )

  object ConnectionRemoved {
    val Table = TableInfo[ConnectionRemovedCreator, ConnectionRemoved, Int]
  }

  case class ConnectionPendingCreator(
    boardId: Int,
    pendingForUser: Int, // user id
  )

  @Table(PostgresDbType)
  case class ConnectionPending(
    @Id id: Int,
    boardId: Int,
    pendingForUser: Int, // user id
  )

  object ConnectionPending {
    val Table = TableInfo[ConnectionPendingCreator, ConnectionPending, Int]
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
    read: Boolean = false,
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
    username: String,
    name: String,
  )

  @Table(PostgresDbType)
  case class ButtonLog(
    @Id id: Int,
    userId: Int,
    buttonId: String,
    pressTimestamp: Long,
    username: String,
    name: String,
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


  private val profileImageRepo = Repo[WallImageCreator, WallImage, Int]
  private val profileTextboxRepo = Repo[WallTextboxCreator, WallTextbox, Int]
  private val profileStickerRepo = Repo[WallStickerCreator, WallSticker, Int]
 
  private val profileRepo = Repo[ProfileCreator, Profile, Int]
  private val userHobbyInfoRepo = Repo[UserHobbyInfoCreator, UserHobbyInfo, Int]
  private val accountRepo = Repo[AccountCreator, Account, Int]

  private val connectionPendingRepo = Repo[ConnectionPendingCreator, ConnectionPending, Int]
  private val connectionRemovedRepo = Repo[ConnectionRemovedCreator, ConnectionRemoved, Int]

  private val sharedBoardRepo = Repo[SharedBoardCreator, SharedBoard, Int]
  private val sharedBoardElementRepo = Repo[SharedBoardElementCreator, SharedBoardElement, Int]
  private val sharedBoardReplyRepo = Repo[SharedBoardReplyCreator, SharedBoardReply, Int]

  private val buttonLogRepo = Repo[ButtonLogCreator, ButtonLog, Int]

  private def userIdFromUsernameSpec(username: String) = Spec[Account]
    .where(sql"${Account.Table.username} = $username")

  private def profileImagesSpec(profileId: Int) = Spec[WallImage]
    .where(sql"${WallImage.Table.profileId} = $profileId")

  private def profileTextboxesSpec(profileId: Int) = Spec[WallTextbox]
    .where(sql"${WallTextbox.Table.profileId} = $profileId")

  private def profileStickersSpec(profileId: Int) = Spec[WallSticker]
    .where(sql"${WallSticker.Table.profileId} = $profileId")

  private def userHobbyInfoSpec(accountId: Int) = Spec[UserHobbyInfo]
    .where(sql"${UserHobbyInfo.Table.accountId} = $accountId")

  val getRecommendations = inDatabase {
    profileRepo.findAll.asRight
  }

  /// Yes, this should be a much better query. Believe in the power of query optimisation!
  def getProfile(
    accountId: Int
  ): IO[Either[String, (Profile, UserHobbyInfo, Vector[WallImage], Vector[WallTextbox], Vector[WallSticker])]] =
    inDatabaseWithRollback {
      for {
        profileId <- getProfileIdFromUserId(accountId).toRight("Could not find a profile for the given accountId")
        profile <- profileRepo.findById(profileId).toRight(s"Could not find profile for profileId $profileId")
        images = profileImageRepo.findAll(profileImagesSpec(profileId = profileId))
        textboxes = profileTextboxRepo.findAll(profileTextboxesSpec(profileId = profileId))
        stickers = profileStickerRepo.findAll(profileStickersSpec(profileId = profileId))
        userHobbyInfo = userHobbyInfoRepo.findAll(userHobbyInfoSpec(accountId = accountId)).headOption
        hobbyInfo <- userHobbyInfo.toRight("Could not find hobby info for the given accountId")
      } yield (profile, hobbyInfo, images, textboxes, stickers)
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

  private def removeHobbyInfo(accountId: Int)(using DbCon) = removeBySpec(userHobbyInfoRepo, userHobbyInfoSpec(accountId), _.id)
  private def addHobbyInfo(uhiCreator: UserHobbyInfoCreator)(using DbCon) = userHobbyInfoRepo.insert(uhiCreator)

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

  private def updateWallElements(
    profileId: Int,
    textboxCreators: Iterable[WallTextboxCreatorBuilder],
    imageCreators: Iterable[WallImageCreatorBuilder],
    stickerCreators: Iterable[WallStickerCreatorBuilder],
  )(using DbCon) = {
    repo.removeTextboxes(profileId)
    repo.addTextboxes(textboxCreators.map(_.build(profileId)))
    repo.removeImages(profileId)
    repo.addImages(imageCreators.map(_.build(profileId)))
    repo.removeStickers(profileId)
    repo.addStickers(stickerCreators.map(_.build(profileId)))
    Right(())
    /// TODO: obviously this is the jankiest most disgusting code ever
    /// but apparently it makes the frontend easier so we will leave as-is for now
    /// (because the frontend can't use our element ids. doesn't help that we have an ugly DB structure)  
  }

  private def updateHobbyInfo(
    userHobbyInfoCreator: UserHobbyInfoCreator,
  )(using DbCon) = {
    repo.removeHobbyInfo(userHobbyInfoCreator.accountId)
    repo.addHobbyInfo(userHobbyInfoCreator)
  }

  def updateFullProfile(
        profileCreator: ProfileCreator,
        userHobbyInfoCreator: UserHobbyInfoCreator,
        textboxCreators: Iterable[WallTextboxCreatorBuilder],
        imageCreators: Iterable[WallImageCreatorBuilder],
        stickerCreators: Iterable[WallStickerCreatorBuilder],
  ) = inDatabaseWithRollback {
    val profileId: Option[Int] = getProfileIdFromUserId(profileCreator.accountId)
    profileId match {
      case Some(pid) => {
        /// TODO: change this so its plain sql!!
        repo.profileRepo.update(profileCreator.toProfile(pid))
        updateWallElements(pid, textboxCreators, imageCreators, stickerCreators)
        updateHobbyInfo(userHobbyInfoCreator)
      }
      case None => {
        /// profile doesn't exist yet, so create a new one.
        val pid = repo.profileRepo.insertReturning(profileCreator).id
        updateWallElements(pid, textboxCreators, imageCreators, stickerCreators)
        repo.userHobbyInfoRepo.insert(userHobbyInfoCreator)
      }
    }
    Right(())
  }

  def newSharedBoard(user1Id: Int, user2Id: Int) = inDatabase {
    sharedBoardRepo.insert(SharedBoardCreator(user1Id, user2Id))
  }

  def getSharedBoard(user1Id: Int, user2Id: Int) = inDatabase {
    val elements = sharedBoardRepo.findAll(boardSpec(user1Id, user2Id)).headOption.map { sharedBoard =>
      sharedBoardElementRepo.findAll(elementsSpec(sharedBoard.id)).map { element =>
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

  private def boardSpec(user1Id: Int, user2Id: Int) = Spec[SharedBoard]
    .where(sql"${SharedBoard.Table.user1Id} = $user1Id AND ${SharedBoard.Table.user2Id} = $user2Id OR ${SharedBoard.Table.user1Id} = $user2Id AND ${SharedBoard.Table.user2Id} = $user1Id")
  private def elementsSpec(sharedBoardId: Int) = Spec[SharedBoardElement]
    .where(sql"${SharedBoardElement.Table.boardId} = $sharedBoardId")
    .orderBy(SharedBoardElement.Table.timestamp.queryRepr, SortOrder.Asc)
  private def repliesSpec(elementId: Int) = Spec[SharedBoardReply]
    .where(sql"${SharedBoardReply.Table.sharedBoardElementId} = $elementId")
    .orderBy(SharedBoardReply.Table.timestamp.queryRepr, SortOrder.Asc)

  def sendImageMessage(message: api.MessageImage): IO[Unit] = sendElement(
    senderId = message.senderId,
    receiverId = message.receiverId,
    timestamp = message.datetime,
    message = message.message,
    text = None,
    url = Some(message.url)
  )

  def sendTextMessage(message: api.MessageText): IO[Unit] = sendElement(
    senderId = message.senderId,
    receiverId = message.receiverId,
    timestamp = message.datetime,
    message = message.message,
    text = Some(message.text),
    url = None
  )

  private def removeAnyPending(boardId: Int, userId: Int)(using DbCon) =
    val pending = ConnectionPending.Table 
    sql"""
    DELETE FROM ${pending}
    WHERE ${pending.boardId} = ${boardId}
      AND ${pending.pendingForUser} = ${userId}
    """.update.run()

  private def sendElement(
    senderId: Int, receiverId: Int, timestamp: Long, text: Option[String], url: Option[String], message: String
  )(using (text.type, url.type) <:< ((Some[String], None.type) | (None.type, Some[String]))
  ) = inDatabaseWithRollback {
    val board = getBoard(senderId, receiverId) match {
      case Some(b) => {
        // holy side effect
        removeAnyPending(b.id, senderId)
        b
      }
      case None => makeBoard(senderId, receiverId)
    }
    val elem = sharedBoardElementRepo.insertReturning(
      SharedBoardElementCreator(
        boardId = board.id,
        timestamp = timestamp,
        url = url,
        text = text,
        senderId = senderId,
        read = false,
      )
    )
    sharedBoardReplyRepo.insert(SharedBoardReplyCreator(
        sharedBoardElementId = elem.id,
        text = message,
        timestamp = timestamp,
        senderId = senderId,
      )
    )
  }

  /// TODO: I THOUGHT WE SAID REPO SHLDNT KNOW ABOUT API? :<
  def sendReply(message: api.MessageReply): IO[Option[Unit]] = inDatabaseWithRollback {    
    sharedBoardElementRepo.findById(message.sharedElementId).map { (sharedElem) =>
      removeAnyPending(sharedElem.boardId, message.senderId)
      sharedBoardReplyRepo.insert(
        SharedBoardReplyCreator(
          sharedBoardElementId = message.sharedElementId,
          text = message.text,
          timestamp = message.datetime,
          senderId = message.senderId,
        )
      )
    }
  }

  private def getBoard(user1Id: Int, user2Id: Int)(using DbCon): Option[SharedBoard] = {
    sharedBoardRepo.findAll(boardSpec(user1Id, user2Id)).headOption
  }

  private def makeBoard(senderId: Int, receiverId: Int)(using DbCon): SharedBoard = {
    val newBoard = sharedBoardRepo.insertReturning(SharedBoardCreator(senderId, receiverId))
    connectionPendingRepo.insert(ConnectionPendingCreator(
      boardId = newBoard.id,
      pendingForUser = receiverId,
    ))
    newBoard
  }

  def logButtonPress(
    userId: Int,
    buttonId: String,
    pressTimestamp: Long,
  ) = inDatabase { for {
    account <- accountRepo.findById(userId).toRight("couldn't find account")
    name <- profileRepo.findAll(Spec[Profile].where(sql"${Profile.Table.accountId} = $userId")).headOption.toRight("couldn't find name")
  } yield buttonLogRepo.insert(
      ButtonLogCreator(
        userId = userId,
        username = account.username,
        name = name.name,
        buttonId = buttonId,
        pressTimestamp = pressTimestamp,
      )
    )
  }

  /// TODO: I THOUGHT WE SAID REPO SHLDNT KNOW ABOUT API? :<
  def getCurrentFriends(userId: Int): IO[Option[(Vector[api.Friend], Int)]] = inDatabase {
    val sharedBoards = sharedBoardRepo.findAll(currentFriendsSpec(userId))
    val friends = sharedBoards.map { case SharedBoard(boardId, user1Id, user2Id) =>
      val friendId = if user1Id == userId then user2Id else user1Id
      val coverImages = sharedBoardElementRepo.findAll(coverImagesSpec(boardId))
      for {
        friendProfile <- profileRepo.findAll(profileFromAccountIdSpec(friendId)).headOption
        coverImageUrls <- coverImages.map(_.url).sequence
      } yield api.Friend(
        friendUserId = friendProfile.accountId,
        name = friendProfile.name,
        coverImages = coverImageUrls,
        mainImage = friendProfile.profileImageUrl,
      )
    }.collect {
      case Some(x) => x
    }
    for {
      nPending <- numberPendingFriends(userId).headOption
    } yield (friends, nPending)
  }

  /// TODO: I THOUGHT WE SAID REPO SHLDNT KNOW ABOUT API? :<
  def getPendingFriends(userId: Int): IO[Vector[api.PendingFriend]] = inDatabase {
    val sharedBoards = sharedBoardRepo.findAll(pendingFriendsSpec(userId))
    sharedBoards.map { case SharedBoard(boardId, user1Id, user2Id) =>
      val friendId = if user1Id == userId then user2Id else user1Id
      val coverImages = sharedBoardElementRepo.findAll(coverImagesSpec(boardId))
      for {
        friendProfile <- profileRepo.findAll(profileFromAccountIdSpec(friendId)).headOption
        coverImageUrls <- coverImages.map(_.url).sequence
      } yield api.PendingFriend(
        friendUserId = friendProfile.accountId,
        name = friendProfile.name,
        mainImage = friendProfile.profileImageUrl,
        age = friendProfile.age,
        location = friendProfile.location,
        bio = friendProfile.bio,
      )
    }.collect {
      case Some(x) => x
    }
  }

  /// TODO: I THOUGHT WE SAID REPO SHLDNT KNOW ABOUT API? :<
  def removeFriend(currentUserId: Int, targetUserId: Int, reason: api.DeletionReason): IO[Option[Unit]] = inDatabase {
    getBoard(currentUserId, targetUserId).map{ (board) =>
      connectionRemovedRepo.insert(ConnectionRemovedCreator(
        boardId = board.id,
        removedByUser = currentUserId,
        reason = reason.dbString,
      ))
    }
  }

  private def currentFriendsSpec(userId: Int) =
    Spec[SharedBoard]
      .where(sql"""
        (${SharedBoard.Table.user1Id} = $userId OR ${SharedBoard.Table.user2Id} = $userId)
      AND ${SharedBoard.Table.id} NOT IN (
        SELECT ${ConnectionPending.Table.boardId} FROM ${ConnectionPending.Table} WHERE ${ConnectionPending.Table.pendingForUser} = $userId
        UNION
        SELECT ${ConnectionRemoved.Table.boardId} FROM ${ConnectionRemoved.Table} WHERE ${ConnectionRemoved.Table.removedByUser} = $userId
      )
    """)

  private def pendingFriendsSpec(userId: Int) =
    Spec[SharedBoard].where(sql"""
      (${SharedBoard.Table.user1Id} = $userId OR ${SharedBoard.Table.user2Id} = $userId)
      AND ${SharedBoard.Table.id} IN (
        SELECT ${ConnectionPending.Table.boardId} FROM ${ConnectionPending.Table} WHERE ${ConnectionPending.Table.pendingForUser} = $userId
      )
    """)
  
  private def numberPendingFriends(userId: Int)(using DbCon) = {
    val pending = ConnectionPending.Table.alias("cp")
    val sharedBoard = SharedBoard.Table.alias("sb")

    sql"""
    SELECT COUNT(*)
    FROM $pending
    LEFT JOIN $sharedBoard ON ${sharedBoard.id} = ${pending.boardId}
    WHERE ${pending.pendingForUser} = $userId
      AND (${sharedBoard.user1Id} = $userId OR ${sharedBoard.user2Id} = $userId)
    """.query[Int].run()
    // the 'AND' at the end is redundant if we make sure the database stays consistent
    // (clearly some poor db design. sorry.)
  }

  private def profileFromAccountIdSpec(userId: Int) = {
    Spec[Profile].where(sql"${Profile.Table.accountId} = $userId")
  }

  private def coverImagesSpec(boardId: Int) = {
    Spec[SharedBoardElement]
      .where(sql"${SharedBoardElement.Table.boardId} = $boardId")
      .where(sql"${SharedBoardElement.Table.url} IS NOT NULL")
      .orderBy(SharedBoardElement.Table.timestamp.queryRepr, SortOrder.Desc)
      .limit(4)
  }

  private def inDatabase[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    connect(dataSource)(f)
  }

  private def inDatabaseWithRollback[B](f: DbCon ?=> B): IO[B] = IO.blocking {
    transact(dataSource)(f)
  }
}


