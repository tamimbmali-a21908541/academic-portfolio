package pt.ulusofona.cd.restaurant.mapper;

import pt.ulusofona.cd.restaurant.model.Restaurant;
import pt.ulusofona.cd.restaurant.dto.RestaurantRequest;
import pt.ulusofona.cd.restaurant.dto.RestaurantResponse;

public class RestaurantMapper {

    public static Restaurant toEntity(RestaurantRequest dto) {
        Restaurant restaurant = new Restaurant();
        restaurant.setName(dto.getName().trim());
        restaurant.setAddress(dto.getAddress() != null ? dto.getAddress().trim() : null);
        restaurant.setCity(dto.getCity().trim());
        restaurant.setCountry(dto.getCountry().trim());
        restaurant.setPhone(dto.getPhone() != null ? dto.getPhone().trim() : null);
        restaurant.setEmail(dto.getEmail().trim());
        return restaurant;
    }

    public static RestaurantResponse toResponse(Restaurant entity) {
        RestaurantResponse response = new RestaurantResponse();
        response.setId(entity.getId());
        response.setName(entity.getName());
        response.setAddress(entity.getAddress());
        response.setCity(entity.getCity());
        response.setCountry(entity.getCountry());
        response.setPhone(entity.getPhone());
        response.setEmail(entity.getEmail());
        return response;
    }
}
