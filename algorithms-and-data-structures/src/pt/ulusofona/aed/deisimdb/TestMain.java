package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

public class TestMain {

    private final String TEST_FOLDER = "test-files";
    private final String TEST_ERROR_FOLDER = "test-files-with-errors";

    @BeforeEach
    public void setUp() {
        try {
            // Create test directories
            createDirectory(TEST_FOLDER);
            createDirectory(TEST_ERROR_FOLDER);
            
            // Create standard test files
            createTestFiles(TEST_FOLDER);
            
            // Create test files with errors
            createErrorTestFiles(TEST_ERROR_FOLDER);
        } catch (IOException e) {
            fail("Failed to create test files: " + e.getMessage());
        }
    }
    
    private void createDirectory(String path) {
        File dir = new File(path);
        if (!dir.exists()) {
            dir.mkdir();
        }
    }
    
    private void createTestFiles(String folder) throws IOException {
        // Create movies.csv
        try (FileWriter writer = new FileWriter(folder + "/movies.csv")) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Test Movie 1,120.0,1000000,01-01-2023\n");
            writer.write("102,Test Movie 2,90.5,500000,15-06-2022\n");
            writer.write("103,Test Movie 3,145.0,2000000,30-12-2023\n");
        }
        
        // Create actors.csv
        try (FileWriter writer = new FileWriter(folder + "/actors.csv")) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
            writer.write("202,Actor Two,F,101\n");
            writer.write("203,Actor Three,M,102\n");
            writer.write("204,Actor Four,F,102\n");
            writer.write("205,Actor Five,M,103\n");
        }
        
        // Create directors.csv
        try (FileWriter writer = new FileWriter(folder + "/directors.csv")) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
            writer.write("302,Director Two,102\n");
            writer.write("303,Director Three,103\n");
        }
        
        // Create genres.csv
        try (FileWriter writer = new FileWriter(folder + "/genres.csv")) {
            writer.write("genreId,genreName\n");
            writer.write("401,Action\n");
            writer.write("402,Comedy\n");
            writer.write("403,Drama\n");
            writer.write("404,Sci-Fi\n");
        }
        
        // Create genres_movies.csv
        try (FileWriter writer = new FileWriter(folder + "/genres_movies.csv")) {
            writer.write("genreId,movieId\n");
            writer.write("401,101\n");
            writer.write("402,101\n");
            writer.write("403,102\n");
            writer.write("404,103\n");
        }
        
        // Create movie_votes.csv
        try (FileWriter writer = new FileWriter(folder + "/movie_votes.csv")) {
            writer.write("movieId,movieRating,movieRatingCount\n");
            writer.write("101,8.5,100\n");
            writer.write("102,7.2,50\n");
            writer.write("103,9.0,75\n");
        }
    }
    
    private void createErrorTestFiles(String folder) throws IOException {
        // Create movies.csv with errors
        try (FileWriter writer = new FileWriter(folder + "/movies.csv")) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Test Movie 1,120.0,1000000,01-01-2023\n");
            // Missing fields
            writer.write("102,Test Movie 2,,500000,15-06-2022\n");
            // Invalid date format
            writer.write("103,Test Movie 3,145.0,2000000,2023/12/30\n");
        }
        
        // Create actors.csv with errors
        try (FileWriter writer = new FileWriter(folder + "/actors.csv")) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
            // Missing gender
            writer.write("202,Actor Two,,101\n");
        }
        
        // Create other files with minimal content
        try (FileWriter writer = new FileWriter(folder + "/directors.csv")) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
        }
        
        try (FileWriter writer = new FileWriter(folder + "/genres.csv")) {
            writer.write("genreId,genreName\n");
            writer.write("401,Action\n");
        }
        
        try (FileWriter writer = new FileWriter(folder + "/genres_movies.csv")) {
            writer.write("genreId,movieId\n");
            writer.write("401,101\n");
        }
        
        try (FileWriter writer = new FileWriter(folder + "/movie_votes.csv")) {
            writer.write("movieId,movieRating,movieRatingCount\n");
            writer.write("101,8.5,100\n");
        }
    }

    // Test parsing files without errors
    @Test
    public void testParseFilesNoErrors() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed");
        
        // Verify that movies were loaded
        ArrayList<Object> movies = Main.getObjects(TipoEntidade.FILME);
        assertFalse(movies.isEmpty(), "Movies list should not be empty");
        
        // Verify that actors were loaded
        ArrayList<Object> actors = Main.getObjects(TipoEntidade.ATOR);
        assertFalse(actors.isEmpty(), "Actors list should not be empty");
        
        // Verify that directors were loaded
        ArrayList<Object> directors = Main.getObjects(TipoEntidade.REALIZADOR);
        assertFalse(directors.isEmpty(), "Directors list should not be empty");
        
        // Verify that genres were loaded
        ArrayList<Object> genres = Main.getObjects(TipoEntidade.GENERO);
        assertFalse(genres.isEmpty(), "Genres list should not be empty");
        
        // Check if at least one movie has actors, directors, and genres
        if (!movies.isEmpty()) {
            Movie movie = (Movie) movies.get(0);
            assertTrue(movie.getActors().size() > 0 || movie.getDirectors().size() > 0 || movie.getGenres().size() > 0,
                    "Movie should have at least one actor, director, or genre");
        }
    }

    // Test parsing files with errors
    @Test
    public void testParseFilesWithErrors() {
        // Parse files with errors
        boolean result = Main.parseFiles(new File(TEST_ERROR_FOLDER));
        assertTrue(result, "File parsing should succeed even with errors");
        
        // Check if invalid inputs were recorded
        ArrayList<Object> invalidInputs = Main.getObjects(TipoEntidade.INPUT_INVALIDO);
        assertNotNull(invalidInputs, "Invalid inputs list should not be null");
        assertFalse(invalidInputs.isEmpty(), "Invalid inputs list should not be empty");
    }
    
    // More tests for file parsing
    @Test
    public void testFilmObjectRetrieval() {
        Main.parseFiles(new File(TEST_FOLDER));
        ArrayList<Object> movies = Main.getObjects(TipoEntidade.FILME);
        assertFalse(movies.isEmpty(), "Movies list should not be empty");
        
        for (Object obj : movies) {
            assertTrue(obj instanceof Movie, "Object should be of type Movie");
            Movie movie = (Movie) obj;
            assertNotNull(movie.getName(), "Movie name should not be null");
        }
    }
    
    @Test
    public void testActorObjectRetrieval() {
        Main.parseFiles(new File(TEST_FOLDER));
        ArrayList<Object> actors = Main.getObjects(TipoEntidade.ATOR);
        assertFalse(actors.isEmpty(), "Actors list should not be empty");
        
        for (Object obj : actors) {
            assertTrue(obj instanceof Actor, "Object should be of type Actor");
            Actor actor = (Actor) obj;
            assertNotNull(actor.getName(), "Actor name should not be null");
        }
    }
    
    @Test
    public void testDirectorObjectRetrieval() {
        Main.parseFiles(new File(TEST_FOLDER));
        ArrayList<Object> directors = Main.getObjects(TipoEntidade.REALIZADOR);
        assertFalse(directors.isEmpty(), "Directors list should not be empty");
        
        for (Object obj : directors) {
            assertTrue(obj instanceof Director, "Object should be of type Director");
            Director director = (Director) obj;
            assertNotNull(director.getName(), "Director name should not be null");
        }
    }
    
    @Test
    public void testGenreObjectRetrieval() {
        Main.parseFiles(new File(TEST_FOLDER));
        ArrayList<Object> genres = Main.getObjects(TipoEntidade.GENERO);
        assertFalse(genres.isEmpty(), "Genres list should not be empty");
        
        for (Object obj : genres) {
            assertTrue(obj instanceof Genre, "Object should be of type Genre");
            Genre genre = (Genre) obj;
            assertNotNull(genre.getName(), "Genre name should not be null");
        }
    }
    
    @Test
    public void testGenreCinematograficoObjectRetrieval() {
        Main.parseFiles(new File(TEST_FOLDER));
        ArrayList<Object> genres = Main.getObjects(TipoEntidade.GENERO_CINEMATOGRAFICO);
        assertFalse(genres.isEmpty(), "Genres list should not be empty");
        
        for (Object obj : genres) {
            assertTrue(obj instanceof Genre, "Object should be of type Genre");
            Genre genre = (Genre) obj;
            assertNotNull(genre.getName(), "Genre name should not be null");
        }
        
        // Verify that GENERO and GENERO_CINEMATOGRAFICO return the same data
        ArrayList<Object> regularGenres = Main.getObjects(TipoEntidade.GENERO);
        assertEquals(regularGenres.size(), genres.size(), 
                "GENERO and GENERO_CINEMATOGRAFICO should return the same number of items");
    }
    
    @Test
    public void testRelationships() {
        Main.parseFiles(new File(TEST_FOLDER));
        ArrayList<Object> movies = Main.getObjects(TipoEntidade.FILME);
        
        if (!movies.isEmpty()) {
            Movie movie = (Movie) movies.get(0);
            
            // Check actor relationships
            for (Actor actor : movie.getActors()) {
                assertTrue(actor.getMovies().contains(movie), 
                        "Actor's movie list should contain the movie that references it");
            }
            
            // Check director relationships
            for (Director director : movie.getDirectors()) {
                assertTrue(director.getMovies().contains(movie), 
                        "Director's movie list should contain the movie that references it");
            }
            
            // Check genre relationships
            for (Genre genre : movie.getGenres()) {
                assertTrue(genre.getMovies().contains(movie), 
                        "Genre's movie list should contain the movie that references it");
            }
        }
    }
    
    @Test
    public void testGetMoviesActorYear() {
        assertTrue(Main.parseFiles(new File("test-files")));
        
        Main.Result result = Main.execute("GET_MOVIES_ACTOR_YEAR 2023 Actor One");
        assertNotNull(result);
        assertTrue(result.success);
        String[] resultParts = result.result.split("\n");
        assertArrayEquals(new String[] {
            "Test Movie 1"
        }, resultParts);
        
        result = Main.execute("GET_MOVIES_ACTOR_YEAR 2022 Actor Three");
        assertNotNull(result);
        assertTrue(result.success);
        resultParts = result.result.split("\n");
        assertArrayEquals(new String[] {
            "Test Movie 2"
        }, resultParts);
    }
    
    @Test
    public void testGetMoviesBudgetAbove() {
        assertTrue(Main.parseFiles(new File("test-files")));
        
        Main.Result result = Main.execute("GET_MOVIES_BUDGET_ABOVE 1500000");
        assertNotNull(result);
        assertTrue(result.success);
        String[] resultParts = result.result.split("\n");
        assertArrayEquals(new String[] {
            "Test Movie 3 : 2000000"
        }, resultParts);
        
        result = Main.execute("GET_MOVIES_BUDGET_ABOVE 100000");
        assertNotNull(result);
        assertTrue(result.success);
        resultParts = result.result.split("\n");
        // Should contain all 3 movies, sorted by budget (highest first)
        assertEquals(3, resultParts.length);
        assertTrue(resultParts[0].startsWith("Test Movie 3"));
        assertTrue(resultParts[1].startsWith("Test Movie 1"));
        assertTrue(resultParts[2].startsWith("Test Movie 2"));
    }
    
    @Test
    public void testCreativeCommand() {
        // We'll use the regular TEST_FOLDER to simplify testing
        assertTrue(Main.parseFiles(new File(TEST_FOLDER)));
        
        // Since we're using the standard test folder, we need to make sure our queries match the data
        // Test with a query that should work with the standard test data
        Main.Result result = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 7.0 Action");
        assertNotNull(result);
        assertTrue(result.success);
        
        // Test with a genre in the standard test data
        result = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 7.0 Sci-Fi");
        assertNotNull(result);
        assertTrue(result.success);
        
        // Test with a non-existent genre
        result = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 7.0 NonExistentGenre");
        assertNotNull(result);
        assertFalse(result.success);
        assertTrue(result.result.contains("Genre not found"));
        
        // Test with a higher threshold
        result = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 9.9 Action");
        assertNotNull(result);
        assertTrue(result.success);
        assertTrue(result.result.contains("No movies found with rating >= 9.9"));
    }
}