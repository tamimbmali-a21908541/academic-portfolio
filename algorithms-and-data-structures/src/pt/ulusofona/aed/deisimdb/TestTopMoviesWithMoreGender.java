package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestTopMoviesWithMoreGender {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-gender-diff");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test TOP_MOVIES_WITH_MORE_GENDER command with top 5
            System.out.println("\nTesting TOP_MOVIES_WITH_MORE_GENDER with top 5:");
            Main.Result cmdResult = Main.execute("TOP_MOVIES_WITH_MORE_GENDER 5");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with a different count
            System.out.println("\nTesting TOP_MOVIES_WITH_MORE_GENDER with top 2:");
            cmdResult = Main.execute("TOP_MOVIES_WITH_MORE_GENDER 2");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with invalid format
            System.out.println("\nTesting TOP_MOVIES_WITH_MORE_GENDER with invalid format:");
            cmdResult = Main.execute("TOP_MOVIES_WITH_MORE_GENDER abc");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
        } catch (IOException e) {
            System.err.println("Error creating test files: " + e.getMessage());
        }
    }
    
    private static void createTestFiles(File folder) throws IOException {
        // Create movies.csv with test movies
        try (FileWriter writer = new FileWriter(new File(folder, "movies.csv"))) {
            writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
            writer.write("101,Monkeybone,120.0,1000000,01-01-2023\n");
            writer.write("102,The Princess Diaries,90.5,500000,15-01-2023\n");
            writer.write("103,Mulholland Drive,145.0,2000000,30-01-2023\n");
            writer.write("104,Amélie,130.0,1500000,10-02-2023\n");
            writer.write("105,Jesus Christ Vampire Hunter,95.0,800000,22-02-2023\n");
            writer.write("106,Not Another Teen Movie,110.0,750000,15-03-2023\n");
            writer.write("107,Moulin Rouge!,105.0,900000,10-06-2022\n");
            writer.write("108,The Warrior,115.0,950000,20-06-2022\n");
        }
        
        // Create actors.csv with different gender distributions
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            
            // Movie 101: 15 more males than females (20M, 5F)
            for (int i = 1; i <= 20; i++) {
                writer.write(i + ",Actor" + i + ",M,101\n");
            }
            for (int i = 21; i <= 25; i++) {
                writer.write(i + ",Actress" + i + ",F,101\n");
            }
            
            // Movie 102: 14 more females than males (3M, 17F)
            for (int i = 26; i <= 28; i++) {
                writer.write(i + ",Actor" + i + ",M,102\n");
            }
            for (int i = 29; i <= 45; i++) {
                writer.write(i + ",Actress" + i + ",F,102\n");
            }
            
            // Movie 103: 12 more males than females (16M, 4F)
            for (int i = 46; i <= 61; i++) {
                writer.write(i + ",Actor" + i + ",M,103\n");
            }
            for (int i = 62; i <= 65; i++) {
                writer.write(i + ",Actress" + i + ",F,103\n");
            }
            
            // Movie 104: 11 more females than males (2M, 13F)
            for (int i = 66; i <= 67; i++) {
                writer.write(i + ",Actor" + i + ",M,104\n");
            }
            for (int i = 68; i <= 80; i++) {
                writer.write(i + ",Actress" + i + ",F,104\n");
            }
            
            // Movie 105: 11 more males than females (13M, 2F)
            for (int i = 81; i <= 93; i++) {
                writer.write(i + ",Actor" + i + ",M,105\n");
            }
            for (int i = 94; i <= 95; i++) {
                writer.write(i + ",Actress" + i + ",F,105\n");
            }
            
            // Movie 106: 11 more males than females (14M, 3F)
            for (int i = 96; i <= 109; i++) {
                writer.write(i + ",Actor" + i + ",M,106\n");
            }
            for (int i = 110; i <= 112; i++) {
                writer.write(i + ",Actress" + i + ",F,106\n");
            }
            
            // Movie 107: 10 more males than females (12M, 2F)
            for (int i = 113; i <= 124; i++) {
                writer.write(i + ",Actor" + i + ",M,107\n");
            }
            for (int i = 125; i <= 126; i++) {
                writer.write(i + ",Actress" + i + ",F,107\n");
            }
            
            // Movie 108: 9 more males than females (10M, 1F)
            for (int i = 127; i <= 136; i++) {
                writer.write(i + ",Actor" + i + ",M,108\n");
            }
            writer.write("137,Actress137,F,108\n");
        }
        
        // Minimal required files to make parsing work
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