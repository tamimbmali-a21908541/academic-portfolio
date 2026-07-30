package pt.ulusofona.lp2.greatprogrammingjourney;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;


public class TestAbyssesAndTools {

    @Test
    public void testAllAbyssesCreated() {
        for (int i = 0; i <= 10; i++) {
            Abyss abyss = AbyssFactory.create(i);
            assertNotNull(abyss, "Abyss with ID " + i + " should be created");
            assertEquals(i, abyss.getId());
            assertEquals("ABYSS", abyss.getType());
        }
    }

    @Test
    public void testAllToolsCreated() {
        for (int i = 0; i <= 5; i++) {
            Tool tool = ToolFactory.create(i);
            assertNotNull(tool, "Tool with ID " + i + " should be created");
            assertEquals(i, tool.getId());
            assertEquals("TOOL", tool.getType());
        }
    }

    @Test
    public void testInheritanceToolCounters() {
        Tool inheritance = ToolFactory.create(0);
        Abyss duplicateCode = AbyssFactory.create(5);

        assertTrue(inheritance.counters(duplicateCode), "Inheritance should counter Duplicate Code");

        Abyss syntaxError = AbyssFactory.create(0);
        assertFalse(inheritance.counters(syntaxError), "Inheritance should not counter Syntax Error");
    }

    @Test
    public void testFunctionalProgrammingToolCounters() {
        Tool functional = ToolFactory.create(1);
        Abyss sideEffects = AbyssFactory.create(6);
        Abyss infiniteLoop = AbyssFactory.create(8);

        assertTrue(functional.counters(sideEffects), "Functional Programming should counter Side Effects");
        assertTrue(functional.counters(infiniteLoop), "Functional Programming should counter Infinite Loop");

        Abyss crash = AbyssFactory.create(4);
        assertFalse(functional.counters(crash), "Functional Programming should not counter Crash");
    }

    @Test
    public void testUnitTestsToolCounters() {
        Tool unitTests = ToolFactory.create(2);
        Abyss logicError = AbyssFactory.create(1);

        assertTrue(unitTests.counters(logicError), "Unit Tests should counter Logic Error");

        Abyss exception = AbyssFactory.create(2);
        assertFalse(unitTests.counters(exception), "Unit Tests should not counter Exception");
    }

    @Test
    public void testExceptionHandlingToolCounters() {
        Tool exceptionHandling = ToolFactory.create(3);
        Abyss exception = AbyssFactory.create(2);
        Abyss fileNotFound = AbyssFactory.create(3);

        assertTrue(exceptionHandling.counters(exception), "Exception Handling should counter Exception");
        assertTrue(exceptionHandling.counters(fileNotFound), "Exception Handling should counter FileNotFoundException");
    }

    @Test
    public void testIDEToolCounters() {
        Tool ide = ToolFactory.create(4);
        Abyss syntaxError = AbyssFactory.create(0);
        Abyss exception = AbyssFactory.create(2);

        assertTrue(ide.counters(syntaxError), "IDE should counter Syntax Error");
        assertTrue(ide.counters(exception), "IDE should counter Exception");
    }

    @Test
    public void testProfessorHelpToolCounters() {
        Tool professorHelp = ToolFactory.create(5);
        Abyss crash = AbyssFactory.create(4);
        Abyss blueScreen = AbyssFactory.create(7);
        Abyss segFault = AbyssFactory.create(9);
        Abyss infiniteLoop = AbyssFactory.create(8);

        assertTrue(professorHelp.counters(crash), "Professor Help should counter Crash");
        assertTrue(professorHelp.counters(blueScreen), "Professor Help should counter Blue Screen");
        assertTrue(professorHelp.counters(segFault), "Professor Help should counter Segmentation Fault");
        assertFalse(professorHelp.counters(infiniteLoop), "Professor Help should not counter Infinite Loop");
    }

