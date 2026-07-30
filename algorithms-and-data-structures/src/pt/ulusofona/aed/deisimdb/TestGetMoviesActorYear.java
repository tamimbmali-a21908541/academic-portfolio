package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.util.Date;

public class TestGetMoviesActorYear {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-actor-year");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test GET_MOVIES_ACTOR_YEAR command
            System.out.println("\nTesting GET_MOVIES_ACTOR_YEAR for Actor One in 2014:");
            Main.Result cmdResult = Main.execute("GET_MOVIES_ACTOR_YEAR 2014 Actor One");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with exact case for actor name
            System.out.println("\nTesting GET_MOVIES_ACTOR_YEAR with case-insensitive actor name:");
            cmdResult = Main.execute("GET_MOVIES_ACTOR_YEAR 2014 ACTOR ONE");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with non-existent actor
            System.out.println("\nTesting GET_MOVIES_ACTOR_YEAR with non-existent actor:");
            cmdResult = Main.execute("GET_MOVIES_ACTOR_YEAR 2014 Unknown Actor");
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
            writer.write("101,Life Partners,120.0,1000000,01-01-2014\n");
            writer.write("102,Teenage Mutant Ninja Turtles,90.5,500000,15-06-2014\n");
            writer.write("103,The Avengers,145.0,2000000,30-12-2014\n");
            writer.write("104,The Batman,130.0,1500000,10-03-2015\n");
        }
        
        // Create actors.csv
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
            writer.write("201,Actor One,M,102\n");
            writer.write("201,Actor One,M,103\n");
            writer.write("202,Actor Two,F,101\n");
            writer.write("203,Actor Three,M,104\n");
        }
        
        // Create directors.csv (minimal)
        try (FileWriter writer = new FileWriter(new File(folder, "directors.csv"))) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
        }
        
        // Create genres.csv (minimal)
        try (FileWriter writer = new FileWriter(new File(folder, "genres.csv"))) {
            writer.write("genreId,genreName\n");
            writer.write("401,Action\n");
        }
        
        // Create genres_movies.csv (minimal)
        try (FileWriter writer = new FileWriter(new File(folder, "genres_movies.csv"))) {
            writer.write("genreId,movieId\n");
            writer.write("401,101\n");
        }
    }
} 