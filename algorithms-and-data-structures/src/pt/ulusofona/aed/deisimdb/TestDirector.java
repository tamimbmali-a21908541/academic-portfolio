package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class TestDirector {

    @Test
    public void testDirectorToString() {
        Director director = new Director(123, "Test Director");
        // Create a movie and associate it with the director
        Movie movie = new Movie(456, "Test Movie", 120.0, 1000000, null);
        director.addMovie(movie);
        assertEquals("123 | Test Director | 456", director.toString());
    }

    @Test
    public void testDirectorToString2() {
        Director director = new Director(456, "Second Director");
        // Create a movie and associate it with the director
        Movie movie = new Movie(789, "Test Movie 2", 95.0, 500000, null);
        director.addMovie(movie);
        assertEquals("456 | Second Director | 789", director.toString());
    }

    @Test
    public void testDirectorToString3() {
        Director director = new Director(789, "Third Director");
        // Create a movie and associate it with the director
        Movie movie = new Movie(123, "Test Movie 3", 110.0, 750000, null);
        director.addMovie(movie);
        assertEquals("789 | Third Director | 123", director.toString());
    }

    @Test
    public void testDirectorToString4() {
        Director director = new Director(12, "Fourth Director");
        // Create a movie and associate it with the director
        Movie movie = new Movie(345, "Test Movie 4", 130.0, 1200000, null);
        director.addMovie(movie);
        assertEquals("12 | Fourth Director | 345", director.toString());
    }

    @Test
    public void testDirectorToString5() {
        Director director = new Director(9999, "Fifth Director");
        // Create a movie and associate it with the director
        Movie movie = new Movie(678, "Test Movie 5", 115.0, 900000, null);
        director.addMovie(movie);
        assertEquals("9999 | Fifth Director | 678", director.toString());
    }
}