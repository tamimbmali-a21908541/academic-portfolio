package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestGetMoviesIdLessThan {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-id-less-than");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test GET_MOVIES_ID_LESS_THAN command for ID < 200
            System.out.println("\nTesting GET_MOVIES_ID_LESS_THAN for ID < 200:");
            Main.Result cmdResult = Main.execute("GET_MOVIES_ID_LESS_THAN 200");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with a higher ID threshold
            System.out.println("\nTesting GET_MOVIES_ID_LESS_THAN for ID < 500:");
            cmdResult = Main.execute("GET_MOVIES_ID_LESS_THAN 500");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with an ID that excludes all movies
            System.out.println("\nTesting GET_MOVIES_ID_LESS_THAN with ID that excludes all movies:");
            cmdResult = Main.execute("GET_MOVIES_ID_LESS_THAN 100");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with invalid format
            System.out.println("\nTesting GET_MOVIES_ID_LESS_THAN with invalid format:");
            cmdResult = Main.execute("GET_MOVIES_ID_LESS_THAN abc");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
        } catch (Exception e) {
            System.out.println("Error: " + e);
            e.printStackTrace();
        }
    }
    
    private static void createTestFiles(File folder) throws IOException {
        // Create movies.csv with test data
        try (FileWriter writer = new FileWriter(new File(folder, "movies.csv"))) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Test Movie 1,120.0,1000000,15-05-2021\n");
            writer.write("202,Test Movie 2,90.0,500000,20-06-2021\n");
            writer.write("303,Test Movie 3,110.0,800000,10-07-2021\n");
            writer.write("1001,Test Movie 4,130.0,1200000,05-08-2021\n"); // Higher ID
            writer.write("2002,Test Movie 5,95.0,750000,12-09-2021\n"); // Higher ID
        }
        
        // Create minimal actors.csv to satisfy movie relationships
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,actorMovies\n");
            writer.write("1,Actor One,M,101;303\n");
            writer.write("2,Actor Two,F,101;202\n");
            writer.write("3,Actor Three,M,202;303;1001\n");
            writer.write("4,Actor Four,F,1001;2002\n");
        }
        
        // Create minimal directors.csv
        try (FileWriter writer = new FileWriter(new File(folder, "directors.csv"))) {
            writer.write("directorId,directorName,directorMovies\n");
            writer.write("1,Director One,101;202\n");
            writer.write("2,Director Two,303;1001;2002\n");
        }
        
        // Create minimal genres.csv
        try (FileWriter writer = new FileWriter(new File(folder, "genres.csv"))) {
            writer.write("genreId,genreName\n");
            writer.write("1,Action\n");
            writer.write("2,Comedy\n");
            writer.write("3,Drama\n");
        }
        
        // Create minimal genres_movies.csv
        try (FileWriter writer = new FileWriter(new File(folder, "genres_movies.csv"))) {
            writer.write("genreId,movieId\n");
            writer.write("1,101\n");
            writer.write("1,303\n");
            writer.write("2,202\n");
            writer.write("2,1001\n");
            writer.write("3,1001\n");
            writer.write("3,2002\n");
        }
        
        // Create minimal movie_votes.csv
        try (FileWriter writer = new FileWriter(new File(folder, "movie_votes.csv"))) {
            writer.write("movieId,movieRating,movieVotes\n");
            writer.write("101,8.5,100\n");
            writer.write("202,7.0,80\n");
            writer.write("303,9.0,120\n");
            writer.write("1001,8.0,150\n");
            writer.write("2002,7.5,90\n");
        }
    }
} 