    @Test
    public void testToolApplicationAddsToInventory() {
        Player player = new Player("1", "TestPlayer");
        player.addLanguage("Java");

        Tool tool = ToolFactory.create(0);  
        String result = tool.applyEffect(player);

        assertTrue(player.hasTool(0), "Player should have the tool in inventory");
        assertTrue(result.contains("apanhou"), "Result should mention player picked up tool");
    }

    @Test
    public void testPlayerMultipleTools() {
        Player player = new Player("2", "MultiToolPlayer");
        player.addLanguage("Python");

        for (int i = 0; i <= 5; i++) {
            Tool tool = ToolFactory.create(i);
            tool.applyEffect(player);
        }

        for (int i = 0; i <= 5; i++) {
            assertTrue(player.hasTool(i), "Player should have tool " + i);
        }
    }

    @Test
    public void testPlayerFindCounterTool() {
        Player player = new Player("3", "CounterPlayer");
        player.addLanguage("Java");

        Tool inheritance = ToolFactory.create(0);
        player.addTool(inheritance);

        Abyss duplicateCode = AbyssFactory.create(5);
        Tool counterTool = player.findCounterTool(duplicateCode);

        assertNotNull(counterTool, "Player should find counter tool");
        assertEquals(0, counterTool.getId(), "Counter tool should be Inheritance");
    }

    @Test
    public void testPlayerNoCounterTool() {
        Player player = new Player("4", "NoCounterPlayer");
        player.addLanguage("C");

        Tool inheritance = ToolFactory.create(0);
        player.addTool(inheritance);

        Abyss crash = AbyssFactory.create(4);
        Tool counterTool = player.findCounterTool(crash);

        assertNull(counterTool, "Player should not find counter tool");
    }

    @Test
    public void testAbyssNames() {
        Abyss syntaxError = AbyssFactory.create(0);
        assertEquals("Erro de sintaxe", syntaxError.getName());

        Abyss logicError = AbyssFactory.create(1);
        assertEquals("Erro de Lógica", logicError.getName());

        Abyss exception = AbyssFactory.create(2);
        assertEquals("Exception", exception.getName());

        Abyss stackOverflow = AbyssFactory.create(10);
        assertEquals("Stack Overflow", stackOverflow.getName());
    }

    @Test
    public void testToolNames() {
        Tool inheritance = ToolFactory.create(0);
        assertEquals("Herança", inheritance.getName());

        Tool functional = ToolFactory.create(1);
        assertEquals("Programação Funcional", functional.getName());

        Tool unitTests = ToolFactory.create(2);
        assertEquals("Testes Unitários", unitTests.getName());
    }

    @Test
    public void testInvalidFileException() {
        InvalidFileException ex = new InvalidFileException("Test error");
        assertEquals("Test error", ex.getMessage());
        assertTrue(ex instanceof Exception);
    }

    @Test
    public void testPlayerPositionHistoryTracking() {
        Player player = new Player("5", "HistoryPlayer");
        player.addLanguage("Java");

        player.setPosition(5);
        player.setPosition(10);
        player.setPosition(15);

        assertEquals(4, player.getPositionHistorySize());  // 1 (start) + 3 moves
        assertEquals(15, player.getCurrentPosition());
        assertEquals(10, player.getPreviousPosition());
    }

    @Test
    public void testPlayerPositionFromEffectDoesNotPollute() {
        Player player = new Player("6", "EffectPlayer");
        player.addLanguage("Python");

        player.setPosition(5);
        player.setPosition(10);

        int historySizeBefore = player.getPositionHistorySize();
        int previousPositionBefore = player.getPreviousPosition();  // Should be 5

        player.setPositionFromEffect(3);

        int historySizeAfter = player.getPositionHistorySize();

        assertEquals(historySizeBefore, historySizeAfter, "History should not change");
        assertEquals(3, player.getCurrentPosition());
        assertEquals(previousPositionBefore, player.getPreviousPosition(), "Previous position should not change");
    }
}
