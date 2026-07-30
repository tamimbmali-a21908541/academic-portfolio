package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestCountActorsIn2Years {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-actors-2-years");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test COUNT_ACTORS_IN_2_YEARS command for 2005 and 2010
            System.out.println("\nTesting COUNT_ACTORS_IN_2_YEARS for 2005 and 2010:");
            Main.Result cmdResult = Main.execute("COUNT_ACTORS_IN_2_YEARS 2005 2010");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test COUNT_ACTORS_IN_2_YEARS command for 2010 and 2005 (reversed order)
            System.out.println("\nTesting COUNT_ACTORS_IN_2_YEARS for 2010 and 2005 (reversed order):");
            cmdResult = Main.execute("COUNT_ACTORS_IN_2_YEARS 2010 2005");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test COUNT_ACTORS_IN_2_YEARS command for years with no common actors
            System.out.println("\nTesting COUNT_ACTORS_IN_2_YEARS for years with no common actors (2000 and 2015):");
            cmdResult = Main.execute("COUNT_ACTORS_IN_2_YEARS 2000 2015");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test COUNT_ACTORS_IN_2_YEARS command for non-existent years
            System.out.println("\nTesting COUNT_ACTORS_IN_2_YEARS for non-existent years (1900 and 1901):");
            cmdResult = Main.execute("COUNT_ACTORS_IN_2_YEARS 1900 1901");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test COUNT_ACTORS_IN_2_YEARS command with invalid parameters
            System.out.println("\nTesting COUNT_ACTORS_IN_2_YEARS with invalid parameters:");
            cmdResult = Main.execute("COUNT_ACTORS_IN_2_YEARS abc 2010");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
        } catch (IOException e) {
            System.err.println("Error creating test files: " + e.getMessage());
        }
    }
    
    private static void createTestFiles(File folder) throws IOException {
        // Create movies.csv with movies from different years
        try (FileWriter writer = new FileWriter(new File(folder, "movies.csv"))) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            // Movies from 2005
            writer.write("101,Movie 2005-1,120.0,1000000,01-01-2005\n");
            writer.write("102,Movie 2005-2,90.5,500000,15-06-2005\n");
            writer.write("103,Movie 2005-3,145.0,2000000,30-12-2005\n");
            
            // Movies from 2010
            writer.write("201,Movie 2010-1,130.0,1500000,10-02-2010\n");
            writer.write("202,Movie 2010-2,95.0,800000,22-07-2010\n");
            writer.write("203,Movie 2010-3,110.0,750000,15-11-2010\n");
            
            // Movies from 2000
            writer.write("301,Movie 2000-1,105.0,900000,10-03-2000\n");
            writer.write("302,Movie 2000-2,115.0,950000,20-08-2000\n");
            
            // Movies from 2015
            writer.write("401,Movie 2015-1,125.0,850000,05-05-2015\n");
            writer.write("402,Movie 2015-2,135.0,950000,15-09-2015\n");
        }
        
        // Create actors.csv - include actors who appear in multiple years
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            
            // Actors in 2005 movies
            writer.write("1,Actor One,M,101\n");   // Only in 2005
            writer.write("2,Actor Two,M,101\n");   // In 2005 and 2010
            writer.write("2,Actor Two,M,201\n");
            writer.write("3,Actor Three,F,102\n"); // In 2005 and 2010
            writer.write("3,Actor Three,F,202\n");
            writer.write("4,Actor Four,M,102\n");  // Only in 2005
            writer.write("5,Actor Five,F,103\n");  // In 2005 and 2010
            writer.write("5,Actor Five,F,203\n");
            
            // Additional actors in 2010 movies
            writer.write("6,Actor Six,M,201\n");   // Only in 2010
            writer.write("7,Actor Seven,F,202\n"); // Only in 2010
            
            // Actors in 2000 movies
            writer.write("8,Actor Eight,M,301\n");
            writer.write("9,Actor Nine,F,301\n");
            writer.write("10,Actor Ten,M,302\n");
            
            // Actors in 2015 movies
            writer.write("11,Actor Eleven,M,401\n");
            writer.write("12,Actor Twelve,F,401\n");
            writer.write("13,Actor Thirteen,M,402\n");
            
            // One actor appears in 2000 and 2015, but not in 2005 or 2010
            writer.write("14,Actor Fourteen,F,302\n");
            writer.write("14,Actor Fourteen,F,402\n");
        }
        
        // Minimal required files to make parsing work
        try (FileWriter writer = new FileWriter(new File(folder, "directors.csv"))) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("1,Director One,101\n");
        }
        
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