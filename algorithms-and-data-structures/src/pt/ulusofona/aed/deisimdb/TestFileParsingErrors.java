package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Test class specifically for file parsing with errors
 */
public class TestFileParsingErrors {

    private final String TEST_FOLDER = "test-files-with-errors";

    @BeforeEach
    public void setUp() throws IOException {
        // Create test directory
        File testDir = new File(TEST_FOLDER);
        if (!testDir.exists()) {
            testDir.mkdir();
        }

        // Create test data files with errors
        createMoviesFileWithErrors();
        createActorsFileWithErrors();
        createDirectorsFileWithErrors();
        createGenresFileWithErrors();
        createGenresMoviesFileWithErrors();
        createMovieVotesFileWithErrors();
    }

    private void createMoviesFileWithErrors() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/movies.csv")) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Test Movie 1,120.0,1000000,01-01-2023\n");
            // Missing fields
            writer.write("102,Test Movie 2,,500000,15-06-2022\n");
            // Duplicate ID
            writer.write("101,Duplicate Movie,100.0,750000,10-10-2022\n");
            // Invalid date format
            writer.write("103,Test Movie 3,145.0,2000000,2023/12/30\n");
            // Missing field
            writer.write("104,Test Movie 4,130.0,\n");
        }
    }

    private void createActorsFileWithErrors() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/actors.csv")) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
            // Missing field
            writer.write("202,Actor Two,,101\n");
            // Invalid movie ID (doesn't exist)
            writer.write("203,Actor Three,M,999\n");
            // Invalid format (too few fields)
            writer.write("204,Actor Four\n");
            // Invalid gender format
            writer.write("205,Actor Five,Male,101\n");
        }
    }

    private void createDirectorsFileWithErrors() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/directors.csv")) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
            // Missing field
            writer.write("302,,102\n");
            // Invalid movie ID (doesn't exist)
            writer.write("303,Director Three,999\n");
            // Too few fields
            writer.write("304,Director Four\n");
        }
    }

    private void createGenresFileWithErrors() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/genres.csv")) {
            writer.write("genreId,genreName\n");
            writer.write("401,Action\n");
            // Missing name
            writer.write("402,\n");
            // Invalid format (missing ID)
            writer.write(",Drama\n");
            // Too few fields
            writer.write("404\n");
        }
    }

    private void createGenresMoviesFileWithErrors() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/genres_movies.csv")) {
            writer.write("genreId,movieId\n");
            writer.write("401,101\n");
            // Non-existent genre
            writer.write("999,101\n");
            // Non-existent movie
            writer.write("401,999\n");
            // Too few fields
            writer.write("401\n");
            // Empty fields
            writer.write(",\n");
        }
    }

    private void createMovieVotesFileWithErrors() throws IOException {
        try (FileWriter writer = new FileWriter(TEST_FOLDER + "/movie_votes.csv")) {
            writer.write("movieId,movieRating,movieRatingCount\n");
            writer.write("101,8.5,100\n");
            // Invalid rating (not a number)
            writer.write("102,excellent,50\n");
            // Non-existent movie
            writer.write("999,7.0,30\n");
            // Too few fields
            writer.write("103,9.0\n");
        }
    }

    @Test
    public void testFileParsingWithErrors1() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed even with errors");
        
        ArrayList<Object> invalidReports = Main.getObjects(TipoEntidade.INPUT_INVALIDO);
        assertFalse(invalidReports.isEmpty(), "Should report invalid inputs");
        
        // Verify the movies report has error information
        String moviesReport = (String)invalidReports.get(0);
        assertTrue(moviesReport.startsWith("movies.csv"), "Should be the movies report");
        // Extract the error counts and code
        String[] parts = moviesReport.split("\\|");
        int validCount = Integer.parseInt(parts[1].trim());
        int invalidCount = Integer.parseInt(parts[2].trim());
        int errorCode = Integer.parseInt(parts[3].trim());
        
        assertTrue(invalidCount > 0, "Should have invalid movies");
        assertTrue(errorCode != 0, "Should have an error code");
    }

    @Test
    public void testFileParsingWithErrors2() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed even with errors");
        
        ArrayList<Object> invalidReports = Main.getObjects(TipoEntidade.INPUT_INVALIDO);
        
        // Verify the actors report has error information
        String actorsReport = (String)invalidReports.get(1);
        assertTrue(actorsReport.startsWith("actors.csv"), "Should be the actors report");
        
        String[] parts = actorsReport.split("\\|");
        int validCount = Integer.parseInt(parts[1].trim());
        int invalidCount = Integer.parseInt(parts[2].trim());
        int errorCode = Integer.parseInt(parts[3].trim());
        
        assertTrue(invalidCount > 0, "Should have invalid actors");
        assertTrue(errorCode != 0, "Should have an error code");
    }

    @Test
    public void testFileParsingWithErrors3() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed even with errors");
        
        ArrayList<Object> invalidReports = Main.getObjects(TipoEntidade.INPUT_INVALIDO);
        
        // Verify the directors report has error information
        String directorsReport = (String)invalidReports.get(2);
        assertTrue(directorsReport.startsWith("directors.csv"), "Should be the directors report");
        
        String[] parts = directorsReport.split("\\|");
        int validCount = Integer.parseInt(parts[1].trim());
        int invalidCount = Integer.parseInt(parts[2].trim());
        int errorCode = Integer.parseInt(parts[3].trim());
        
        assertTrue(invalidCount > 0, "Should have invalid directors");
        assertTrue(errorCode != 0, "Should have an error code");
    }

    @Test
    public void testFileParsingWithErrors4() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed even with errors");
        
        ArrayList<Object> invalidReports = Main.getObjects(TipoEntidade.INPUT_INVALIDO);
        
        // Verify the genres report has error information
        String genresReport = (String)invalidReports.get(3);
        assertTrue(genresReport.startsWith("genres.csv"), "Should be the genres report");
        
        String[] parts = genresReport.split("\\|");
        int validCount = Integer.parseInt(parts[1].trim());
        int invalidCount = Integer.parseInt(parts[2].trim());
        int errorCode = Integer.parseInt(parts[3].trim());
        
        assertTrue(invalidCount > 0, "Should have invalid genres");
        assertTrue(errorCode != 0, "Should have an error code");
    }
    
    @Test
    public void testFileParsingWithErrors5() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed even with errors");
        
        ArrayList<Object> invalidReports = Main.getObjects(TipoEntidade.INPUT_INVALIDO);
        
        // Verify the genres_movies report has error information
        String genresMoviesReport = (String)invalidReports.get(4);
        assertTrue(genresMoviesReport.startsWith("genres_movies.csv"), "Should be the genres_movies report");
        
        String[] parts = genresMoviesReport.split("\\|");
        int validCount = Integer.parseInt(parts[1].trim());
        int invalidCount = Integer.parseInt(parts[2].trim());
        int errorCode = Integer.parseInt(parts[3].trim());
        
        assertTrue(invalidCount > 0, "Should have invalid genre-movie associations");
        assertTrue(errorCode != 0, "Should have an error code");
    }
    
    @Test
    public void testFileParsingWithErrors6() {
        boolean result = Main.parseFiles(new File(TEST_FOLDER));
        assertTrue(result, "File parsing should succeed even with errors");
        
        ArrayList<Object> invalidReports = Main.getObjects(TipoEntidade.INPUT_INVALIDO);
        
        // Verify the movie_votes report has error information
        String movieVotesReport = (String)invalidReports.get(5);
        assertTrue(movieVotesReport.startsWith("movie_votes.csv"), "Should be the movie_votes report");
        
        String[] parts = movieVotesReport.split("\\|");
        int validCount = Integer.parseInt(parts[1].trim());
        int invalidCount = Integer.parseInt(parts[2].trim());
        int errorCode = Integer.parseInt(parts[3].trim());
        
        assertTrue(invalidCount > 0, "Should have invalid movie votes");
        assertTrue(errorCode != 0, "Should have an error code");
    }
}
