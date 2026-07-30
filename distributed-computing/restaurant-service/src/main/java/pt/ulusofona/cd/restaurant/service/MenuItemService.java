package pt.ulusofona.cd.restaurant.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pt.ulusofona.cd.restaurant.dto.MenuItemRequest;
import pt.ulusofona.cd.restaurant.exception.MenuItemNotFoundException;
import pt.ulusofona.cd.restaurant.mapper.MenuItemMapper;
import pt.ulusofona.cd.restaurant.model.MenuItem;
import pt.ulusofona.cd.restaurant.repository.MenuItemRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MenuItemService {

    private final MenuItemRepository menuItemRepository;
    private final RestaurantService restaurantService;

    @Transactional
    public MenuItem createMenuItem(UUID restaurantId, MenuItemRequest request) {
        restaurantService.getRestaurantById(restaurantId);

        if (request.getPrice() == null || request.getPrice().doubleValue() <= 0) {
            throw new IllegalArgumentException("Price must be greater than zero");
        }

        MenuItem menuItem = MenuItemMapper.toEntity(request, restaurantId);
        return menuItemRepository.save(menuItem);
    }

    public MenuItem getMenuItemById(UUID id) {
        return menuItemRepository.findById(id)
                .orElseThrow(() -> new MenuItemNotFoundException("Menu item not found with id: " + id));
    }

    public List<MenuItem> getMenuItemsByRestaurant(UUID restaurantId) {
        restaurantService.getRestaurantById(restaurantId);
        return menuItemRepository.findByRestaurantIdAndActive(restaurantId, true);
    }

    public List<MenuItem> getAllMenuItemsByRestaurant(UUID restaurantId) {
        restaurantService.getRestaurantById(restaurantId);
        return menuItemRepository.findByRestaurantId(restaurantId);
    }

    @Transactional
    public MenuItem updateMenuItem(UUID id, MenuItemRequest request) {
        MenuItem menuItem = getMenuItemById(id);

        if (request.getPrice() == null || request.getPrice().doubleValue() <= 0) {
            throw new IllegalArgumentException("Price must be greater than zero");
        }

        menuItem.setName(request.getName().trim());
        menuItem.setDescription(request.getDescription());
        menuItem.setPrice(request.getPrice());
        menuItem.setCurrency(request.getCurrency() != null ? request.getCurrency() : "EUR");
        return menuItemRepository.save(menuItem);
    }

    @Transactional
    public MenuItem deactivateMenuItem(UUID id) {
        MenuItem menuItem = getMenuItemById(id);
        menuItem.setActive(false);
        return menuItemRepository.save(menuItem);
    }

    @Transactional
    public void deleteMenuItem(UUID id) {
        MenuItem menuItem = getMenuItemById(id);
        menuItemRepository.delete(menuItem);
    }
}
