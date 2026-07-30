package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class TestGenre {

    @Test
    public void testGenreToString() {
        Genre genre = new Genre(123, "Test Genre");
        assertEquals("123 | Test Genre", genre.toString());
    }

    @Test
    public void testGenreToString2() {
        Genre genre = new Genre(456, "Action");
        assertEquals("456 | Action", genre.toString());
    }

    @Test
    public void testGenreToString3() {
        Genre genre = new Genre(789, "Comedy");
        assertEquals("789 | Comedy", genre.toString());
    }

    @Test
    public void testGenreToString4() {
        Genre genre = new Genre(12, "Horror");
        assertEquals("12 | Horror", genre.toString());
    }

    @Test
    public void testGenreToString5() {
        Genre genre = new Genre(9999, "Sci-Fi");
        assertEquals("9999 | Sci-Fi", genre.toString());
    }
}