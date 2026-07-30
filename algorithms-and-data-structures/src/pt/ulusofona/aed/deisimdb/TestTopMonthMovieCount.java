package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestTopMonthMovieCount {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-top-month");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test TOP_MONTH_MOVIE_COUNT command for 2023
            System.out.println("\nTesting TOP_MONTH_MOVIE_COUNT for 2023:");
            Main.Result cmdResult = Main.execute("TOP_MONTH_MOVIE_COUNT 2023");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with a different year
            System.out.println("\nTesting TOP_MONTH_MOVIE_COUNT for 2022:");
            cmdResult = Main.execute("TOP_MONTH_MOVIE_COUNT 2022");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with a year with no movies
            System.out.println("\nTesting TOP_MONTH_MOVIE_COUNT with year with no movies:");
            cmdResult = Main.execute("TOP_MONTH_MOVIE_COUNT 2020");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with invalid format
            System.out.println("\nTesting TOP_MONTH_MOVIE_COUNT with invalid format:");
            cmdResult = Main.execute("TOP_MONTH_MOVIE_COUNT abc");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
        } catch (IOException e) {
            System.err.println("Error creating test files: " + e.getMessage());
        }
    }
    
    private static void createTestFiles(File folder) throws IOException {
        // Create movies.csv with movies distributed across months in 2023 and 2022
        try (FileWriter writer = new FileWriter(new File(folder, "movies.csv"))) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            // 3 movies in January 2023
            writer.write("101,Movie Jan 1,120.0,1000000,01-01-2023\n");
            writer.write("102,Movie Jan 2,90.5,500000,15-01-2023\n");
            writer.write("103,Movie Jan 3,145.0,2000000,30-01-2023\n");
            // 2 movies in February 2023
            writer.write("104,Movie Feb 1,130.0,1500000,10-02-2023\n");
            writer.write("105,Movie Feb 2,95.0,800000,22-02-2023\n");
            // 1 movie in March 2023
            writer.write("106,Movie Mar 1,110.0,750000,15-03-2023\n");
            // 2 movies in June 2022
            writer.write("107,Movie Jun 1,105.0,900000,10-06-2022\n");
            writer.write("108,Movie Jun 2,115.0,950000,20-06-2022\n");
            // 3 movies in July 2022
            writer.write("109,Movie Jul 1,125.0,850000,05-07-2022\n");
            writer.write("110,Movie Jul 2,135.0,950000,15-07-2022\n");
            writer.write("111,Movie Jul 3,140.0,1050000,25-07-2022\n");
        }
        
        // Minimal required files to make parsing work
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            writer.write("201,Actor One,M,101\n");
        }
        
        try (FileWriter writer = new FileWriter(new File(folder, "directors.csv"))) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("301,Director One,101\n");
        }
        
        try (FileWriter writer = new FileWriter(new File(folder, "genres.csv"))) {
            writer.write("genreId,genreName\n");
            writer.write("401,Action\n");
        }
        
        try (FileWriter writer = new FileWriter(new File(folder, "genres_movies.csv"))) {
            writer.write("genreId,movieId\n");
            writer.write("401,101\n");
        }
    }
} 