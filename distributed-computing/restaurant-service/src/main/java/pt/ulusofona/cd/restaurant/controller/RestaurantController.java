package pt.ulusofona.cd.restaurant.controller;

import lombok.RequiredArgsConstructor;
import pt.ulusofona.cd.restaurant.dto.RestaurantRequest;
import pt.ulusofona.cd.restaurant.dto.RestaurantResponse;
import pt.ulusofona.cd.restaurant.dto.AvailabilitySlotResponse;
import pt.ulusofona.cd.restaurant.dto.ReleaseSeatsRequest;
import pt.ulusofona.cd.restaurant.model.Restaurant;
import pt.ulusofona.cd.restaurant.mapper.RestaurantMapper;
import pt.ulusofona.cd.restaurant.mapper.AvailabilitySlotMapper;
import pt.ulusofona.cd.restaurant.service.RestaurantService;
import pt.ulusofona.cd.restaurant.service.AvailabilitySlotService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.*;

@RestController
@RequestMapping("/api/restaurants")
@RequiredArgsConstructor
public class RestaurantController {

    private final RestaurantService restaurantService;
    private final AvailabilitySlotService availabilitySlotService;

    @PostMapping
    public ResponseEntity<RestaurantResponse> create(
            @Valid @RequestBody RestaurantRequest request
    ) {
        Restaurant created = restaurantService.createRestaurant(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(RestaurantMapper.toResponse(created));
    }

    @GetMapping("/{id}")
    public ResponseEntity<RestaurantResponse> getById(@PathVariable UUID id) {
        Restaurant restaurant = restaurantService.getRestaurantById(id);
        return ResponseEntity.ok(RestaurantMapper.toResponse(restaurant));
    }

    @GetMapping
    public ResponseEntity<List<RestaurantResponse>> getAll(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String search
    ) {
        List<Restaurant> restaurants;
        if (city != null && !city.isBlank()) {
            restaurants = restaurantService.getRestaurantsByCity(city);
        } else if (search != null && !search.isBlank()) {
            restaurants = restaurantService.searchRestaurants(search);
        } else {
            restaurants = restaurantService.getAllRestaurants();
        }

        List<RestaurantResponse> responseList = restaurants.stream()
                .map(RestaurantMapper::toResponse)
                .toList();

        return ResponseEntity.ok(responseList);
    }

    @PutMapping("/{id}")
    public ResponseEntity<RestaurantResponse> update(
            @PathVariable UUID id,
            @Valid @RequestBody RestaurantRequest request
    ) {
        Restaurant updated = restaurantService.updateRestaurant(id, request);
        return ResponseEntity.ok(RestaurantMapper.toResponse(updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        restaurantService.deleteRestaurant(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/availability")
    public ResponseEntity<List<AvailabilitySlotResponse>> getAvailability(
            @PathVariable UUID id,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam int partySize
    ) {
        var slots = availabilitySlotService.getAvailableSlots(id, date, partySize);
        List<AvailabilitySlotResponse> responseList = slots.stream()
                .map(AvailabilitySlotMapper::toResponse)
                .toList();

        return ResponseEntity.ok(responseList);
    }

    @PostMapping("/{id}/availability/release")
    public ResponseEntity<Void> releaseSeats(
            @PathVariable UUID id,
            @Valid @RequestBody ReleaseSeatsRequest request
    ) {
        availabilitySlotService.releaseSeats(id, request);
        return ResponseEntity.ok().build();
    }
}
