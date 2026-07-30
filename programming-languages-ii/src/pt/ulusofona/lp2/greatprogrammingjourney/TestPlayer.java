package pt.ulusofona.lp2.greatprogrammingjourney;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class TestPlayer {

    @Test
    public void testPlayerCreation() {
        Player player = new Player("1", "Alice");
        assertEquals("1", player.getId(), "Player ID should match");
        assertEquals("Alice", player.getName(), "Player name should match");
        assertEquals(1, player.getCurrentPosition(), "Initial position should be 1");
        assertEquals("Em Jogo", player.getStatus(), "Initial status should be 'Em Jogo'");
    }

    @Test
    public void testAddLanguage() {
        Player player = new Player("1", "Alice");
        player.addLanguage("Java");
        player.addLanguage("Python");

        assertEquals(2, player.getLanguages().size(), "Player should have 2 languages");
        assertTrue(player.getLanguages().contains("Java"), "Player should know Java");
        assertTrue(player.getLanguages().contains("Python"), "Player should know Python");
    }

    @Test
    public void testGetLanguagesAsString() {
        Player player = new Player("1", "Alice");
        player.addLanguage("Java");
        player.addLanguage("Python");
        player.addLanguage("C++");

        String langString = player.getLanguagesAsString();
        assertEquals("C++; Java; Python", langString, "Languages should be sorted alphabetically");
    }

    @Test
    public void testMoveBy() {
        Player player = new Player("1", "Alice");
        assertEquals(1, player.getCurrentPosition(), "Initial position should be 1");

        player.moveBy(5);
        assertEquals(6, player.getCurrentPosition(), "Position should be 6 after moving by 5");

        player.moveBy(3);
        assertEquals(9, player.getCurrentPosition(), "Position should be 9 after moving by 3 more");
    }

    @Test
    public void testSetPosition() {
        Player player = new Player("1", "Alice");
        player.setPosition(10);
        assertEquals(10, player.getCurrentPosition(), "Position should be set to 10");
    }

    @Test
    public void testSetColor() {
        Player player = new Player("1", "Alice");
        player.setColor("red");
        assertEquals("red", player.getColor(), "Color should be set to red");
    }

    @Test
    public void testSetStatus() {
        Player player = new Player("1", "Alice");
        player.setStatus("Finished");
        assertEquals("Finished", player.getStatus(), "Status should be updated to Finished");
    }

    @Test
    public void testGetLanguagesAsStringEmpty() {
        Player player = new Player("1", "Alice");
        assertEquals("", player.getLanguagesAsString());
    }

    @Test
    public void testGetLanguagesAsStringSingleLanguage() {
        Player player = new Player("1", "Alice");
        player.addLanguage("Java");
        assertEquals("Java", player.getLanguagesAsString());
    }

    @Test
    public void testGetPositionFromNMovesAgoBasic() {
        Player player = new Player("1", "Alice");
        player.setPosition(5);
        player.setPosition(10);
        player.setPosition(15);

        assertEquals(15, player.getPositionFromNMovesAgo(0));
        assertEquals(10, player.getPositionFromNMovesAgo(1));
        assertEquals(5, player.getPositionFromNMovesAgo(2));
        assertEquals(1, player.getPositionFromNMovesAgo(3));
    }

    @Test
    public void testGetPositionFromNMovesAgoExceedsHistory() {
        Player player = new Player("1", "Alice");
        player.setPosition(5);

        assertEquals(1, player.getPositionFromNMovesAgo(10));
        assertEquals(1, player.getPositionFromNMovesAgo(100));
    }

    @Test
    public void testIsTrapped() {
        Player player = new Player("1", "Alice");
        assertFalse(player.isTrapped());

        player.setStatus("Preso");
        assertTrue(player.isTrapped());

        player.setStatus("Em Jogo");
        assertFalse(player.isTrapped());
    }

    @Test
    public void testIsEliminated() {
        Player player = new Player("1", "Alice");
        assertFalse(player.isEliminated());

        player.setStatus("Derrotado");
        assertTrue(player.isEliminated());

        player.setStatus("Em Jogo");
        assertFalse(player.isEliminated());
    }

    @Test
    public void testRemoveTool() {
        Player player = new Player("1", "Alice");
        Tool tool1 = ToolFactory.create(0);
        Tool tool2 = ToolFactory.create(1);

        player.addTool(tool1);
        player.addTool(tool2);
        assertEquals(2, player.getTools().size());

        player.removeTool(tool1);
        assertEquals(1, player.getTools().size());
        assertFalse(player.hasTool(0));
        assertTrue(player.hasTool(1));
    }

    @Test
    public void testRemoveToolNotPresent() {
        Player player = new Player("1", "Alice");
        Tool tool1 = ToolFactory.create(0);
        Tool tool2 = ToolFactory.create(1);

        player.addTool(tool1);
        player.removeTool(tool2);

        assertEquals(1, player.getTools().size());
        assertTrue(player.hasTool(0));
    }

    @Test
    public void testGetToolsAsStringEmpty() {
        Player player = new Player("1", "Alice");
        assertEquals("", player.getToolsAsString());
    }

    @Test
    public void testGetToolsAsStringSingleTool() {
        Player player = new Player("1", "Alice");
        player.addTool(ToolFactory.create(0));
        assertEquals("Herança", player.getToolsAsString());
    }

    @Test
    public void testGetToolsAsStringMultipleToolsSorted() {
        Player player = new Player("1", "Alice");
        player.addTool(ToolFactory.create(2));
        player.addTool(ToolFactory.create(0));
        player.addTool(ToolFactory.create(1));

        String result = player.getToolsAsString();
        assertEquals("Herança;Programação Funcional;Testes Unitários", result);
    }

    @Test
    public void testGetToolIdsAsStringEmpty() {
        Player player = new Player("1", "Alice");
        assertEquals("", player.getToolIdsAsString());
    }

    @Test
    public void testGetToolIdsAsStringSingleTool() {
        Player player = new Player("1", "Alice");
        player.addTool(ToolFactory.create(3));
        assertEquals("3", player.getToolIdsAsString());
    }

    @Test
    public void testGetToolIdsAsStringMultipleTools() {
        Player player = new Player("1", "Alice");
        player.addTool(ToolFactory.create(0));
        player.addTool(ToolFactory.create(2));
        player.addTool(ToolFactory.create(4));

        assertEquals("0;2;4", player.getToolIdsAsString());
    }

    @Test
    public void testLastDiceRollInitialValue() {
        Player player = new Player("1", "Alice");
        assertEquals(0, player.getLastDiceRoll());
    }

    @Test
    public void testSetAndGetLastDiceRoll() {
        Player player = new Player("1", "Alice");
        player.setLastDiceRoll(5);
        assertEquals(5, player.getLastDiceRoll());

        player.setLastDiceRoll(1);
        assertEquals(1, player.getLastDiceRoll());

        player.setLastDiceRoll(6);
        assertEquals(6, player.getLastDiceRoll());
    }

    @Test
    public void testGetPositionFromHistoryValid() {
        Player player = new Player("1", "Alice");
        player.setPosition(5);
        player.setPosition(10);
        player.setPosition(15);

        assertEquals(1, player.getPositionFromHistory(0));
        assertEquals(5, player.getPositionFromHistory(1));
        assertEquals(10, player.getPositionFromHistory(2));
        assertEquals(15, player.getPositionFromHistory(3));
    }

    @Test
    public void testGetPositionFromHistoryInvalidIndex() {
        Player player = new Player("1", "Alice");
        player.setPosition(5);

        assertEquals(1, player.getPositionFromHistory(-1));
        assertEquals(1, player.getPositionFromHistory(100));
    }

    @Test
    public void testPreviousPositionUpdates() {
        Player player = new Player("1", "Alice");
        assertEquals(1, player.getPreviousPosition());

        player.setPosition(5);
        assertEquals(1, player.getPreviousPosition());

        player.setPosition(10);
        assertEquals(5, player.getPreviousPosition());

        player.setPosition(20);
        assertEquals(10, player.getPreviousPosition());
    }

    @Test
    public void testInitialColorIsEmpty() {
        Player player = new Player("1", "Alice");
        assertEquals("", player.getColor());
    }

    @Test
    public void testHasToolReturnsFalseWhenEmpty() {
        Player player = new Player("1", "Alice");
        for (int i = 0; i <= 5; i++) {
            assertFalse(player.hasTool(i));
        }
    }

    @Test
    public void testGetToolsReturnsCorrectList() {
        Player player = new Player("1", "Alice");
        Tool tool1 = ToolFactory.create(0);
        Tool tool2 = ToolFactory.create(1);

        player.addTool(tool1);
        player.addTool(tool2);

        assertEquals(2, player.getTools().size());
        assertTrue(player.getTools().contains(tool1));
        assertTrue(player.getTools().contains(tool2));
    }

    @Test
    public void testPositionHistorySizeAfterMultipleMoves() {
        Player player = new Player("1", "Alice");
        assertEquals(1, player.getPositionHistorySize());

        player.setPosition(5);
        assertEquals(2, player.getPositionHistorySize());

        player.setPosition(10);
        assertEquals(3, player.getPositionHistorySize());

        player.setPosition(15);
        assertEquals(4, player.getPositionHistorySize());
    }

    @Test
    public void testMoveByNegative() {
        Player player = new Player("1", "Alice");
        player.moveBy(10);
        assertEquals(11, player.getCurrentPosition());

        player.moveBy(-5);
        assertEquals(6, player.getCurrentPosition());
    }

    @Test
    public void testSetPositionFromEffectDoesNotChangeHistory() {
        Player player = new Player("1", "Alice");
        player.setPosition(5);
        player.setPosition(10);

        int historyBefore = player.getPositionHistorySize();
        int previousBefore = player.getPreviousPosition();

        player.setPositionFromEffect(1);

        assertEquals(historyBefore, player.getPositionHistorySize());
        assertEquals(previousBefore, player.getPreviousPosition());
        assertEquals(1, player.getCurrentPosition());
    }

    @Test
    public void testFindCounterToolReturnsNullWhenNoTools() {
        Player player = new Player("1", "Alice");
        Abyss abyss = AbyssFactory.create(0);

        assertNull(player.findCounterTool(abyss));
    }

    @Test
    public void testFindCounterToolReturnsFirstMatch() {
        Player player = new Player("1", "Alice");
        player.addTool(ToolFactory.create(3));
        player.addTool(ToolFactory.create(4));

        Abyss exception = AbyssFactory.create(2);
        Tool counter = player.findCounterTool(exception);

        assertNotNull(counter);
        assertEquals(3, counter.getId());
    }
}
