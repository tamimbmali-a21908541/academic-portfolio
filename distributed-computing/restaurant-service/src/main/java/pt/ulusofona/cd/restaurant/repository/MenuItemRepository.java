package pt.ulusofona.cd.restaurant.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import pt.ulusofona.cd.restaurant.model.MenuItem;

import java.util.List;
import java.util.UUID;

@Repository
public interface MenuItemRepository extends JpaRepository<MenuItem, UUID> {
    List<MenuItem> findByRestaurantId(UUID restaurantId);
    List<MenuItem> findByRestaurantIdAndActive(UUID restaurantId, boolean active);
}
