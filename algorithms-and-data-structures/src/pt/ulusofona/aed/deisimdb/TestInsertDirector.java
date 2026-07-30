package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestInsertDirector {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-insert-director");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test GET_ACTORS_BY_DIRECTOR for a non-existent director (Tó Silva)
            System.out.println("\nTesting GET_ACTORS_BY_DIRECTOR for non-existent director (should return 'No results'):");
            Main.Result cmdResult = Main.execute("GET_ACTORS_BY_DIRECTOR 2 Tó Silva");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test INSERT_DIRECTOR command
            System.out.println("\nTesting INSERT_DIRECTOR command:");
            cmdResult = Main.execute("INSERT_DIRECTOR 999 Tó Silva 101");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test GET_ACTORS_BY_DIRECTOR after insertion
            System.out.println("\nTesting GET_ACTORS_BY_DIRECTOR after insertion:");
            cmdResult = Main.execute("GET_ACTORS_BY_DIRECTOR 1 Tó Silva");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test INSERT_DIRECTOR with invalid movie ID
            System.out.println("\nTesting INSERT_DIRECTOR with invalid movie ID:");
            cmdResult = Main.execute("INSERT_DIRECTOR 888 Another Director 9999");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
        } catch (IOException e) {
            System.err.println("Error creating test files: " + e.getMessage());
        }
    }
    
    private static void createTestFiles(File folder) throws IOException {
        // Create movies.csv with test movies
        try (FileWriter writer = new FileWriter(new File(folder, "movies.csv"))) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Test Movie 1,120.0,1000000,01-01-2020\n");
            writer.write("102,Test Movie 2,90.5,500000,15-06-2020\n");
        }
        
        // Create actors.csv
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("1,Actor One,M,101\n");
            writer.write("2,Actor Two,F,101\n");
            writer.write("3,Actor Three,M,102\n");
        }
        
        // Create directors.csv with an existing director
        try (FileWriter writer = new FileWriter(new File(folder, "directors.csv"))) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("1,Director One,102\n");
        }
        
        // Minimal required files to make parsing work
        try (FileWriter writer = new FileWriter(new File(folder, "genres.csv"))) {
            writer.write("genreId,genreName\n");
            writer.write("1,Action\n");
        }
        
        try (FileWriter writer = new FileWriter(new File(folder, "genres_movies.csv"))) {
            writer.write("genreId,movieId\n");
            writer.write("1,101\n");
        }
    }
} 