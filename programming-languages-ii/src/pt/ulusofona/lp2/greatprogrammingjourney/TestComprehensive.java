package pt.ulusofona.lp2.greatprogrammingjourney;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import static org.junit.jupiter.api.Assertions.*;

import java.io.File;
import java.io.FileWriter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;

public class TestComprehensive {

    @Test
    public void testCreateBoardWithNullPlayerInfo() {
        GameManager gm = new GameManager();
        assertFalse(gm.createInitialBoard(null, 10));
    }

    @Test
    public void testCreateBoardWithOnePlayer() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {{"1", "Solo", "Java", "Purple"}};
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithFivePlayers() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "P1", "Java", "Purple"},
            {"2", "P2", "Python", "Blue"},
            {"3", "P3", "C", "Green"},
            {"4", "P4", "Ruby", "Brown"},
            {"5", "P5", "Go", "Purple"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 20));
    }

    @Test
    public void testCreateBoardWithDuplicateIds() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"1", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithDuplicateColors() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Purple"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithInvalidColor() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Red"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithEmptyName() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithNullName() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", null, "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithNullId() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {null, "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithNegativeId() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"-1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithZeroId() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"0", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithNonNumericId() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"abc", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithEmptyId() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithNullPlayerEntry() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            null,
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithShortPlayerEntry() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1"},
            {"2", "Bob", "Python", "Blue"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithThreePlayers() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"},
            {"3", "Carol", "C", "Green"}
        };
        assertTrue(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithFourPlayers() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"},
            {"3", "Carol", "C", "Green"},
            {"4", "Dan", "Go", "Brown"}
        };
        assertTrue(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithAbyssesAndTools() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "0", "5"},
            {"1", "0", "3"}
        };
        assertTrue(gm.createInitialBoard(playerInfo, 10, abyssesAndTools));
    }

    @Test
    public void testCreateBoardWithInvalidAbyssId() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "99", "5"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10, abyssesAndTools));
    }

    @Test
    public void testCreateBoardWithInvalidToolId() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "99", "5"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10, abyssesAndTools));
    }

    @Test
    public void testCreateBoardWithInvalidElementType() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"2", "0", "5"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10, abyssesAndTools));
    }

    @Test
    public void testCreateBoardWithNullAbyssData() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            null
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10, abyssesAndTools));
    }

    @Test
    public void testCreateBoardWithShortAbyssData() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "5"}
        };
        assertFalse(gm.createInitialBoard(playerInfo, 10, abyssesAndTools));
    }

    @Test
    public void testGetImagePngWithNoBoard() {
        GameManager gm = new GameManager();
        assertEquals("", gm.getImagePng(5));
    }

    @Test
    public void testGetImagePngWithTile() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertEquals("blank.png", gm.getImagePng(5));
    }

    @Test
    public void testGetImagePngWithAbyss() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "0", "5"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);
        assertEquals("syntax.png", gm.getImagePng(5));
    }

    @Test
    public void testGetImagePngWithTool() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "4", "5"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);
        assertEquals("IDE.png", gm.getImagePng(5));
    }

    @Test
    public void testGetProgrammerInfoAsStr() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java;Python", "Purple"},
            {"2", "Bob", "C", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);

        String info = gm.getProgrammerInfoAsStr(1);
        assertNotNull(info);
        assertTrue(info.contains("Alice"));
        assertTrue(info.contains("Java"));
    }

    @Test
    public void testGetProgrammerInfoAsStrNonExistent() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertNull(gm.getProgrammerInfoAsStr(99));
    }

    @Test
    public void testGetProgrammersInfo() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);

        String info = gm.getProgrammersInfo();
        assertTrue(info.contains("Alice"));
        assertTrue(info.contains("Bob"));
    }

    @Test
    public void testGetProgrammersInfoWithNullPlayers() {
        GameManager gm = new GameManager();
        assertEquals("", gm.getProgrammersInfo());
    }

    @Test
    public void testGetCurrentPlayerIDBeforeGameStart() {
        GameManager gm = new GameManager();
        assertEquals(-1, gm.getCurrentPlayerID());
    }

    @Test
    public void testMoveCurrentPlayerBeforeGameStart() {
        GameManager gm = new GameManager();
        assertFalse(gm.moveCurrentPlayer(3));
    }

    @Test
    public void testMoveCurrentPlayerInvalidDiceZero() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertFalse(gm.moveCurrentPlayer(0));
    }

    @Test
    public void testMoveCurrentPlayerInvalidDiceSeven() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertFalse(gm.moveCurrentPlayer(7));
    }

    @Test
    public void testMoveCurrentPlayerInvalidDiceNegative() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertFalse(gm.moveCurrentPlayer(-1));
    }

    @Test
    public void testMoveAssemblyPlayerRestriction() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Assembly", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertFalse(gm.moveCurrentPlayer(3));
        assertTrue(gm.moveCurrentPlayer(2));
    }

    @Test
    public void testMoveCPlayerRestriction() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "C", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertFalse(gm.moveCurrentPlayer(4));
        assertTrue(gm.moveCurrentPlayer(3));
    }

    @Test
    public void testMoveBounceBack() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 7);

        gm.moveCurrentPlayer(4);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(6);
        String[] info = gm.getProgrammerInfo(1);
        assertTrue(Integer.parseInt(info[4]) <= 7);
    }

    @Test
    public void testGameIsOverWhenPlayerReachesEnd() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 7);

        gm.moveCurrentPlayer(6);
        gm.reactToAbyssOrTool();

        assertTrue(gm.gameIsOver());
    }

    @Test
    public void testGameIsOverBeforeStart() {
        GameManager gm = new GameManager();
        assertFalse(gm.gameIsOver());
    }

    @Test
    public void testReactToAbyssOrToolBeforeGameStart() {
        GameManager gm = new GameManager();
        assertNull(gm.reactToAbyssOrTool());
    }

    @Test
    public void testReactToAbyssOrToolPicksUpTool() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "0", "4"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(3);
        String result = gm.reactToAbyssOrTool();

        assertNotNull(result);
        assertTrue(result.contains("apanhou"));
    }

    @Test
    public void testReactToAbyssWithCounterTool() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "4", "2"},
            {"0", "0", "4"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(2);
        String result = gm.reactToAbyssOrTool();

        assertTrue(result.contains("usou"));
    }

    @Test
    public void testReactToAbyssWithoutCounterTool() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "0", "4"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(3);
        String result = gm.reactToAbyssOrTool();

        assertTrue(result.contains("voltou"));
    }

    @Test
    public void testPlayerAlreadyHasTool() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "0", "2"},
            {"1", "0", "4"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(2);
        String result = gm.reactToAbyssOrTool();

        assertTrue(result.contains("já tem"));
    }

    @Test
    public void testInfiniteLoopTrapsPlayer() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "8", "4"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(3);
        String result = gm.reactToAbyssOrTool();

        assertTrue(result.contains("preso"));
        String[] info = gm.getProgrammerInfo(1);
        assertEquals("Preso", info[6]);
    }

    @Test
    public void testTrappedPlayerCannotMove() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "8", "4"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(3);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        assertFalse(gm.moveCurrentPlayer(3));
    }

    @Test
    public void testGetSlotInfoWithPlayers() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);

        String[] slotInfo = gm.getSlotInfo(1);
        assertTrue(slotInfo[0].contains("1"));
        assertTrue(slotInfo[0].contains("2"));
    }

    @Test
    public void testGetSlotInfoWithAbyss() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "0", "5"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        String[] slotInfo = gm.getSlotInfo(5);
        assertEquals("Erro de sintaxe", slotInfo[1]);
        assertEquals("A:0", slotInfo[2]);
    }

    @Test
    public void testGetSlotInfoWithTool() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "0", "5"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        String[] slotInfo = gm.getSlotInfo(5);
        assertEquals("Herança", slotInfo[1]);
        assertEquals("T:0", slotInfo[2]);
    }

    @Test
    public void testGetSlotInfoNoBoard() {
        GameManager gm = new GameManager();
        String[] slotInfo = gm.getSlotInfo(5);
        assertEquals("", slotInfo[0]);
        assertEquals("", slotInfo[1]);
        assertEquals("", slotInfo[2]);
    }

    @Test
    public void testGetGameResults() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 7);

        gm.moveCurrentPlayer(6);
        gm.reactToAbyssOrTool();

        ArrayList<String> results = gm.getGameResults();
        assertTrue(results.contains("THE GREAT PROGRAMMING JOURNEY"));
        assertTrue(results.contains("NR. DE TURNOS"));
        assertTrue(results.contains("VENCEDOR"));
        assertTrue(results.contains("Alice"));
        assertTrue(results.contains("RESTANTES"));
    }

    @Test
    public void testGetGameResultsMultiplePlayers() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"},
            {"3", "Carol", "C", "Green"}
        };
        gm.createInitialBoard(playerInfo, 10);

        gm.moveCurrentPlayer(5);
        gm.reactToAbyssOrTool();
        gm.moveCurrentPlayer(3);
        gm.reactToAbyssOrTool();
        gm.moveCurrentPlayer(2);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(5);
        gm.reactToAbyssOrTool();

        ArrayList<String> results = gm.getGameResults();
        assertTrue(results.size() > 5);
    }

    @Test
    public void testCustomizeBoard() {
        GameManager gm = new GameManager();
        var customizations = gm.customizeBoard();
        assertEquals("true", customizations.get("hasNewAbyss"));
        assertEquals("10", customizations.get("newAbyssId"));
        assertEquals("Stack Overflow", customizations.get("newAbyssName"));
    }

    @Test
    public void testAuthorsPanel() {
        GameManager gm = new GameManager();
        assertNotNull(gm.getAuthorsPanel());
    }

    @Test
    public void testSaveGameBeforeStart() {
        GameManager gm = new GameManager();
        File file = new File("test_save.txt");
        assertFalse(gm.saveGame(file));
        file.delete();
    }

    @Test
    public void testSaveGameNullFile() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);
        assertFalse(gm.saveGame(null));
    }

    @Test
    public void testSaveAndLoadGame(@TempDir Path tempDir) throws Exception {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "0", "5"},
            {"1", "0", "3"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(3);
        gm.reactToAbyssOrTool();

        File saveFile = tempDir.resolve("test_save.txt").toFile();
        assertTrue(gm.saveGame(saveFile));

        GameManager gm2 = new GameManager();
        gm2.loadGame(saveFile);

        assertEquals(gm.getCurrentPlayerID(), gm2.getCurrentPlayerID());
    }

    @Test
    public void testLoadGameNullFile() {
        GameManager gm = new GameManager();
        assertThrows(InvalidFileException.class, () -> gm.loadGame(null));
    }

    @Test
    public void testLoadGameNonExistentFile() {
        GameManager gm = new GameManager();
        File file = new File("non_existent_file.txt");
        assertThrows(FileNotFoundException.class, () -> gm.loadGame(file));
    }

    @Test
    public void testLoadGameValidFormat(@TempDir Path tempDir) throws Exception {
        File file = tempDir.resolve("valid.txt").toFile();
        FileWriter writer = new FileWriter(file);
        writer.write("VERSION:1\n");
        writer.write("WORLD_SIZE:10\n");
        writer.write("TURN:1\n");
        writer.write("CURRENT_PLAYER_INDEX:0\n");
        writer.write("GAME_OVER:false\n");
        writer.write("PLAYER:1,Alice,1,Purple,Java,Em Jogo,\n");
        writer.write("PLAYER:2,Bob,1,Blue,Python,Em Jogo,\n");
        writer.close();

        GameManager gm = new GameManager();
        gm.loadGame(file);
        assertTrue(gm.getCurrentPlayerID() >= 0);
    }

    @Test
    public void testPlayerInitialState() {
        Player player = new Player("1", "Test");
        assertEquals("1", player.getId());
        assertEquals("Test", player.getName());
        assertEquals(1, player.getCurrentPosition());
        assertEquals("Em Jogo", player.getStatus());
        assertEquals("", player.getColor());
        assertFalse(player.isEliminated());
        assertFalse(player.isTrapped());
    }

    @Test
    public void testPlayerLanguages() {
        Player player = new Player("1", "Test");
        player.addLanguage("Python");
        player.addLanguage("Java");
        player.addLanguage("C");

        String langs = player.getLanguagesAsString();
        assertTrue(langs.contains("C"));
        assertTrue(langs.contains("Java"));
        assertTrue(langs.contains("Python"));
    }

    @Test
    public void testPlayerEmptyLanguages() {
        Player player = new Player("1", "Test");
        assertEquals("", player.getLanguagesAsString());
    }

    @Test
    public void testPlayerTools() {
        Player player = new Player("1", "Test");
        Tool tool1 = ToolFactory.create(0);
        Tool tool2 = ToolFactory.create(1);

        player.addTool(tool1);
        player.addTool(tool2);

        assertTrue(player.hasTool(0));
        assertTrue(player.hasTool(1));
        assertFalse(player.hasTool(2));

        String toolsStr = player.getToolsAsString();
        assertTrue(toolsStr.length() > 0);
    }

    @Test
    public void testPlayerEmptyTools() {
        Player player = new Player("1", "Test");
        assertEquals("", player.getToolsAsString());
    }

    @Test
    public void testPlayerRemoveTool() {
        Player player = new Player("1", "Test");
        Tool tool = ToolFactory.create(0);
        player.addTool(tool);
        assertTrue(player.hasTool(0));

        player.removeTool(tool);
        assertFalse(player.hasTool(0));
    }

    @Test
    public void testPlayerMoveBy() {
        Player player = new Player("1", "Test");
        player.moveBy(5);
        assertEquals(6, player.getCurrentPosition());
    }

    @Test
    public void testPlayerPositionHistory() {
        Player player = new Player("1", "Test");
        player.setPosition(5);
        player.setPosition(10);
        player.setPosition(15);

        assertEquals(4, player.getPositionHistorySize());
        assertEquals(10, player.getPreviousPosition());
        assertEquals(15, player.getCurrentPosition());
    }

    @Test
    public void testPlayerGetPositionFromNMovesAgo() {
        Player player = new Player("1", "Test");
        player.setPosition(5);
        player.setPosition(10);
        player.setPosition(15);

        assertEquals(10, player.getPositionFromNMovesAgo(1));
        assertEquals(5, player.getPositionFromNMovesAgo(2));
        assertEquals(1, player.getPositionFromNMovesAgo(3));
    }

    @Test
    public void testPlayerGetPositionFromNMovesAgoExceedsHistory() {
        Player player = new Player("1", "Test");
        player.setPosition(5);

        assertEquals(1, player.getPositionFromNMovesAgo(100));
    }

    @Test
    public void testPlayerGetPositionFromHistory() {
        Player player = new Player("1", "Test");
        player.setPosition(5);
        player.setPosition(10);

        assertEquals(1, player.getPositionFromHistory(0));
        assertEquals(5, player.getPositionFromHistory(1));
        assertEquals(10, player.getPositionFromHistory(2));
    }

    @Test
    public void testPlayerGetPositionFromHistoryInvalidIndex() {
        Player player = new Player("1", "Test");
        assertEquals(1, player.getPositionFromHistory(-1));
        assertEquals(1, player.getPositionFromHistory(100));
    }

    @Test
    public void testPlayerToolIdsAsString() {
        Player player = new Player("1", "Test");
        player.addTool(ToolFactory.create(0));
        player.addTool(ToolFactory.create(2));

        String ids = player.getToolIdsAsString();
        assertTrue(ids.contains("0"));
        assertTrue(ids.contains("2"));
    }

    @Test
    public void testPlayerEmptyToolIdsAsString() {
        Player player = new Player("1", "Test");
        assertEquals("", player.getToolIdsAsString());
    }

    @Test
    public void testPlayerStatus() {
        Player player = new Player("1", "Test");

        player.setStatus("Preso");
        assertTrue(player.isTrapped());

        player.setStatus("Derrotado");
        assertTrue(player.isEliminated());
    }

    @Test
    public void testPlayerLastDiceRoll() {
        Player player = new Player("1", "Test");
        player.setLastDiceRoll(5);
        assertEquals(5, player.getLastDiceRoll());
    }

    @Test
    public void testSyntaxErrorAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(5);

        SyntaxErrorAbyss abyss = new SyntaxErrorAbyss();
        assertEquals(0, abyss.getId());
        assertEquals("Erro de sintaxe", abyss.getName());
        assertEquals("syntax.png", abyss.getImageName());

        String result = abyss.applyEffect(player);
        assertEquals(4, player.getCurrentPosition());
        assertTrue(result.contains("voltou"));
    }

    @Test
    public void testSyntaxErrorAbyssAtPosition1() {
        Player player = new Player("1", "Test");
        player.setPosition(1);

        SyntaxErrorAbyss abyss = new SyntaxErrorAbyss();
        abyss.applyEffect(player);

        assertEquals(1, player.getCurrentPosition());
    }

    @Test
    public void testLogicErrorAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(10);
        player.setLastDiceRoll(4);

        LogicErrorAbyss abyss = new LogicErrorAbyss();
        assertEquals(1, abyss.getId());
        assertEquals("Erro de Lógica", abyss.getName());

        String result = abyss.applyEffect(player);
        assertEquals(8, player.getCurrentPosition());
        assertTrue(result.contains("voltou"));
    }

    @Test
    public void testLogicErrorAbyssOddDice() {
        Player player = new Player("1", "Test");
        player.setPosition(10);
        player.setLastDiceRoll(5);

        LogicErrorAbyss abyss = new LogicErrorAbyss();
        abyss.applyEffect(player);
        assertEquals(8, player.getCurrentPosition());
    }

    @Test
    public void testSideEffectsAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(5);
        player.setPosition(10);
        player.setPosition(15);

        SideEffectsAbyss abyss = new SideEffectsAbyss();
        assertEquals(6, abyss.getId());
        assertEquals("Efeitos Secundarios", abyss.getName());

        abyss.applyEffect(player);
        assertEquals(5, player.getCurrentPosition());
    }

    @Test
    public void testInfiniteLoopAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(5);

        InfiniteLoopAbyss abyss = new InfiniteLoopAbyss();
        assertEquals(8, abyss.getId());
        assertEquals("Ciclo Infinito", abyss.getName());

        String result = abyss.applyEffect(player);
        assertEquals("Preso", player.getStatus());
        assertTrue(result.contains("preso"));
    }

    @Test
    public void testSegFaultAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(10);

        SegFaultAbyss abyss = new SegFaultAbyss();
        assertEquals(9, abyss.getId());
        assertEquals("Segmentation Fault", abyss.getName());
        assertTrue(abyss.requiresMultiplePlayers());

        String result = abyss.applyEffect(player);
        assertEquals(7, player.getCurrentPosition());
    }

    @Test
    public void testSegFaultAbyssNearStart() {
        Player player = new Player("1", "Test");
        player.setPosition(2);

        SegFaultAbyss abyss = new SegFaultAbyss();
        abyss.applyEffect(player);
        assertEquals(1, player.getCurrentPosition());
    }

    @Test
    public void testStackOverflowAbyss() {
        Player player = new Player("1", "Test");
        for (int i = 1; i <= 20; i++) {
            player.setPosition(i);
        }

        StackOverflowAbyss abyss = new StackOverflowAbyss();
        assertEquals(10, abyss.getId());
        assertEquals("Stack Overflow", abyss.getName());
        assertEquals("stack_overflow.png", abyss.getImageName());

        int historyBefore = player.getPositionHistorySize();
        String result = abyss.applyEffect(player);

        assertTrue(player.getCurrentPosition() < 20);
        assertEquals(historyBefore, player.getPositionHistorySize());
        assertTrue(result.contains("desfazer"));
    }

    @Test
    public void testInheritanceTool() {
        Tool tool = ToolFactory.create(0);
        assertEquals(0, tool.getId());
        assertEquals("Herança", tool.getName());
        assertEquals("TOOL", tool.getType());

        assertTrue(tool.counters(AbyssFactory.create(5)));
    }

    @Test
    public void testFunctionalProgrammingTool() {
        Tool tool = ToolFactory.create(1);
        assertEquals(1, tool.getId());
        assertEquals("Programação Funcional", tool.getName());

        assertTrue(tool.counters(AbyssFactory.create(6)));
        assertTrue(tool.counters(AbyssFactory.create(8)));
    }

    @Test
    public void testUnitTestsTool() {
        Tool tool = ToolFactory.create(2);
        assertEquals(2, tool.getId());
        assertEquals("Testes Unitários", tool.getName());
        assertEquals("unit-tests.png", tool.getImageName());

        assertTrue(tool.counters(AbyssFactory.create(1)));
    }

    @Test
    public void testExceptionHandlingTool() {
        Tool tool = ToolFactory.create(3);
        assertEquals(3, tool.getId());
        assertEquals("Tratamento de Excepções", tool.getName());

        assertTrue(tool.counters(AbyssFactory.create(2)));
        assertTrue(tool.counters(AbyssFactory.create(3)));
    }

    @Test
    public void testIDETool() {
        Tool tool = ToolFactory.create(4);
        assertEquals(4, tool.getId());
        assertEquals("IDE", tool.getName());
        assertEquals("IDE.png", tool.getImageName());

        assertTrue(tool.counters(AbyssFactory.create(0)));
        assertTrue(tool.counters(AbyssFactory.create(2)));
    }

    @Test
    public void testProfessorHelpTool() {
        Tool tool = ToolFactory.create(5);
        assertEquals(5, tool.getId());
        assertEquals("Ajuda do Professor", tool.getName());
        assertEquals("ajuda-professor.png", tool.getImageName());

        assertTrue(tool.counters(AbyssFactory.create(4)));
        assertTrue(tool.counters(AbyssFactory.create(7)));
        assertTrue(tool.counters(AbyssFactory.create(9)));
    }

    @Test
    public void testBoardCreation() {
        Board board = new Board(10);
        assertEquals(10, board.getWorldSize());
        assertEquals(10, board.getTiles().size());
    }

    @Test
    public void testBoardGetTileAt() {
        Board board = new Board(10);
        Tile tile = board.getTileAt(5);
        assertNotNull(tile);
        assertEquals(5, tile.getPosition());
    }

    @Test
    public void testBoardGetTileAtInvalid() {
        Board board = new Board(10);
        assertNull(board.getTileAt(15));
    }

    @Test
    public void testBoardPlaceElements() {
        Board board = new Board(10);
        String[][] elements = {
            {"0", "0", "3"},
            {"1", "0", "5"}
        };
        board.placeElements(elements);

        assertNotNull(board.getAbyssAt(3));
        assertNotNull(board.getToolAt(5));
    }

    @Test
    public void testBoardPlaceElementsNull() {
        Board board = new Board(10);
        board.placeElements(null);
        assertTrue(board.getAbysses().isEmpty());
    }

    @Test
    public void testBoardPlaceElementsInvalidData() {
        Board board = new Board(10);
        String[][] elements = {
            {"0", "invalid", "3"}
        };
        board.placeElements(elements);
        assertNull(board.getAbyssAt(3));
    }

    @Test
    public void testBoardRemoveToolFromBoard() {
        Board board = new Board(10);
        String[][] elements = {
            {"1", "0", "5"}
        };
        board.placeElements(elements);

        Tool tool = board.getToolAt(5);
        assertNotNull(tool);

        board.removeToolFromBoard(tool);
        assertNull(board.getToolAt(5));
    }

    @Test
    public void testBoardGetAbysses() {
        Board board = new Board(10);
        String[][] elements = {
            {"0", "0", "3"},
            {"0", "1", "5"}
        };
        board.placeElements(elements);

        assertEquals(2, board.getAbysses().size());
    }

    @Test
    public void testBoardGetToolsOnBoard() {
        Board board = new Board(10);
        String[][] elements = {
            {"1", "0", "3"},
            {"1", "1", "5"}
        };
        board.placeElements(elements);

        assertEquals(2, board.getToolsOnBoard().size());
    }

    @Test
    public void testTileCreation() {
        Tile tile = new Tile(5, "GRASS", "blank.png");
        assertEquals(5, tile.getPosition());
        assertEquals("GRASS", tile.getType());
        assertEquals("blank.png", tile.getImageName());
    }

    @Test
    public void testTileSetType() {
        Tile tile = new Tile(5, "GRASS", "blank.png");
        tile.setType("ABYSS");
        assertEquals("ABYSS", tile.getType());
    }

    @Test
    public void testInvalidFileExceptionMessage() {
        InvalidFileException ex = new InvalidFileException("Custom error");
        assertEquals("Custom error", ex.getMessage());
    }

    @Test
    public void testInvalidFileExceptionIsException() {
        InvalidFileException ex = new InvalidFileException("Test");
        assertTrue(ex instanceof Exception);
    }

    @Test
    public void testFullGameFlow() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "0", "3"},
            {"0", "5", "5"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(2);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        gm.moveCurrentPlayer(2);
        String result = gm.reactToAbyssOrTool();

        assertTrue(result.contains("usou") || result.contains("apanhou"));
    }

    @Test
    public void testPlayerEliminationFlow() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "7", "3"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(2);
        gm.reactToAbyssOrTool();

        String[] info = gm.getProgrammerInfo(1);
        assertEquals("Derrotado", info[6]);
    }

    @Test
    public void testMultipleTurnsFlow() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"},
            {"3", "Carol", "C", "Green"}
        };
        gm.createInitialBoard(playerInfo, 20);

        for (int round = 0; round < 3; round++) {
            gm.moveCurrentPlayer(2);
            gm.reactToAbyssOrTool();
            gm.moveCurrentPlayer(2);
            gm.reactToAbyssOrTool();
            gm.moveCurrentPlayer(2);
            gm.reactToAbyssOrTool();
        }

        String[] info1 = gm.getProgrammerInfo(1);
        String[] info2 = gm.getProgrammerInfo(2);
        String[] info3 = gm.getProgrammerInfo(3);

        assertTrue(Integer.parseInt(info1[4]) > 1);
        assertTrue(Integer.parseInt(info2[4]) > 1);
        assertTrue(Integer.parseInt(info3[4]) > 1);
    }

    @Test
    public void testDuplicateCodeAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(5);
        player.setPosition(10);

        DuplicateCodeAbyss abyss = new DuplicateCodeAbyss();
        assertEquals(5, abyss.getId());
        assertEquals("Codigo Duplicado", abyss.getName());
        assertEquals("duplicated-code.png", abyss.getImageName());

        String result = abyss.applyEffect(player);
        assertEquals(5, player.getCurrentPosition());
        assertTrue(result.contains("voltou"));
    }

    @Test
    public void testExceptionAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(10);

        ExceptionAbyss abyss = new ExceptionAbyss();
        assertEquals(2, abyss.getId());
        assertEquals("Exception", abyss.getName());
        assertEquals("exception.png", abyss.getImageName());

        String result = abyss.applyEffect(player);
        assertEquals(8, player.getCurrentPosition());
        assertTrue(result.contains("voltou"));
    }

    @Test
    public void testExceptionAbyssNearStart() {
        Player player = new Player("1", "Test");
        player.setPosition(2);

        ExceptionAbyss abyss = new ExceptionAbyss();
        abyss.applyEffect(player);
        assertEquals(1, player.getCurrentPosition());
    }

    @Test
    public void testFileNotFoundAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(10);

        FileNotFoundAbyss abyss = new FileNotFoundAbyss();
        assertEquals(3, abyss.getId());
        assertEquals("FileNotFoundException", abyss.getName());
        assertEquals("file-not-found-exception.png", abyss.getImageName());

        String result = abyss.applyEffect(player);
        assertEquals(7, player.getCurrentPosition());
        assertTrue(result.contains("recuou"));
    }

    @Test
    public void testFileNotFoundAbyssNearStart() {
        Player player = new Player("1", "Test");
        player.setPosition(2);

        FileNotFoundAbyss abyss = new FileNotFoundAbyss();
        abyss.applyEffect(player);
        assertEquals(1, player.getCurrentPosition());
    }

    @Test
    public void testCrashAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(15);

        CrashAbyss abyss = new CrashAbyss();
        assertEquals(4, abyss.getId());
        assertEquals("Crash", abyss.getName());
        assertEquals("crash.png", abyss.getImageName());

        String result = abyss.applyEffect(player);
        assertEquals(1, player.getCurrentPosition());
        assertTrue(result.contains("inicial"));
    }

    @Test
    public void testBlueScreenAbyss() {
        Player player = new Player("1", "Test");
        player.setPosition(10);

        BlueScreenAbyss abyss = new BlueScreenAbyss();
        assertEquals(7, abyss.getId());
        assertEquals("Blue Screen of Death", abyss.getName());
        assertEquals("bsod.png", abyss.getImageName());

        String result = abyss.applyEffect(player);
        assertEquals("Derrotado", player.getStatus());
        assertTrue(result.contains("Blue Screen"));
    }

    @Test
    public void testInheritanceToolImage() {
        Tool tool = ToolFactory.create(0);
        assertEquals("inheritance.png", tool.getImageName());
    }

    @Test
    public void testFunctionalProgrammingToolImage() {
        Tool tool = ToolFactory.create(1);
        assertEquals("functional.png", tool.getImageName());
    }

    @Test
    public void testToolApplyEffectMessage() {
        Player player = new Player("1", "Test");
        Tool tool = ToolFactory.create(0);

        String result = tool.applyEffect(player);
        assertTrue(result.contains("apanhou"));
        assertTrue(result.contains("Herança"));
    }

    @Test
    public void testGetSlotInfoWithEmptySlot() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);

        String[] slotInfo = gm.getSlotInfo(8);
        assertEquals("", slotInfo[0]);
        assertEquals("", slotInfo[1]);
        assertEquals("", slotInfo[2]);
    }

    @Test
    public void testCreateBoardResetsState() {
        GameManager gm = new GameManager();
        String[][] playerInfo1 = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo1, 10);

        String[][] playerInfo2 = {
            {"3", "Carol", "C", "Green"},
            {"4", "Dan", "Go", "Brown"}
        };
        gm.createInitialBoard(playerInfo2, 15);

        assertEquals(3, gm.getCurrentPlayerID());
    }

    @Test
    public void testProgrammerInfoWithTools() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"1", "0", "2"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(1);
        gm.reactToAbyssOrTool();

        String[] info = gm.getProgrammerInfo(1);
        assertTrue(info[5].contains("Herança"));
    }

    @Test
    public void testProgrammersInfoExcludesEliminated() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        String[][] abyssesAndTools = {
            {"0", "7", "3"}
        };
        gm.createInitialBoard(playerInfo, 10, abyssesAndTools);

        gm.moveCurrentPlayer(2);
        gm.reactToAbyssOrTool();

        String info = gm.getProgrammersInfo();
        assertFalse(info.contains("Alice"));
        assertTrue(info.contains("Bob"));
    }

    @Test
    public void testCreateBoardWithMultipleLanguages() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java;Python;C", "Purple"},
            {"2", "Bob", "Go;Rust", "Blue"}
        };
        assertTrue(gm.createInitialBoard(playerInfo, 10));

        String[] info = gm.getProgrammerInfo(1);
        assertTrue(info[2].contains("Java"));
        assertTrue(info[2].contains("Python"));
        assertTrue(info[2].contains("C"));
    }

    @Test
    public void testCreateBoardWithEmptyLanguages() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "", "Purple"},
            {"2", "Bob", "", "Blue"}
        };
        assertTrue(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testCreateBoardWithAllValidColors() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"},
            {"3", "Carol", "C", "Green"},
            {"4", "Dan", "Go", "Brown"}
        };
        assertTrue(gm.createInitialBoard(playerInfo, 10));
    }

    @Test
    public void testSyntaxErrorIsCounteredByIDE() {
        SyntaxErrorAbyss abyss = new SyntaxErrorAbyss();
        Tool ide = ToolFactory.create(4);
        assertTrue(abyss.isCounteredBy(ide));
    }

    @Test
    public void testLogicErrorIsCounteredByUnitTests() {
        LogicErrorAbyss abyss = new LogicErrorAbyss();
        Tool unitTests = ToolFactory.create(2);
        assertTrue(abyss.isCounteredBy(unitTests));
    }

    @Test
    public void testExceptionIsCounteredByExceptionHandling() {
        ExceptionAbyss abyss = new ExceptionAbyss();
        Tool exHandler = ToolFactory.create(3);
        assertTrue(abyss.isCounteredBy(exHandler));
    }

    @Test
    public void testFileNotFoundIsCounteredByExceptionHandling() {
        FileNotFoundAbyss abyss = new FileNotFoundAbyss();
        Tool exHandler = ToolFactory.create(3);
        assertTrue(abyss.isCounteredBy(exHandler));
    }

    @Test
    public void testCrashIsCounteredByProfessorHelp() {
        CrashAbyss abyss = new CrashAbyss();
        Tool profHelp = ToolFactory.create(5);
        assertTrue(abyss.isCounteredBy(profHelp));
    }

    @Test
    public void testDuplicateCodeIsCounteredByInheritance() {
        DuplicateCodeAbyss abyss = new DuplicateCodeAbyss();
        Tool inheritance = ToolFactory.create(0);
        assertTrue(abyss.isCounteredBy(inheritance));
    }

    @Test
    public void testSideEffectsIsCounteredByFunctionalProgramming() {
        SideEffectsAbyss abyss = new SideEffectsAbyss();
        Tool functional = ToolFactory.create(1);
        assertTrue(abyss.isCounteredBy(functional));
    }

    @Test
    public void testBlueScreenIsCounteredByProfessorHelp() {
        BlueScreenAbyss abyss = new BlueScreenAbyss();
        Tool profHelp = ToolFactory.create(5);
        assertTrue(abyss.isCounteredBy(profHelp));
    }

    @Test
    public void testSegFaultIsCounteredByProfessorHelp() {
        SegFaultAbyss abyss = new SegFaultAbyss();
        Tool profHelp = ToolFactory.create(5);
        assertTrue(abyss.isCounteredBy(profHelp));
    }

    @Test
    public void testBoardPlaceElementsWithInvalidType() {
        Board board = new Board(10);
        String[][] elements = {
            {"2", "0", "3"}
        };
        board.placeElements(elements);
        assertNull(board.getAbyssAt(3));
        assertNull(board.getToolAt(3));
    }

    @Test
    public void testBoardPlaceElementsWithNullEntry() {
        Board board = new Board(10);
        String[][] elements = {
            null,
            {"0", "0", "5"}
        };
        board.placeElements(elements);
        assertNotNull(board.getAbyssAt(5));
    }

    @Test
    public void testBoardPlaceElementsWithShortEntry() {
        Board board = new Board(10);
        String[][] elements = {
            {"0", "0"},
            {"0", "1", "5"}
        };
        board.placeElements(elements);
        assertNotNull(board.getAbyssAt(5));
    }

    @Test
    public void testBoardGetAbyssAtEmpty() {
        Board board = new Board(10);
        assertNull(board.getAbyssAt(5));
    }

    @Test
    public void testBoardGetToolAtEmpty() {
        Board board = new Board(10);
        assertNull(board.getToolAt(5));
    }

    @Test
    public void testPlayerGetTools() {
        Player player = new Player("1", "Test");
        Tool t1 = ToolFactory.create(0);
        Tool t2 = ToolFactory.create(1);
        player.addTool(t1);
        player.addTool(t2);

        ArrayList<Tool> tools = player.getTools();
        assertEquals(2, tools.size());
    }

    @Test
    public void testPlayerGetLanguages() {
        Player player = new Player("1", "Test");
        player.addLanguage("Java");
        player.addLanguage("Python");

        ArrayList<String> langs = player.getLanguages();
        assertEquals(2, langs.size());
        assertTrue(langs.contains("Java"));
        assertTrue(langs.contains("Python"));
    }

    @Test
    public void testPlayerFindCounterToolWithMultipleTools() {
        Player player = new Player("1", "Test");
        player.addTool(ToolFactory.create(0));
        player.addTool(ToolFactory.create(1));
        player.addTool(ToolFactory.create(5));

        Abyss crash = AbyssFactory.create(4);
        Tool counter = player.findCounterTool(crash);
        assertNotNull(counter);
        assertEquals(5, counter.getId());
    }

    @Test
    public void testPlayerSetPositionFromEffectDoesNotAffectHistory() {
        Player player = new Player("1", "Test");
        player.setPosition(5);
        player.setPosition(10);

        int historyBefore = player.getPositionHistorySize();
        player.setPositionFromEffect(3);

        assertEquals(historyBefore, player.getPositionHistorySize());
        assertEquals(3, player.getCurrentPosition());
    }

    @Test
    public void testMoveAfterGameOver() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 7);

        gm.moveCurrentPlayer(6);
        gm.reactToAbyssOrTool();

        assertTrue(gm.gameIsOver());

        assertFalse(gm.moveCurrentPlayer(3));
    }

    @Test
    public void testReactWithNoSpecialElement() {
        GameManager gm = new GameManager();
        String[][] playerInfo = {
            {"1", "Alice", "Java", "Purple"},
            {"2", "Bob", "Python", "Blue"}
        };
        gm.createInitialBoard(playerInfo, 10);

        gm.moveCurrentPlayer(3);
        String result = gm.reactToAbyssOrTool();

        assertNull(result);
    }

    @Test
    public void testStackOverflowAbyssCounteredByTools() {
        StackOverflowAbyss abyss = new StackOverflowAbyss();

        Tool unitTests = ToolFactory.create(2);
        Tool ide = ToolFactory.create(4);
        Tool profHelp = ToolFactory.create(5);

        assertTrue(abyss.isCounteredBy(unitTests));
        assertTrue(abyss.isCounteredBy(ide));
        assertTrue(abyss.isCounteredBy(profHelp));
    }

    @Test
    public void testInfiniteLoopAbyssIsCounteredByIDE() {
        InfiniteLoopAbyss abyss = new InfiniteLoopAbyss();
        Tool ide = ToolFactory.create(4);
        assertTrue(abyss.isCounteredBy(ide));
    }

    @Test
    public void testAbyssPosition() {
        Abyss abyss = AbyssFactory.create(0);
        abyss.setPosition(5);
        assertEquals(5, abyss.getPosition());
    }

    @Test
    public void testToolPosition() {
        Tool tool = ToolFactory.create(0);
        tool.setPosition(5);
        assertEquals(5, tool.getPosition());
    }

    @Test
    public void testAbyssFactoryBoundaryIDs() {
        assertNotNull(AbyssFactory.create(0));
        assertNotNull(AbyssFactory.create(10));
        assertNull(AbyssFactory.create(-1));
        assertNull(AbyssFactory.create(11));
    }

    @Test
    public void testToolFactoryBoundaryIDs() {
        assertNotNull(ToolFactory.create(0));
        assertNotNull(ToolFactory.create(5));
        assertNull(ToolFactory.create(-1));
        assertNull(ToolFactory.create(6));
    }

    @Test
    public void testAllAbyssEffectsDetailedCoverage() {
        Player player = new Player("1", "Test");
        player.addLanguage("Java");

        player.setPosition(5);
        Abyss syntaxError = AbyssFactory.create(0);
        syntaxError.applyEffect(player);
        assertEquals(4, player.getCurrentPosition());

        player.setPosition(10);
        player.setLastDiceRoll(6);
        Abyss logicError = AbyssFactory.create(1);
        logicError.applyEffect(player);
        assertEquals(7, player.getCurrentPosition());

        player.setPosition(10);
        Abyss exception = AbyssFactory.create(2);
        exception.applyEffect(player);
        assertEquals(8, player.getCurrentPosition());

        player.setPosition(10);
        Abyss fileNotFound = AbyssFactory.create(3);
        fileNotFound.applyEffect(player);
        assertEquals(7, player.getCurrentPosition());

        player.setPosition(10);
        Abyss crash = AbyssFactory.create(4);
        crash.applyEffect(player);
        assertEquals(1, player.getCurrentPosition());

        player.setPosition(5);
        player.setPosition(10);
        Abyss duplicateCode = AbyssFactory.create(5);
        duplicateCode.applyEffect(player);
        assertEquals(5, player.getCurrentPosition());

        player.setPosition(3);
        player.setPosition(6);
        player.setPosition(10);
        Abyss sideEffects = AbyssFactory.create(6);
        sideEffects.applyEffect(player);
        assertEquals(3, player.getCurrentPosition());

        player.setStatus("Em Jogo");
        Abyss blueScreen = AbyssFactory.create(7);
        blueScreen.applyEffect(player);
        assertEquals("Derrotado", player.getStatus());

        player.setStatus("Em Jogo");
        Abyss infiniteLoop = AbyssFactory.create(8);
        infiniteLoop.applyEffect(player);
        assertEquals("Preso", player.getStatus());

        player.setStatus("Em Jogo");
        player.setPosition(10);
        Abyss segFault = AbyssFactory.create(9);
        segFault.applyEffect(player);
        assertEquals(7, player.getCurrentPosition());
    }
}
