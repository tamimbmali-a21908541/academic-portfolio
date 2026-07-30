package pt.ulusofona.cd.restaurant.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pt.ulusofona.cd.restaurant.dto.RestaurantRequest;
import pt.ulusofona.cd.restaurant.exception.RestaurantNotFoundException;
import pt.ulusofona.cd.restaurant.mapper.RestaurantMapper;
import pt.ulusofona.cd.restaurant.model.Restaurant;
import pt.ulusofona.cd.restaurant.repository.RestaurantRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;

    @Transactional
    public Restaurant createRestaurant(RestaurantRequest request) {
        Restaurant restaurant = RestaurantMapper.toEntity(request);
        return restaurantRepository.save(restaurant);
    }

    public Restaurant getRestaurantById(UUID id) {
        return restaurantRepository.findById(id)
                .orElseThrow(() -> new RestaurantNotFoundException("Restaurant not found with id: " + id));
    }

    public List<Restaurant> getAllRestaurants() {
        return restaurantRepository.findAll();
    }

    public List<Restaurant> getRestaurantsByCity(String city) {
        return restaurantRepository.findByCity(city);
    }

    public List<Restaurant> searchRestaurants(String name) {
        return restaurantRepository.findByNameContainingIgnoreCase(name);
    }

    @Transactional
    public Restaurant updateRestaurant(UUID id, RestaurantRequest request) {
        Restaurant restaurant = getRestaurantById(id);
        restaurant.setName(request.getName().trim());
        restaurant.setAddress(request.getAddress() != null ? request.getAddress().trim() : null);
        restaurant.setCity(request.getCity().trim());
        restaurant.setCountry(request.getCountry().trim());
        restaurant.setPhone(request.getPhone() != null ? request.getPhone().trim() : null);
        restaurant.setEmail(request.getEmail().trim());
        return restaurantRepository.save(restaurant);
    }

    @Transactional
    public void deleteRestaurant(UUID id) {
        Restaurant restaurant = getRestaurantById(id);
        restaurantRepository.delete(restaurant);
    }
}
