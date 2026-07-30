package pt.ulusofona.lp2.greatprogrammingjourney;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;


public class TestEdgeCases {

    @Test
    public void testAbyssFactoryInvalidIDs() {
        assertNull(AbyssFactory.create(-1), "Negative ID should return null");
        assertNull(AbyssFactory.create(11), "ID > 10 should return null");
        assertNull(AbyssFactory.create(100), "Large invalid ID should return null");
    }

    @Test
    public void testToolFactoryInvalidIDs() {
        assertNull(ToolFactory.create(-1), "Negative ID should return null");
        assertNull(ToolFactory.create(6), "ID > 5 should return null");
        assertNull(ToolFactory.create(100), "Large invalid ID should return null");
    }

    @Test
    public void testToolAppliedMultipleTimes() {
        Player player = new Player("1", "TestPlayer");
        player.addLanguage("Java");

        Tool tool = ToolFactory.create(0);
        tool.applyEffect(player);

        String result = tool.applyEffect(player);

        assertTrue(player.hasTool(0));
        assertNotNull(result);
    }

    @Test
    public void testPlayerEmptyPositionHistory() {
        Player player = new Player("1", "TestPlayer");
        player.addLanguage("Python");

        assertTrue(player.getPositionHistorySize() >= 1);
    }

    @Test
    public void testPlayerVeryLongPositionHistory() {
        Player player = new Player("1", "LongJourneyPlayer");
        player.addLanguage("Java");

        for (int i = 1; i <= 200; i++) {
            player.setPosition(i);
        }

        assertTrue(player.getPositionHistorySize() > 100);
        assertEquals(200, player.getCurrentPosition());
    }

    @Test
    public void testAbyssEffectAtPosition1() {
        Player player = new Player("1", "TestPlayer");
        player.addLanguage("C");
        player.setPosition(1);

        Abyss logicError = AbyssFactory.create(1);
        logicError.applyEffect(player);

        assertTrue(player.getCurrentPosition() >= 1);
    }

    @Test
    public void testAllToolsCounterSomething() {
        for (int toolId = 0; toolId <= 5; toolId++) {
            Tool tool = ToolFactory.create(toolId);
            boolean countersAny = false;

            for (int abyssId = 0; abyssId <= 10; abyssId++) {
                Abyss abyss = AbyssFactory.create(abyssId);
                if (tool.counters(abyss)) {
                    countersAny = true;
                    break;
                }
            }

            assertTrue(countersAny, "Tool " + toolId + " should counter at least one abyss");
        }
    }

    @Test
    public void testAllAbyssesCanBeCountered() {
        for (int abyssId = 0; abyssId <= 10; abyssId++) {
            Abyss abyss = AbyssFactory.create(abyssId);
            boolean canBeCountered = false;

            for (int toolId = 0; toolId <= 5; toolId++) {
                Tool tool = ToolFactory.create(toolId);
                if (abyss.isCounteredBy(tool)) {
                    canBeCountered = true;
                    break;
                }
            }

            assertTrue(canBeCountered, "Abyss " + abyssId + " should be counterable by at least one tool");
        }
    }

    @Test
    public void testAllAbyssImageNames() {
        for (int i = 0; i <= 10; i++) {
            Abyss abyss = AbyssFactory.create(i);
            assertNotNull(abyss.getImageName(), "Abyss " + i + " should have image name");
            assertFalse(abyss.getImageName().isEmpty(), "Abyss " + i + " image name should not be empty");
        }
    }

    @Test
    public void testAllToolImageNames() {
        for (int i = 0; i <= 5; i++) {
            Tool tool = ToolFactory.create(i);
            assertNotNull(tool.getImageName(), "Tool " + i + " should have image name");
            assertFalse(tool.getImageName().isEmpty(), "Tool " + i + " image name should not be empty");
        }
    }

    @Test
    public void testAllAbyssTypes() {
        for (int i = 0; i <= 10; i++) {
            Abyss abyss = AbyssFactory.create(i);
            assertEquals("ABYSS", abyss.getType(), "Abyss " + i + " should have type ABYSS");
        }
    }

    @Test
    public void testAllToolTypes() {
        for (int i = 0; i <= 5; i++) {
            Tool tool = ToolFactory.create(i);
            assertEquals("TOOL", tool.getType(), "Tool " + i + " should have type TOOL");
        }
    }

    @Test
    public void testPlayerWithMultipleToolsFindsCorrectCounter() {
        Player player = new Player("1", "MultiToolPlayer");
        player.addLanguage("Java");

        player.addTool(ToolFactory.create(0)); 
        player.addTool(ToolFactory.create(1)); 
        player.addTool(ToolFactory.create(2)); 

        Abyss duplicateCode = AbyssFactory.create(5); 
        Tool counter1 = player.findCounterTool(duplicateCode);
        assertNotNull(counter1);
        assertEquals(0, counter1.getId());

        Abyss sideEffects = AbyssFactory.create(6); 
        Tool counter2 = player.findCounterTool(sideEffects);
        assertNotNull(counter2);
        assertEquals(1, counter2.getId());

        Abyss logicError = AbyssFactory.create(1); 
        Tool counter3 = player.findCounterTool(logicError);
        assertNotNull(counter3);
        assertEquals(2, counter3.getId());
    }

    @Test
    public void testStackOverflowWithExactlyThreePositions() {
        Player player = new Player("1", "ThreePositionPlayer");
        player.addLanguage("Java");

        player.setPosition(1);
        player.setPosition(2);
        player.setPosition(3);

        int historySize = player.getPositionHistorySize();

        StackOverflowAbyss abyss = new StackOverflowAbyss();
        abyss.applyEffect(player);

        assertTrue(player.getCurrentPosition() <= 3);
        assertEquals(historySize, player.getPositionHistorySize()); // History unchanged
    }

    @Test
    public void testAllAbyssesApplyEffectSuccessfully() {
        Player player = new Player("1", "TestPlayer");
        player.addLanguage("Java");
        player.setPosition(10);

        for (int i = 0; i <= 10; i++) {
            Player testPlayer = new Player(String.valueOf(i), "Player" + i);
            testPlayer.addLanguage("Python");
            testPlayer.setPosition(10);

            Abyss abyss = AbyssFactory.create(i);
            String result = abyss.applyEffect(testPlayer);

            assertNotNull(result, "Abyss " + i + " should return non-null message");
            assertFalse(result.isEmpty(), "Abyss " + i + " should return non-empty message");
        }
    }

    @Test
    public void testAllToolsApplyEffectSuccessfully() {
        for (int i = 0; i <= 5; i++) {
            Player testPlayer = new Player(String.valueOf(i), "Player" + i);
            testPlayer.addLanguage("Java");

            Tool tool = ToolFactory.create(i);
            String result = tool.applyEffect(testPlayer);

            assertNotNull(result, "Tool " + i + " should return non-null message");
            assertFalse(result.isEmpty(), "Tool " + i + " should return non-empty message");
            assertTrue(testPlayer.hasTool(i), "Player should have tool " + i + " after applying it");
        }
    }
}
