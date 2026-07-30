package pt.ulusofona.aed.deisimdb;

import java.util.ArrayList;
import java.util.List;

public class Actor {
    private final int id;
    private final String name;
    private final char gender;
    /**
     * Stores the ID of the first movie this actor was associated with upon initial data loading.
     * This ID is used in `toString()` to consistently represent the actor's primary or first-known movie,
     * fulfilling the requirement to associate the actor with their earliest appearance in the dataset.
     */
    private final int representativeMovieId;
    private final List<Movie> movies = new ArrayList<>();

    public Actor(int id, String name, char gender, int representativeMovieId) {
        this.id = id;
        this.name = name;
        this.gender = gender;
        this.representativeMovieId = representativeMovieId;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public char getGender() { return gender; }
    public List<Movie> getMovies() { return movies; }

    public void addMovie(Movie movie) {
        movies.add(movie);
    }

    public void addMovieIfAbsent(Movie m) {
        if (m != null && !movies.contains(m)) {
            movies.add(m);
        }
    }
    @Override
    public String toString() {
        String genderText = gender == 'M' ? "Masculino" :
                gender == 'F' ? "Feminino" : "Unknown";
        int movieId = this.representativeMovieId;
        return String.format("%d | %s | %s | %d", id, name, genderText, movieId);
    }
}