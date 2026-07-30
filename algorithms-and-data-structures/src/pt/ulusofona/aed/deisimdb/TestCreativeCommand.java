package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestCreativeCommand {
    public static void main(String[] args) {
        try {
            // Create test directory
            createDirectory("test-files/popularMoviesByGenre");
            
            // Create test files
            createTestFiles("test-files/popularMoviesByGenre");
            
            // Parse files
            System.out.println("Parsing files...");
            boolean result = Main.parseFiles(new File("test-files/popularMoviesByGenre"));
            System.out.println("Parse result: " + result);
            
            // Test creative command
            System.out.println("\nTesting creative command...");
            Main.Result cmdResult = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 8.0 Action");
            System.out.println("Command result success: " + cmdResult.success);
            System.out.println("Command result: " + cmdResult.result);
            
            // Test with Sci-Fi genre
            System.out.println("\nTesting with Sci-Fi genre...");
            cmdResult = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 9.0 Sci-Fi");
            System.out.println("Command result success: " + cmdResult.success);
            System.out.println("Command result: " + cmdResult.result);
            
            // Test with a non-existent genre
            System.out.println("\nTesting with non-existent genre...");
            cmdResult = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 7.0 Horror");
            System.out.println("Command result success: " + cmdResult.success);
            System.out.println("Command result: " + cmdResult.result);
            
            // Test with a higher threshold
            System.out.println("\nTesting with higher threshold...");
            cmdResult = Main.execute("GET_POPULAR_MOVIES_BY_GENRE 9.5 Action");
            System.out.println("Command result success: " + cmdResult.success);
            System.out.println("Command result: " + cmdResult.result);
            
        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
    
    private static void createDirectory(String path) {
        File dir = new File(path);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }
    
    private static void createTestFiles(String folder) throws IOException {
        // Create movies.csv
        try (FileWriter writer = new FileWriter(folder + "/movies.csv")) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Action Movie 1,120.0,1000000,01-01-2023\n");
            writer.write("102,Action Movie 2,90.5,500000,15-06-2022\n");
            writer.write("103,Sci-Fi Movie 1,145.0,2000000,30-12-2023\n");
            writer.write("104,Drama Movie 1,130.0,1500000,10-03-2022\n");
            writer.write("105,Comedy Movie 1,95.0,800000,22-07-2023\n");
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
            writer.write("401,102\n");
            writer.write("404,103\n");
            writer.write("403,104\n");
            writer.write("402,105\n");
        }
        
        // Create movie_votes.csv
        try (FileWriter writer = new FileWriter(folder + "/movie_votes.csv")) {
            writer.write("movieId,movieRating,movieRatingCount\n");
            writer.write("101,8.5,100\n");
            writer.write("102,7.2,50\n");
            writer.write("103,9.0,75\n");
            writer.write("104,8.8,60\n");
            writer.write("105,7.5,80\n");
        }
        
        // Create actors.csv (basic)
        try (FileWriter writer = new FileWriter(folder + "/actors.csv")) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
            writer.write("202,Actor Two,F,101\n");
            writer.write("203,Actor Three,M,102\n");
            writer.write("204,Actor Four,F,102\n");
            writer.write("205,Actor Five,M,103\n");
        }
        
        // Create directors.csv (basic)
        try (FileWriter writer = new FileWriter(folder + "/directors.csv")) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
            writer.write("302,Director Two,102\n");
            writer.write("303,Director Three,103\n");
            writer.write("304,Director Four,104\n");
            writer.write("305,Director Five,105\n");
        }
    }
} 