package pt.ulusofona.aed.deisimdb;

import java.text.ParseException;
import java.util.Date;

public class MovieToStringTest {
    public static void main(String[] args) throws ParseException {
        // Create a test movie with ID >= 1000
        Movie movie = new Movie(1603, "The Matrix", 136.0, 63000000, DateUtils.parseDate("30-03-1999"));
        
        // Add actors, directors, genres, and rating info
        Actor actor = new Actor(1, "Keanu Reeves", 'M', 1603);
        Director director1 = new Director(1, "Lana Wachowski");
        Director director2 = new Director(2, "Lilly Wachowski");
        Genre genre = new Genre(1, "Science Fiction");
        
        movie.addActor(actor);
        movie.addDirector(director1);
        movie.addDirector(director2);
        movie.addGenre(genre);
        movie.setRating(8.7, 1);
        
        // Print the toString representation
        System.out.println("Movie toString() output:");
        System.out.println(movie.toString());
        System.out.println("\nExpected output:");
        System.out.println("1603 | The Matrix | 1999-03-30 | 1 | 2 | 1 | 1");
    }
}