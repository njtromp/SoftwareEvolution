package smallsql.junit;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.MessageFormat;
public class TestTokenizer extends BasicTestCase {
	private static final String TABLE_NAME = "table_comments";
	private static final PrintStream out = System.out;
	private boolean init;
	private Connection conn;
	private Statement stat;
	public void setUp() throws SQLException {
		if (! init) {
			conn = AllTests.createConnection("?locale=en", null);
			stat = conn.createStatement();
			init = true;
		}
		dropTable();
		createTable();
	}
	public void tearDown() throws SQLException {
		if (conn != null) {
			dropTable();
			stat.close(); 
			conn.close();
		}
	}
	private void createTable() throws SQLException {
		stat.execute(
				"CREATE TABLE " + TABLE_NAME + 
				" (id INT, myint INT)");
		stat.execute(
				"INSERT INTO " + TABLE_NAME + " VALUES (1, 2)");
		stat.execute(
				"INSERT INTO " + TABLE_NAME + " VALUES (1, 3)");
	}
	private void dropTable() throws SQLException {
		try {
			stat.execute("DROP TABLE " + TABLE_NAME);
		} catch (SQLException e) {
			out.println("REGULAR: " + e.getMessage() + '\n');
		}
	}
	public void testSingleLine() throws SQLException {
		final String SQL_1 = 
			"SELECT 10/2--mycomment\n" + 
			" , -- mycomment    \r\n" +
			"id, SUM(myint)--my comment  \n\n" +
			"FROM " + TABLE_NAME + " -- my other comment \r \r" + 
			"GROUP BY id --mycommentC\n" +
			"--   myC    omment  E    \n" +
			"ORDER BY id \r" +
			"--myCommentD   \r\r\r";
		successTest(SQL_1);
		final String SQL_2 = 
			"SELECT 10/2 - - this must fail ";
		failureTest(SQL_2, "Tokenized not-comment as a line-comment.");
	}
	public void testMultiLine() throws SQLException {
		final String SQL_1 = 
			"SELECT 10/2, id, SUM(myint) /* comment, 'ignore it.   \n" +
			" */ FROM /* -- comment */" + TABLE_NAME + " -- my comment /* \n\r" +
			" /* comment */ GROUP BY id ORDER BY id\r" +
			"/* comment */ -- somment\r\n";
		successTest(SQL_1);
		final String SQL_2 = 
			"SELECT 10/2 / * this must fail */";
		failureTest(SQL_2, "Tokenized not-comment as a multiline-comment.");
		final String SQL_3 = 
			"SELECT 10/2 /* this must fail ";
		failureTest(SQL_3, 
				"Uncomplete end multiline comment not recognized.",
				"Missing end comment mark");
	}
	private void successTest(String sql) throws SQLException {
		ResultSet rs_1 = stat.executeQuery(sql);
		rs_1.next();
		rs_1.close();
	}
	private void failureTest(String sql, String failureMessage) {
		try {
			stat.executeQuery(sql);
			fail(failureMessage);
		}
		catch (SQLException e) {
			out.println("REGULAR: " + e.getMessage() + '\n');
		}
	}
	private void failureTest(String sql, String failureMessage, String expected) {
		try {
			stat.executeQuery(sql);
			fail(failureMessage);
		}
		catch (SQLException e) {
			String foundMsg = e.getMessage();
			String assertMsg = MessageFormat.format(
					"Unexpected error: [{0}], expected: [{1}]", 
					new Object[] { foundMsg, expected }); 
			assertTrue(assertMsg, foundMsg.indexOf(expected) > -1);
			out.println("REGULAR: " + e.getMessage() + '\n');
		}
	}
}