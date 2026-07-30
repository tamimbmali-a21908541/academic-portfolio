package pt.ulusofona.aed.deisimdb;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class TestGetActorsByDirector {
    public static void main(String[] args) {
        try {
            // Create a temporary test folder
            File testFolder = new File("test-files-actors-by-director");
            if (!testFolder.exists()) {
                testFolder.mkdir();
            }
            
            // Create test files
            createTestFiles(testFolder);
            
            // Parse the test files
            boolean result = Main.parseFiles(testFolder);
            System.out.println("Parsing files result: " + result);
            
            // Test GET_ACTORS_BY_DIRECTOR command for Quentin Tarantino with min 2 appearances
            System.out.println("\nTesting GET_ACTORS_BY_DIRECTOR for Quentin Tarantino with min 2 appearances:");
            Main.Result cmdResult = Main.execute("GET_ACTORS_BY_DIRECTOR 2 Quentin Tarantino");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test with min 3 appearances
            System.out.println("\nTesting GET_ACTORS_BY_DIRECTOR for Quentin Tarantino with min 3 appearances:");
            cmdResult = Main.execute("GET_ACTORS_BY_DIRECTOR 3 Quentin Tarantino");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test with a different director
            System.out.println("\nTesting GET_ACTORS_BY_DIRECTOR for Christopher Nolan with min 2 appearances:");
            cmdResult = Main.execute("GET_ACTORS_BY_DIRECTOR 2 Christopher Nolan");
            System.out.println("Success: " + cmdResult.success);
            System.out.println("Result: " + cmdResult.result);
            System.out.println("Error code: " + cmdResult.error);
            
            // Test with non-existent director
            System.out.println("\nTesting GET_ACTORS_BY_DIRECTOR with non-existent director:");
            cmdResult = Main.execute("GET_ACTORS_BY_DIRECTOR 2 Unknown Director");
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
            // Quentin Tarantino movies
            writer.write("101,Pulp Fiction,154.0,8000000,01-01-1994\n");
            writer.write("102,Kill Bill Vol. 1,111.0,30000000,10-10-2003\n");
            writer.write("103,Kill Bill Vol. 2,137.0,30000000,16-04-2004\n");
            writer.write("104,Django Unchained,165.0,100000000,25-12-2012\n");
            
            // Christopher Nolan movies
            writer.write("201,Interstellar,169.0,165000000,07-11-2014\n");
            writer.write("202,Inception,148.0,160000000,16-07-2010\n");
            writer.write("203,The Dark Knight,152.0,185000000,18-07-2008\n");
        }
        
        // Create directors.csv
        try (FileWriter writer = new FileWriter(new File(folder, "directors.csv"))) {
            writer.write("directorId,directorName,movieId\n");
            writer.write("1,Quentin Tarantino,101\n");
            writer.write("1,Quentin Tarantino,102\n");
            writer.write("1,Quentin Tarantino,103\n");
            writer.write("1,Quentin Tarantino,104\n");
            writer.write("2,Christopher Nolan,201\n");
            writer.write("2,Christopher Nolan,202\n");
            writer.write("2,Christopher Nolan,203\n");
        }
        
        // Create actors.csv - actors appearing in multiple movies
        try (FileWriter writer = new FileWriter(new File(folder, "actors.csv"))) {
            writer.write("actorId,actorName,actorGender,movieId\n");
            
            // Quentin Tarantino as actor in his own movies
            writer.write("1,Quentin Tarantino,M,101\n");
            writer.write("1,Quentin Tarantino,M,104\n");
            
            // Samuel L. Jackson in multiple Tarantino movies
            writer.write("2,Samuel L. Jackson,M,101\n");
            writer.write("2,Samuel L. Jackson,M,103\n");
            writer.write("2,Samuel L. Jackson,M,104\n");
            
            // Michael Bowen in multiple Tarantino movies
            writer.write("3,Michael Bowen,M,102\n");
            writer.write("3,Michael Bowen,M,103\n");
            
            // Michael Parks in multiple Tarantino movies
            writer.write("4,Michael Parks,M,102\n");
            writer.write("4,Michael Parks,M,103\n");
            
            // Sakichi Satô in multiple Tarantino movies
            writer.write("5,Sakichi Satô,M,102\n");
            writer.write("5,Sakichi Satô,M,103\n");
            
            // Laura Cayouette in multiple Tarantino movies
            writer.write("6,Laura Cayouette,F,102\n");
            writer.write("6,Laura Cayouette,F,104\n");
            
            // Tim Roth in only one Tarantino movie (for testing min appearances)
            writer.write("7,Tim Roth,M,101\n");
            
            // Actors in Christopher Nolan movies
            writer.write("8,Christian Bale,M,203\n");
            writer.write("9,Michael Caine,M,201\n");
            writer.write("9,Michael Caine,M,202\n");
            writer.write("9,Michael Caine,M,203\n");
            writer.write("10,Leonardo DiCaprio,M,202\n");
            writer.write("11,Joseph Gordon-Levitt,M,202\n");
            writer.write("11,Joseph Gordon-Levitt,M,203\n");
        }
        
        // Minimal required files to make parsing work
        try (FileWriter writer = new FileWriter(new File(folder, "genres.csv"))) {
            writer.write("genreId,genreName\n");
            writer.write("1,Action\n");
            writer.write("2,Drama\n");
        }
        
        try (FileWriter writer = new FileWriter(new File(folder, "genres_movies.csv"))) {
            writer.write("genreId,movieId\n");
            writer.write("1,101\n");
            writer.write("1,102\n");
            writer.write("1,103\n");
            writer.write("1,104\n");
            writer.write("2,201\n");
            writer.write("2,202\n");
            writer.write("2,203\n");
        }
    }
} 