package pt.ulusofona.aed.deisimdb;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class TestActor {

    @Test
    public void testActorToString() {
        Actor actor = new Actor(123, "Test Actor", 'M', 456);
        // Create a movie and associate it with the actor
        Movie movie = new Movie(456, "Test Movie", 120.0, 1000000, null);
        actor.addMovie(movie);
        assertEquals("123 | Test Actor | Masculino | 456", actor.toString(), 
                "Actor toString should return correct format");
    }

    @Test
    public void testActorToString2() {
        Actor actor = new Actor(456, "Female Actor", 'F', 789);
        // Create a movie and associate it with the actor
        Movie movie = new Movie(789, "Test Movie 2", 95.0, 500000, null);
        actor.addMovie(movie);
        assertEquals("456 | Female Actor | Feminino | 789", actor.toString(),
                "Female actor toString should show Feminino");
    }

    @Test
    public void testActorToString3() {
        Actor actor = new Actor(789, "Another Actor", 'M', 123);
        // Create a movie and associate it with the actor
        Movie movie = new Movie(123, "Test Movie 3", 110.0, 750000, null);
        actor.addMovie(movie);
        assertEquals("789 | Another Actor | Masculino | 123", actor.toString(),
                "Male actor toString should show Masculino");
    }

    @Test
    public void testActorToString4() {
        Actor actor = new Actor(12, "Fourth Actor", 'F', 345);
        // Create a movie and associate it with the actor
        Movie movie = new Movie(345, "Test Movie 4", 130.0, 1200000, null);
        actor.addMovie(movie);
        assertEquals("12 | Fourth Actor | Feminino | 345", actor.toString(),
                "Actor with ID 12 toString should be correct");
    }

    @Test
    public void testActorToString5() {
        Actor actor = new Actor(9999, "Fifth Actor", 'M', 678);
        // Create a movie and associate it with the actor
        Movie movie = new Movie(678, "Test Movie 5", 115.0, 900000, null);
        actor.addMovie(movie);
        assertEquals("9999 | Fifth Actor | Masculino | 678", actor.toString(),
                "Actor with ID 9999 toString should be correct");
    }
}