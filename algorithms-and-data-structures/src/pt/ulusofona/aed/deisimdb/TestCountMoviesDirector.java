package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestCountMoviesDirector {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-director");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test COUNT_MOVIES_DIRECTOR command
            System.out.println("\nTesting COUNT_MOVIES_DIRECTOR for Director One:");
            Main.Result cmdResult = Main.execute("COUNT_MOVIES_DIRECTOR Director One");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with case-insensitive director name
            System.out.println("\nTesting COUNT_MOVIES_DIRECTOR with case-insensitive name:");
            cmdResult = Main.execute("COUNT_MOVIES_DIRECTOR DIRECTOR ONE");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with multi-word director name
            System.out.println("\nTesting COUNT_MOVIES_DIRECTOR with multi-word name:");
            cmdResult = Main.execute("COUNT_MOVIES_DIRECTOR Steven Spielberg");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with non-existent director
            System.out.println("\nTesting COUNT_MOVIES_DIRECTOR with non-existent director:");
            cmdResult = Main.execute("COUNT_MOVIES_DIRECTOR Unknown Director");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
        } catch (IOException e) {
            System.err.println("Error creating test files: " + e.getMessage());
        }
    }
    
    private static void createTestFiles(File folder) throws IOException {
        // Create movies.csv
        try (FileWriter writer = new FileWriter(new File(folder, "movies.csv"))) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Movie 1,120.0,1000000,01-01-2023\n");
            writer.write("102,Movie 2,90.5,500000,15-06-2022\n");
            writer.write("103,Movie 3,145.0,2000000,30-12-2023\n");
            writer.write("104,Movie 4,130.0,1500000,10-03-2022\n");
            writer.write("105,Movie 5,95.0,800000,22-07-2023\n");
        }
        
        // Create directors.csv with multiple movies per director
        try (FileWriter writer = new FileWriter(new File(folder, "directors.csv"))) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
            writer.write("301,Director One,102\n");
            writer.write("301,Director One,103\n");
            writer.write("302,Steven Spielberg,104\n");
            writer.write("302,Steven Spielberg,105\n");
        }
        
        // Create minimal actors.csv
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
        }
        
        // Create minimal genres.csv
        try (FileWriter writer = new FileWriter(new File(folder, "genres.csv"))) {
            writer.write("genreId,genreName\n");
            writer.write("401,Action\n");
        }
        
        // Create minimal genres_movies.csv
        try (FileWriter writer = new FileWriter(new File(folder, "genres_movies.csv"))) {
            writer.write("genreId,movieId\n");
            writer.write("401,101\n");
        }
    }
} 