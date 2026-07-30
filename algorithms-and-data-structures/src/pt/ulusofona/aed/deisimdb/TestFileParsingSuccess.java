package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test class specifically for successful file parsing scenarios
 */
public class TestFileParsingSuccess {

    private final String TEST_FOLDER = "test-files";

    @BeforeEach
    public void setUp() throws IOException {
        // Create test directory
        File testDir = new File(TEST_FOLDER);
        if (!testDir.exists()) {
            testDir.mkdir();
        }

        // Create test data files
        createMoviesFile();
        createActorsFile();
        createDirectorsFile();
        createGenresFile();
        createGenresMoviesFile();
        createMovieVotesFile();
    }

    private void createMoviesFile() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/movies.csv")) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Test Movie 1,120.0,1000000,01-01-2023\n");
            writer.write("102,Test Movie 2,90.5,500000,15-06-2022\n");
            writer.write("103,Test Movie 3,145.0,2000000,30-12-2023\n");
        }
    }

    private void createActorsFile() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/actors.csv")) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
            writer.write("202,Actor Two,F,101\n");
            writer.write("203,Actor Three,M,102\n");
            writer.write("204,Actor Four,F,102\n");
            writer.write("205,Actor Five,M,103\n");
        }
    }

    private void createDirectorsFile() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/directors.csv")) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
            writer.write("302,Director Two,102\n");
            writer.write("303,Director Three,103\n");
        }
    }

    private void createGenresFile() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/genres.csv")) {
            writer.write("genreId,genreName\n");
            writer.write("401,Action\n");
            writer.write("402,Comedy\n");
            writer.write("403,Drama\n");
            writer.write("404,Sci-Fi\n");
        }
    }

    private void createGenresMoviesFile() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/genres_movies.csv")) {
            writer.write("genreId,movieId\n");
            writer.write("401,101\n");
            writer.write("402,101\n");
            writer.write("403,102\n");
            writer.write("404,103\n");
        }
    }

    private void createMovieVotesFile() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/movie_votes.csv")) {
            writer.write("movieId,movieRating,movieRatingCount\n");
            writer.write("101,8.5,100\n");
            writer.write("102,7.2,50\n");
            writer.write("103,9.0,75\n");
        }
    }

    @Test
    public void testCompleteFileParsing1() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed");
        
        // Verify movies were loaded with correct data
        ArrayList<Object> movies = Main.getObjects(TipoEntidade.FILME);
        assertEquals(3, movies.size(), "Should load 3 movies");
        
        // Verify first movie has expected properties and relationships
        Movie movie = (Movie) movies.get(0);
        assertEquals(101, movie.getId(), "Movie ID should match");
        assertEquals("Test Movie 1", movie.getName(), "Movie name should match");
        assertEquals(120.0, movie.getDuration(), "Movie duration should match");
        assertEquals(1000000, movie.getBudget(), "Movie budget should match");
        assertEquals(2, movie.getActors().size(), "Movie should have 2 actors");
        assertEquals(1, movie.getDirectors().size(), "Movie should have 1 director");
        assertEquals(2, movie.getGenres().size(), "Movie should have 2 genres");
        assertEquals(8.5, movie.getRating(), "Movie rating should match");
        assertEquals(100, movie.getRatingCount(), "Movie rating count should match");
    }

    @Test
    public void testCompleteFileParsing2() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed");
        
        // Verify actors were loaded
        ArrayList<Object> actors = Main.getObjects(TipoEntidade.ATOR);
        assertEquals(5, actors.size(), "Should load 5 actors");
        
        // Verify first actor has expected properties and relationships
        Actor actor = (Actor) actors.get(0);
        assertEquals(201, actor.getId(), "Actor ID should match");
        assertEquals("Actor One", actor.getName(), "Actor name should match");
        assertEquals('M', actor.getGender(), "Actor gender should match");
        assertEquals(1, actor.getMovies().size(), "Actor should be in 1 movie");
        assertEquals(101, actor.getMovies().get(0).getId(), "Actor's movie ID should match");
    }

    @Test
    public void testCompleteFileParsing3() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed");
        
        // Verify directors were loaded
        ArrayList<Object> directors = Main.getObjects(TipoEntidade.REALIZADOR);
        assertEquals(3, directors.size(), "Should load 3 directors");
        
        // Verify first director has expected properties and relationships
        Director director = (Director) directors.get(0);
        assertEquals(301, director.getId(), "Director ID should match");
        assertEquals("Director One", director.getName(), "Director name should match");
        assertEquals(1, director.getMovies().size(), "Director should have 1 movie");
        assertEquals(101, director.getMovies().get(0).getId(), "Director's movie ID should match");
    }

    @Test
    public void testCompleteFileParsing4() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed");
        
        // Verify genres were loaded
        ArrayList<Object> genres = Main.getObjects(TipoEntidade.GENERO);
        assertEquals(4, genres.size(), "Should load 4 genres");
        
        // Verify genres are attached to correct movies
        Genre genre = (Genre) genres.get(0);
        assertEquals(404, genre.getId(), "Genre ID should match");
        assertEquals("Sci-Fi", genre.getName(), "Genre name should match");
        assertTrue(genre.getMovies().size() > 0, "Genre should be associated with at least one movie");
    }

    @Test
    public void testCompleteFileParsing5() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed");
        
        // Verify bidirectional relationships
        ArrayList<Object> movies = Main.getObjects(TipoEntidade.FILME);
        Movie movie = (Movie) movies.get(0);
        
        // Verify movie-actor relationship is bidirectional
        for (Actor actor : movie.getActors()) {
            assertTrue(actor.getMovies().contains(movie), 
                    "Actor should have reference to the movie that references it");
        }
        
        // Verify movie-director relationship is bidirectional
        for (Director director : movie.getDirectors()) {
            assertTrue(director.getMovies().contains(movie), 
                    "Director should have reference to the movie that references it");
        }
        
        // Verify movie-genre relationship is bidirectional
        for (Genre genre : movie.getGenres()) {
            assertTrue(genre.getMovies().contains(movie), 
                    "Genre should have reference to the movie that references it");
        }
    }
}
