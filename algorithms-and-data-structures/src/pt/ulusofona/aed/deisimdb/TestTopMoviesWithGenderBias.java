package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestTopMoviesWithGenderBias {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-gender-bias");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test GET_TOP_MOVIES_WITH_GENDER_BIAS command for male bias (top 2)
            System.out.println("\nTesting GET_TOP_MOVIES_WITH_GENDER_BIAS for male bias (top 2):");
            Main.Result cmdResult = Main.execute("GET_TOP_MOVIES_WITH_GENDER_BIAS M 2");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test for female bias (top 2)
            System.out.println("\nTesting GET_TOP_MOVIES_WITH_GENDER_BIAS for female bias (top 2):");
            cmdResult = Main.execute("GET_TOP_MOVIES_WITH_GENDER_BIAS F 2");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test with invalid gender
            System.out.println("\nTesting GET_TOP_MOVIES_WITH_GENDER_BIAS with invalid gender:");
            cmdResult = Main.execute("GET_TOP_MOVIES_WITH_GENDER_BIAS X 2");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test with invalid count
            System.out.println("\nTesting GET_TOP_MOVIES_WITH_GENDER_BIAS with invalid count:");
            cmdResult = Main.execute("GET_TOP_MOVIES_WITH_GENDER_BIAS M -1");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test with requesting more movies than available
            System.out.println("\nTesting GET_TOP_MOVIES_WITH_GENDER_BIAS with more movies than available (10):");
            cmdResult = Main.execute("GET_TOP_MOVIES_WITH_GENDER_BIAS M 10");
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
            writer.write("101,All Male Cast,120.0,1000000,01-01-2023\n");
            writer.write("102,Mostly Male Cast,90.5,500000,15-01-2023\n");
            writer.write("103,Equal Cast,145.0,2000000,30-01-2023\n");
            writer.write("104,Mostly Female Cast,130.0,1500000,10-02-2023\n");
            writer.write("105,All Female Cast,95.0,800000,22-02-2023\n");
            writer.write("106,Slight Male Bias,110.0,750000,15-03-2023\n");
            writer.write("107,Slight Female Bias,105.0,900000,10-06-2022\n");
        }
        
        // Create actors.csv with different gender distributions
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            
            // Movie 101: All males (5M, 0F) - infinite M/F ratio
            for (int i = 1; i <= 5; i++) {
                writer.write(i + ",Actor" + i + ",M,101\n");
            }
            
            // Movie 102: Mostly males (8M, 2F) - 4:1 M/F ratio
            for (int i = 10; i <= 17; i++) {
                writer.write(i + ",Actor" + i + ",M,102\n");
            }
            writer.write("18,Actress18,F,102\n");
            writer.write("19,Actress19,F,102\n");
            
            // Movie 103: Equal gender distribution (5M, 5F) - 1:1 ratio
            for (int i = 20; i <= 24; i++) {
                writer.write(i + ",Actor" + i + ",M,103\n");
            }
            for (int i = 25; i <= 29; i++) {
                writer.write(i + ",Actress" + i + ",F,103\n");
            }
            
            // Movie 104: Mostly females (2M, 8F) - 1:4 M/F ratio (or 4:1 F/M ratio)
            writer.write("30,Actor30,M,104\n");
            writer.write("31,Actor31,M,104\n");
            for (int i = 32; i <= 39; i++) {
                writer.write(i + ",Actress" + i + ",F,104\n");
            }
            
            // Movie 105: All females (0M, 5F) - infinite F/M ratio
            for (int i = 40; i <= 44; i++) {
                writer.write(i + ",Actress" + i + ",F,105\n");
            }
            
            // Movie 106: Slight male bias (6M, 4F) - 1.5:1 M/F ratio
            for (int i = 45; i <= 50; i++) {
                writer.write(i + ",Actor" + i + ",M,106\n");
            }
            for (int i = 51; i <= 54; i++) {
                writer.write(i + ",Actress" + i + ",F,106\n");
            }
            
            // Movie 107: Slight female bias (4M, 6F) - 1:1.5 M/F ratio (or 1.5:1 F/M ratio)
            for (int i = 55; i <= 58; i++) {
                writer.write(i + ",Actor" + i + ",M,107\n");
            }
            for (int i = 59; i <= 64; i++) {
                writer.write(i + ",Actress" + i + ",F,107\n");
            }
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