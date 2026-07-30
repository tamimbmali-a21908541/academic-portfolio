package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.util.Date;

public class TestCountMovies {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-count");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create a movies.csv with test data
            try (FileWriter writer = new FileWriter(new File(testFolder, "movies.csv"))) {
                writer.write("movieId,movieName,movieDuration,movieBudget,movieReleaseDate\n");
                writer.write("1,Movie for May 2006,120.0,1000000,15-05-2006\n");
                writer.write("2,Another Movie for May 2006,90.0,500000,20-05-2006\n");
                writer.write("3,Movie for June 2006,110.0,800000,10-06-2006\n");
                writer.write("4,Movie for May 2007,130.0,1200000,05-05-2007\n");
            }
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test COUNT_MOVIES_MONTH_YEAR command for May 2006
            System.out.println("\nTesting COUNT_MOVIES_MONTH_YEAR for May 2006 (using number):");
            Main.Result cmdResult = Main.execute("COUNT_MOVIES_MONTH_YEAR 5 2006");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test with month name in Portuguese
            System.out.println("\nTesting COUNT_MOVIES_MONTH_YEAR for May 2006 (using Portuguese name):");
            cmdResult = Main.execute("COUNT_MOVIES_MONTH_YEAR Maio 2006");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test COUNT_MOVIES_MONTH_YEAR command for June 2006
            System.out.println("\nTesting COUNT_MOVIES_MONTH_YEAR for June 2006:");
            cmdResult = Main.execute("COUNT_MOVIES_MONTH_YEAR 6 2006");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test COUNT_MOVIES_MONTH_YEAR command for May 2007
            System.out.println("\nTesting COUNT_MOVIES_MONTH_YEAR for May 2007:");
            cmdResult = Main.execute("COUNT_MOVIES_MONTH_YEAR 5 2007");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
            // Test invalid month
            System.out.println("\nTesting COUNT_MOVIES_MONTH_YEAR with invalid month:");
            cmdResult = Main.execute("COUNT_MOVIES_MONTH_YEAR 13 2006");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            
        } catch (IOException e) {
            System.err.println("Error creating test files: " + e.getMessage());
        }
    }
} 