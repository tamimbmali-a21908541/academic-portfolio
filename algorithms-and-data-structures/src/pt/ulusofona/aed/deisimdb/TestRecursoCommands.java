package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.*;

public class TestRecursoCommands {

    @TempDir
    Path tempDir;

    @BeforeEach
    void setUp() throws IOException {
        // Create test CSV files with sample data
        createTestFiles();
    }

    private void createTestFiles() throws IOException {
        // movies.csv
        File moviesFile = new File(tempDir.toFile(), "movies.csv");
        try (FileWriter writer = new FileWriter(moviesFile)) {
            writer.write("id,title,duration_minutes,budget,release_date\n");
            writer.write("1,Movie One,120,1000000,01-01-2000\n");
            writer.write("2,Movie Two,130,2000000,15-06-2000\n");
            writer.write("3,Movie Three,140,3000000,01-01-2001\n");
            writer.write("4,Movie Four,150,4000000,01-01-2000\n");
            writer.write("5,Movie Five,160,5000000,01-01-2002\n");
        }

        // actors.csv
        File actorsFile = new File(tempDir.toFile(), "actors.csv");
        try (FileWriter writer = new FileWriter(actorsFile)) {
            writer.write("id,name,gender,movie_id\n");
            writer.write("1,Julia Roberts,F,1\n");
            writer.write("1,Julia Roberts,F,2\n");
            writer.write("1,Julia Roberts,F,3\n");
            writer.write("2,Tom Hanks,M,1\n");
            writer.write("2,Tom Hanks,M,4\n");
            writer.write("3,Unknown Actor,M,5\n");
        }

        // directors.csv
        File directorsFile = new File(tempDir.toFile(), "directors.csv");
        try (FileWriter writer = new FileWriter(directorsFile)) {
            writer.write("id,name,movie_id\n");
            writer.write("1,Quentin Tarantino,1\n");
            writer.write("1,Quentin Tarantino,2\n");
            writer.write("1,Quentin Tarantino,3\n");
            writer.write("2,Steven Spielberg,4\n");
            writer.write("3,Empty Director,5\n");
        }

        // genres.csv
        File genresFile = new File(tempDir.toFile(), "genres.csv");
        try (FileWriter writer = new FileWriter(genresFile)) {
            writer.write("id,name\n");
            writer.write("1,Action\n");
            writer.write("2,Drama\n");
            writer.write("3,Comedy\n");
        }

// genres_movies.csv
        File genresMoviesFile = new File(tempDir.toFile(), "genres_movies.csv");
        try (FileWriter writer = new FileWriter(genresMoviesFile)) {  // Changed from genresFile to genresMoviesFile
            writer.write("genre_id,movie_id\n");
            writer.write("1,1\n");
            writer.write("2,1\n");
            writer.write("1,2\n");
            writer.write("3,3\n");
            writer.write("2,4\n");
        }
    }

    @Test
    void testMaxBudgetYearActor_NormalCase() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("MAX_BUDGET_YEAR_ACTOR 2000 Julia Roberts");
        assertTrue(result.success);
        assertEquals("2000000", result.result);
    }

    @Test
    void testMaxBudgetYearActor_ActorExistsButNoMoviesInYear() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("MAX_BUDGET_YEAR_ACTOR 2002 Julia Roberts");
        assertTrue(result.success);
        assertEquals("No results", result.result);
    }

    @Test
    void testMaxBudgetYearActor_NonExistentActor() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("MAX_BUDGET_YEAR_ACTOR 2000 Brad Pitt");
        assertTrue(result.success);
        assertEquals("No results", result.result);
    }

    @Test
    void testMaxBudgetYearActor_CaseInsensitive() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("MAX_BUDGET_YEAR_ACTOR 2000 julia roberts");
        assertTrue(result.success);
        assertEquals("2000000", result.result);
    }

    @Test
    void testMaxBudgetYearActor_InvalidYear() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("MAX_BUDGET_YEAR_ACTOR abc Julia Roberts");
        assertFalse(result.success);
        assertTrue(result.result.contains("Invalid year format"));
    }

    @Test
    void testMaxBudgetYearActor_MissingParameters() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("MAX_BUDGET_YEAR_ACTOR 2000");
        assertFalse(result.success);
        assertTrue(result.result.contains("Invalid parameters"));
    }

    @Test
    void testGetGenresByDirector_NormalCase() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("GET_GENRES_BY_DIRECTOR Quentin Tarantino");
        assertTrue(result.success);
        String[] lines = result.result.split("\n");
        assertEquals(3, lines.length);

        // Check that all expected genres are present
        String allLines = result.result;
        assertTrue(allLines.contains("Action:2"));
        assertTrue(allLines.contains("Drama:1"));
        assertTrue(allLines.contains("Comedy:1"));
    }

    @Test
    void testGetGenresByDirector_NonExistentDirector() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("GET_GENRES_BY_DIRECTOR Christopher Nolan");
        assertTrue(result.success);
        assertEquals("No results", result.result);
    }

    @Test
    void testGetGenresByDirector_CaseInsensitive() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("GET_GENRES_BY_DIRECTOR quentin tarantino");
        assertTrue(result.success);
        assertNotEquals("No results", result.result);
        assertTrue(result.result.contains(":"));
    }

    @Test
    void testGetGenresByDirector_DirectorWithOneGenre() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("GET_GENRES_BY_DIRECTOR Steven Spielberg");
        assertTrue(result.success);
        assertEquals("Drama:1", result.result);
    }

    @Test
    void testGetGenresByDirector_MissingParameters() {
        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("GET_GENRES_BY_DIRECTOR");
        assertFalse(result.success);
        assertTrue(result.result.contains("Invalid parameters"));
    }

    @Test
    void testGetGenresByDirector_DirectorWithNoGenres() throws IOException {
        // Create a movie without genres
        File moviesFile = new File(tempDir.toFile(), "movies.csv");
        try (FileWriter writer = new FileWriter(moviesFile)) {
            writer.write("id,title,duration_minutes,budget,release_date\n");
            writer.write("6,Movie Six,120,1000000,01-01-2000\n");
        }

        File directorsFile = new File(tempDir.toFile(), "directors.csv");
        try (FileWriter writer = new FileWriter(directorsFile)) {
            writer.write("id,name,movie_id\n");
            writer.write("4,No Genre Director,6\n");
        }

        assertTrue(Main.parseFiles(tempDir.toFile()));

        Main.Result result = Main.execute("GET_GENRES_BY_DIRECTOR No Genre Director");
        assertTrue(result.success);
        assertEquals("No results", result.result);
    }
}