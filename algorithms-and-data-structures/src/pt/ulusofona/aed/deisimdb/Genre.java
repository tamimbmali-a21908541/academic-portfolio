package pt.ulusofona.aed.deisimdb;

import java.util.ArrayList;
import java.util.List;

public class Genre {
    private final int id;
    private final String name;
    private final List<Movie> movies = new ArrayList<>();

    public Genre(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public List<Movie> getMovies() { return movies; }
    
    public void addMovie(Movie movie) {
        movies.add(movie);
    }

    @Override
    public String toString() {
        return id + " | " + name;
    }
}