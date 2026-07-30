package pt.ulusofona.lp2.greatprogrammingjourney;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class TestGameManager {

    @Test
    public void testCreateInitialBoardWithValidData() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java;Python", "Purple"},
            {"2", "Bob", "C++;JavaScript", "Blue"}
        };
        boolean result = gm.createInitialBoard(playerInfo, 20);
        assertTrue(result, "createInitialBoard should return true with valid data");
    }

    @Test
    public void testCreateInitialBoardWithInvalidWorldSize() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        boolean result = gm.createInitialBoard(playerInfo, 3);
        assertFalse(result, "createInitialBoard should return false when worldSize < playerCount * 2");
    }

    @Test
    public void testGetProgrammerInfoForExistingPlayer() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 15);

        String[] info = gm.getProgrammerInfo(1);
        assertNotNull(info, "getProgrammerInfo should return array for existing player");
        assertEquals(7, info.length, "getProgrammerInfo should return array with 7 elements");
        assertEquals("1", info[0], "Player ID should match");
        assertEquals("Alice", info[1], "Player name should match");
    }

    @Test
    public void testGetProgrammerInfoForNonExistingPlayer() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 15);

        String[] info = gm.getProgrammerInfo(99);
        assertNull(info, "getProgrammerInfo should return null for non-existing player");
    }

    @Test
    public void testGetCurrentPlayerID() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 15);

        int currentId = gm.getCurrentPlayerID();
        assertEquals(1, currentId, "Current player ID should be 1 initially");
    }

    @Test
    public void testMoveCurrentPlayer() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 20);

        boolean result = gm.moveCurrentPlayer(3);
        assertTrue(result, "moveCurrentPlayer should return true for valid move");

        gm.reactToAbyssOrTool();

        int newCurrentId = gm.getCurrentPlayerID();
        assertEquals(2, newCurrentId, "Current player should switch to player 2 after move and reaction");
    }

    @Test
    public void testGetSlotInfo() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 15);

        String[] slotInfo = gm.getSlotInfo(5);
        assertNotNull(slotInfo, "getSlotInfo should not return null");
        assertEquals(3, slotInfo.length, "getSlotInfo should return array with 3 elements");
    }

    @Test
    public void testCreateInitialBoardWithUppercaseColors() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Green"},
            {"2", "Bob", "Python", "Brown"}
        };
        boolean result = gm.createInitialBoard(playerInfo, 4);
        assertTrue(result, "createInitialBoard should accept valid colors like Green and Brown");
    }

    @Test
    public void testCreateInitialBoardWithMinimumWorldSize() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "", "Blue"},
            {"2", "Bob", "", "Green"}
        };
        boolean result = gm.createInitialBoard(playerInfo, 4);
        assertTrue(result, "createInitialBoard should work with worldSize = 4 for 2 players");
    }
}
