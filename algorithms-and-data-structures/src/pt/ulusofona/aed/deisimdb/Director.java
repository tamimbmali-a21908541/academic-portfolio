package pt.ulusofona.aed.deisimdb;

import java.util.ArrayList;
import java.util.List;

public class Director {
    private final int id;
    private final String name;
    private final List<Movie> movies = new ArrayList<>();
    /**
     * The ID of the first valid movie this director was associated with.
     * This ensures consistent toString() output regardless of movie list changes.
     */
    private int representativeMovieId = 0;

    public Director(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public List<Movie> getMovies() { return movies; }

    public void addMovie(Movie movie) {
        movies.add(movie);
        // Set representative movie ID on first movie addition
        if (representativeMovieId == 0 && movie != null) {
            representativeMovieId = movie.getId();
        }
    }

    public void addMovieIfAbsent(Movie m) {
        if (m != null && !movies.contains(m)) {
            movies.add(m);
        }
    }

    @Override
    public String toString() {
        // Use representativeMovieId for consistent output
        return id + " | " + name + " | " + representativeMovieId;
    }
}