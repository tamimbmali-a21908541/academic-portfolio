package pt.ulusofona.cd.restaurant.mapper;

import pt.ulusofona.cd.restaurant.model.MenuItem;
import pt.ulusofona.cd.restaurant.dto.MenuItemRequest;
import pt.ulusofona.cd.restaurant.dto.MenuItemResponse;
import java.util.UUID;

public class MenuItemMapper {

    public static MenuItem toEntity(MenuItemRequest dto, UUID restaurantId) {
        MenuItem menuItem = new MenuItem();
        menuItem.setRestaurantId(restaurantId);
        menuItem.setName(dto.getName().trim());
        menuItem.setDescription(dto.getDescription());
        menuItem.setPrice(dto.getPrice());
        menuItem.setCurrency(dto.getCurrency() != null ? dto.getCurrency() : "EUR");
        menuItem.setActive(true);
        return menuItem;
    }

    public static MenuItemResponse toResponse(MenuItem entity) {
        MenuItemResponse response = new MenuItemResponse();
        response.setId(entity.getId());
        response.setRestaurantId(entity.getRestaurantId());
        response.setName(entity.getName());
        response.setDescription(entity.getDescription());
        response.setPrice(entity.getPrice());
        response.setCurrency(entity.getCurrency());
        response.setActive(entity.isActive());
        return response;
    }
}
