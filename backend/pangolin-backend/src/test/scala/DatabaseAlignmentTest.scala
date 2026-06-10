package pangolin

import scala.deriving.Mirror
import scala.compiletime.{constValue, erasedValue}
import munit.FunSuite
import java.sql.DriverManager
import io.github.cdimascio.dotenv.Dotenv

// NB: these are entirely AI generated. They seem to test the right thing but be aware.
final class SchemaAlignmentTest extends FunSuite {

  private object CaseClassParams {

  inline def tupleLabels[T <: Tuple]: List[String] =
      inline erasedValue[T] match {
      case _: EmptyTuple => Nil
      case _: (h *: t) =>
          constValue[h].asInstanceOf[String] :: tupleLabels[t]
      }

  inline def constructorParamsOf[A](using m: Mirror.ProductOf[A]): List[String] =
      tupleLabels[m.MirroredElemLabels]
  }

  private val jdbcUrl =
    "jdbc:postgresql://dpg-d8cbgu3eo5us73eq2hl0-a.frankfurt-postgres.render.com/pangolindb"

  private val dbUser = "pangolindbuser"

  private val dbPassword =
    sys.env.getOrElse("DB_PASSWORD", Dotenv.load().get("DB_PASSWORD"))

  private def withConnection[A](f: java.sql.Connection => A): A = {
    val conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword)
    try f(conn)
    finally conn.close()
  }

  private def tableColumnsInOrder(tableName: String): List[String] =
    withConnection { conn =>
      val ps = conn.prepareStatement(
        """
          |select column_name
          |from information_schema.columns
          |where table_schema = 'public'
          |  and table_name = ?
          |order by ordinal_position
          |""".stripMargin
      )

      ps.setString(1, tableName)

      val rs = ps.executeQuery()
      val cols = scala.collection.mutable.ListBuffer.empty[String]

      while (rs.next()) {
        cols += rs.getString("column_name")
      }

      rs.close()
      ps.close()

      cols.toList
    }

  private def scalaNameToDbColumn(name: String): String =
    name.toLowerCase

  private inline def assertCaseClassMatchesTable[A <: Product](
    tableName: String
  )(using scala.deriving.Mirror.ProductOf[A]): Unit = {
    val dbColumns = tableColumnsInOrder(tableName)
    val constructorParams =
      CaseClassParams.constructorParamsOf[A].map(scalaNameToDbColumn)

    assertEquals(
      dbColumns,
      constructorParams,
      s"DB columns for table '$tableName' do not match constructor parameter order"
    )
  }

  test("Profile matches database column ordering") {
    assertCaseClassMatchesTable[repo.Profile]("profile")
  }

  test("Account matches database column ordering") {
    assertCaseClassMatchesTable[repo.Account]("account")
  }

  test("UserHobbyInfo matches database column ordering") {
    assertCaseClassMatchesTable[repo.UserHobbyInfo]("userhobbyinfo")
  }

  test("WallImage matches database column ordering") {
    assertCaseClassMatchesTable[repo.WallImage]("wallimage")
  }

  test("WallTextbox matches database column ordering") {
    assertCaseClassMatchesTable[repo.WallTextbox]("walltextbox")
  }

  test("WallSticker matches database column ordering") {
    assertCaseClassMatchesTable[repo.WallSticker]("wallsticker")
  }

  //
  
  test("SharedBoard matches database column ordering") {
    assertCaseClassMatchesTable[repo.SharedBoard]("sharedboard")
  }
  
  test("SharedBoardElement matches database column ordering") {
    assertCaseClassMatchesTable[repo.SharedBoardElement]("sharedboardelement")
  }
  
  test("SharedBoardReply matches database column ordering") {
    assertCaseClassMatchesTable[repo.SharedBoardReply]("sharedboardreply")
  }

  //

  test("ConnectionPending matches database column ordering") {
    assertCaseClassMatchesTable[repo.ConnectionPending]("connectionpending")
  }
  
  test("ConnectionRemoved matches database column ordering") {
    assertCaseClassMatchesTable[repo.ConnectionRemoved]("connectionremoved")
  }

  //

  test("ButtonLog matches database column ordering") {
    assertCaseClassMatchesTable[repo.ButtonLog]("buttonlog")
  }
}