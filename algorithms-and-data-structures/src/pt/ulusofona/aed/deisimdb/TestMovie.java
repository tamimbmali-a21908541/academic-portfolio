package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.Test;

import java.text.ParseException;

import static org.junit.jupiter.api.Assertions.*;

public class TestMovie {

    // Test movie toString for id >= 1000
    @Test
    public void testMovieToStringHighId() throws ParseException {
        Movie movie = new Movie(1234, "Test Movie", 120.0, 1000000, DateUtils.parseDate("01-01-2023"));
        assertEquals("1234 | Test Movie | 2023-01-01", movie.toString());
    }

    @Test
    public void testMovieToStringHighId2() throws ParseException {
        Movie movie = new Movie(9999, "Another Test Movie", 90.5, 500000, DateUtils.parseDate("15-06-2022"));
        assertEquals("9999 | Another Test Movie | 2022-06-15", movie.toString());
    }

    @Test
    public void testMovieToStringHighId3() throws ParseException {
        Movie movie = new Movie(5000, "Third Test Movie", 145.0, 2000000, DateUtils.parseDate("30-12-2023"));
        assertEquals("5000 | Third Test Movie | 2023-12-30", movie.toString());
    }

    @Test
    public void testMovieToStringHighId4() throws ParseException {
        Movie movie = new Movie(1500, "Fourth Test Movie", 110.5, 750000, DateUtils.parseDate("10-03-2024"));
        assertEquals("1500 | Fourth Test Movie | 2024-03-10", movie.toString());
    }

    @Test
    public void testMovieToStringHighId5() throws ParseException {
        Movie movie = new Movie(2500, "Fifth Test Movie", 135.75, 1250000, DateUtils.parseDate("22-09-2021"));
        assertEquals("2500 | Fifth Test Movie | 2021-09-22", movie.toString());
    }

    // Test movie toString for id < 1000
    @Test
    public void testMovieToStringLowId() throws ParseException {
        Movie movie = new Movie(123, "Test Movie", 120.0, 1000000, DateUtils.parseDate("01-01-2023"));
        // Add actor to test actor count in toString()
        Actor actor = new Actor(1, "Test Actor", 'M', 123);
        movie.addActor(actor);
        actor.addMovie(movie);
        assertEquals("123 | Test Movie | 2023-01-01 | 1", movie.toString());
    }

    @Test
    public void testMovieToStringLowId2() throws ParseException {
        Movie movie = new Movie(99, "Another Low ID Movie", 95.0, 300000, DateUtils.parseDate("05-07-2022"));
        // Add two actors
        Actor actor1 = new Actor(2, "Actor One", 'M', 99);
        Actor actor2 = new Actor(3, "Actor Two", 'F', 99);
        movie.addActor(actor1);
        movie.addActor(actor2);
        actor1.addMovie(movie);
        actor2.addMovie(movie);
        assertEquals("99 | Another Low ID Movie | 2022-07-05 | 2", movie.toString());
    }

    @Test
    public void testMovieToStringLowId3() throws ParseException {
        Movie movie = new Movie(456, "Third Low ID Movie", 125.5, 800000, DateUtils.parseDate("18-11-2023"));
        // Add three actors
        Actor actor1 = new Actor(4, "Actor Three", 'M', 456);
        Actor actor2 = new Actor(5, "Actor Four", 'F', 456);
        Actor actor3 = new Actor(6, "Actor Five", 'M', 456);
        movie.addActor(actor1);
        movie.addActor(actor2);
        movie.addActor(actor3);
        actor1.addMovie(movie);
        actor2.addMovie(movie);
        actor3.addMovie(movie);
        assertEquals("456 | Third Low ID Movie | 2023-11-18 | 3", movie.toString());
    }

    @Test
    public void testMovieToStringLowId4() throws ParseException {
        Movie movie = new Movie(7, "Fourth Low ID Movie", 105.25, 450000, DateUtils.parseDate("29-02-2024"));
        // No actors added, should show 0
        assertEquals("7 | Fourth Low ID Movie | 2024-02-29 | 0", movie.toString());
    }

    @Test
    public void testMovieToStringLowId5() throws ParseException {
        Movie movie = new Movie(888, "Fifth Low ID Movie", 150.0, 1800000, DateUtils.parseDate("01-04-2021"));
        // Add one actor
        Actor actor = new Actor(7, "Last Actor", 'F', 888);
        movie.addActor(actor);
        actor.addMovie(movie);
        assertEquals("888 | Fifth Low ID Movie | 2021-04-01 | 1", movie.toString());
    }
}