package pt.ulusofona.cd.restaurant.controller;

import lombok.RequiredArgsConstructor;
import pt.ulusofona.cd.restaurant.dto.MenuItemRequest;
import pt.ulusofona.cd.restaurant.dto.MenuItemResponse;
import pt.ulusofona.cd.restaurant.model.MenuItem;
import pt.ulusofona.cd.restaurant.mapper.MenuItemMapper;
import pt.ulusofona.cd.restaurant.service.MenuItemService;
import jakarta.validation.Valid;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/restaurants/{restaurantId}/menu")
@RequiredArgsConstructor
public class MenuItemController {

    private final MenuItemService menuItemService;

    @PostMapping
    public ResponseEntity<MenuItemResponse> create(
            @PathVariable UUID restaurantId,
            @Valid @RequestBody MenuItemRequest request
    ) {
        MenuItem created = menuItemService.createMenuItem(restaurantId, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(MenuItemMapper.toResponse(created));
    }

    @GetMapping
    public ResponseEntity<List<MenuItemResponse>> getAll(
            @PathVariable UUID restaurantId,
            @RequestParam(defaultValue = "false") boolean includeInactive
    ) {
        List<MenuItem> items;
        if (includeInactive) {
            items = menuItemService.getAllMenuItemsByRestaurant(restaurantId);
        } else {
            items = menuItemService.getMenuItemsByRestaurant(restaurantId);
        }

        List<MenuItemResponse> responseList = items.stream()
                .map(MenuItemMapper::toResponse)
                .toList();

        return ResponseEntity.ok(responseList);
    }

    @GetMapping("/{itemId}")
    public ResponseEntity<MenuItemResponse> getById(
            @PathVariable UUID restaurantId,
            @PathVariable UUID itemId
    ) {
        MenuItem item = menuItemService.getMenuItemById(itemId);
        return ResponseEntity.ok(MenuItemMapper.toResponse(item));
    }

    @PutMapping("/{itemId}")
    public ResponseEntity<MenuItemResponse> update(
            @PathVariable UUID restaurantId,
            @PathVariable UUID itemId,
            @Valid @RequestBody MenuItemRequest request
    ) {
        MenuItem updated = menuItemService.updateMenuItem(itemId, request);
        return ResponseEntity.ok(MenuItemMapper.toResponse(updated));
    }

    @PatchMapping("/{itemId}/deactivate")
    public ResponseEntity<MenuItemResponse> deactivate(
            @PathVariable UUID restaurantId,
            @PathVariable UUID itemId
    ) {
        MenuItem deactivated = menuItemService.deactivateMenuItem(itemId);
        return ResponseEntity.ok(MenuItemMapper.toResponse(deactivated));
    }

    @DeleteMapping("/{itemId}")
    public ResponseEntity<Void> delete(
            @PathVariable UUID restaurantId,
            @PathVariable UUID itemId
    ) {
        menuItemService.deleteMenuItem(itemId);
        return ResponseEntity.noContent().build();
    }
}
