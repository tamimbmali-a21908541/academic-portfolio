package pt.ulusofona.aed.deisimdb;

public class Constants {

    public static final String HELP_TEXT = """
        Comandos disponíveis:
        COUNT_MOVIES_MONTH_YEAR <month> <year>
        COUNT_MOVIES_DIRECTOR <full-name>
        COUNT_ACTORS_IN_2_YEARS <year-1> <year-2>
        COUNT_MOVIES_BETWEEN_YEARS_WITH_N_ACTORS <year-start> <year-end> <min> <max>
        GET_MOVIES_ACTOR_YEAR <year> <full-name>
        GET_MOVIES_WITH_ACTOR_CONTAINING <name>
        GET_TOP_4_YEARS_WITH_MOVIES_CONTAINING <search-string>
        GET_ACTORS_BY_DIRECTOR <num> <full-name>
        TOP_MONTH_MOVIE_COUNT <year>
        TOP_VOTED_ACTORS <num> <year>
        TOP_MOVIES_WITH_MORE_GENDER <num> <year> <gender>
        TOP_MOVIES_WITH_GENDER_BIAS <num> <year>
        TOP_6_DIRECTORS_WITHIN_FAMILY <year-start> <year-end>
        INSERT_ACTOR <id>;<name>;<gender>;<movie-id>
        INSERT_DIRECTOR <id>;<name>;<movie-id>
        DISTANCE_BETWEEN_ACTORS <actor-1>,<actor-2>
        MAX_BUDGET_YEAR_ACTOR <year> <full-name>
        GET_GENRES_BY_DIRECTOR <full-name>
        HELP
        QUIT""";
}