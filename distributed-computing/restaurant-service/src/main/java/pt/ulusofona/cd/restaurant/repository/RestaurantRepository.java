package pt.ulusofona.cd.restaurant.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import pt.ulusofona.cd.restaurant.model.Restaurant;

import java.util.List;
import java.util.UUID;

@Repository
public interface RestaurantRepository extends JpaRepository<Restaurant, UUID> {
    List<Restaurant> findByCity(String city);
    List<Restaurant> findByCountry(String country);
    List<Restaurant> findByNameContainingIgnoreCase(String name);
}
