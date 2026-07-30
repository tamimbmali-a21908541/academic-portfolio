package pt.ulusofona.lp2.greatprogrammingjourney;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;


public class TestStackOverflowAbyss {

    @Test
    public void testStackOverflowAbyssCreation() {
        StackOverflowAbyss abyss = new StackOverflowAbyss();
        assertEquals(10, abyss.getId());
        assertEquals("Stack Overflow", abyss.getName());
        assertEquals("ABYSS", abyss.getType());
    }

    @Test
    public void testStackOverflowAbyssImageName() {
        StackOverflowAbyss abyss = new StackOverflowAbyss();
        assertEquals("stack_overflow.png", abyss.getImageName());
    }

    @Test
    public void testStackOverflowEffectWithShortHistory() {
        Player player = new Player("1", "TestPlayer");
        player.addLanguage("Java");

        player.setPosition(5);
        player.setPosition(8);
        player.setPosition(12);

        StackOverflowAbyss abyss = new StackOverflowAbyss();
        String result = abyss.applyEffect(player);

        assertTrue(player.getCurrentPosition() < 12);
        assertTrue(result.contains("Stack Overflow"));
        assertTrue(result.contains("desfazer"));
        assertTrue(result.contains("chamadas recursivas"));
    }

    @Test
    public void testStackOverflowEffectWithLongHistory() {
        Player player = new Player("2", "LongJourneyPlayer");
        player.addLanguage("Python");

        for (int i = 1; i <= 30; i++) {
            player.setPosition(i);
        }

        int positionBeforeAbyss = player.getCurrentPosition();
        StackOverflowAbyss abyss = new StackOverflowAbyss();
        String result = abyss.applyEffect(player);

        int positionAfterAbyss = player.getCurrentPosition();
        assertTrue(positionAfterAbyss < positionBeforeAbyss);
        assertNotNull(result);
        assertTrue(result.contains("TestPlayer") || result.contains("LongJourneyPlayer"));
    }

    @Test
    public void testStackOverflowMinimumUnwind() {
        Player player = new Player("3", "NewPlayer");
        player.addLanguage("C");

        player.setPosition(2);
        player.setPosition(3);

        StackOverflowAbyss abyss = new StackOverflowAbyss();
        String result = abyss.applyEffect(player);

        assertTrue(player.getCurrentPosition() <= 3);
        assertNotNull(result);
    }

    @Test
    public void testStackOverflowMaximumUnwind() {
        Player player = new Player("4", "ExperiencedPlayer");
        player.addLanguage("Java");

        for (int i = 1; i <= 100; i++) {
            player.setPosition(i);
        }

        int historySize = player.getPositionHistorySize();
        StackOverflowAbyss abyss = new StackOverflowAbyss();
        abyss.applyEffect(player);

        assertTrue(player.getCurrentPosition() >= 80);  
        assertTrue(player.getCurrentPosition() <= 100);
    }

    @Test
    public void testStackOverflowEffectMessageFormat() {
        Player player = new Player("5", "MessageTestPlayer");
        player.addLanguage("Python");

        for (int i = 1; i <= 15; i++) {
            player.setPosition(i);
        }

        StackOverflowAbyss abyss = new StackOverflowAbyss();
        String result = abyss.applyEffect(player);

        assertTrue(result.contains("MessageTestPlayer"));
        assertTrue(result.contains("caiu em"));
        assertTrue(result.contains("Stack Overflow"));
        assertTrue(result.contains("desfazer"));
        assertTrue(result.contains("chamadas recursivas"));
        assertTrue(result.contains("voltando para a posição"));
    }

    @Test
    public void testStackOverflowDoesNotPollutePositionHistory() {
        Player player = new Player("6", "HistoryTestPlayer");
        player.addLanguage("Java");

        for (int i = 1; i <= 10; i++) {
            player.setPosition(i);
        }

        int historySizeBefore = player.getPositionHistorySize();

        StackOverflowAbyss abyss = new StackOverflowAbyss();
        abyss.applyEffect(player);

        int historySizeAfter = player.getPositionHistorySize();

        assertEquals(historySizeBefore, historySizeAfter);
    }

    @Test
    public void testFactoryCreatesStackOverflowAbyss() {
        Abyss abyss = AbyssFactory.create(10);
        assertNotNull(abyss);
        assertTrue(abyss instanceof StackOverflowAbyss);
        assertEquals(10, abyss.getId());
        assertEquals("Stack Overflow", abyss.getName());
    }

    @Test
    public void testStackOverflowCounteredByTools() {
        StackOverflowAbyss abyss = new StackOverflowAbyss();

        Tool unitTests = ToolFactory.create(2);
        Tool ide = ToolFactory.create(4);
        Tool professorHelp = ToolFactory.create(5);

        assertTrue(abyss.isCounteredBy(unitTests), "Should be countered by Unit Tests");
        assertTrue(abyss.isCounteredBy(ide), "Should be countered by IDE");
        assertTrue(abyss.isCounteredBy(professorHelp), "Should be countered by Professor Help");

        Tool inheritance = ToolFactory.create(0);
        Tool functional = ToolFactory.create(1);
        Tool exceptionHandling = ToolFactory.create(3);

        assertFalse(abyss.isCounteredBy(inheritance), "Should not be countered by Inheritance");
        assertFalse(abyss.isCounteredBy(functional), "Should not be countered by Functional Programming");
        assertFalse(abyss.isCounteredBy(exceptionHandling), "Should not be countered by Exception Handling");
    }
}
