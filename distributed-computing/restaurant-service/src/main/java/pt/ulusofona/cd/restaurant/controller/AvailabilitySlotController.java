package pt.ulusofona.cd.restaurant.controller;

import lombok.RequiredArgsConstructor;
import pt.ulusofona.cd.restaurant.dto.AvailabilitySlotRequest;
import pt.ulusofona.cd.restaurant.dto.AvailabilitySlotResponse;
import pt.ulusofona.cd.restaurant.model.AvailabilitySlot;
import pt.ulusofona.cd.restaurant.mapper.AvailabilitySlotMapper;
import pt.ulusofona.cd.restaurant.service.AvailabilitySlotService;
import jakarta.validation.Valid;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/restaurants/{restaurantId}/slots")
@RequiredArgsConstructor
public class AvailabilitySlotController {

    private final AvailabilitySlotService availabilitySlotService;

    @PostMapping
    public ResponseEntity<AvailabilitySlotResponse> create(
            @PathVariable UUID restaurantId,
            @Valid @RequestBody AvailabilitySlotRequest request
    ) {
        AvailabilitySlot created = availabilitySlotService.createAvailabilitySlot(restaurantId, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(AvailabilitySlotMapper.toResponse(created));
    }

    @GetMapping
    public ResponseEntity<List<AvailabilitySlotResponse>> getAll(@PathVariable UUID restaurantId) {
        List<AvailabilitySlot> slots = availabilitySlotService.getAvailabilitySlotsByRestaurant(restaurantId);
        List<AvailabilitySlotResponse> responseList = slots.stream()
                .map(AvailabilitySlotMapper::toResponse)
                .toList();

        return ResponseEntity.ok(responseList);
    }

    @GetMapping("/{slotId}")
    public ResponseEntity<AvailabilitySlotResponse> getById(
            @PathVariable UUID restaurantId,
            @PathVariable UUID slotId
    ) {
        AvailabilitySlot slot = availabilitySlotService.getAvailabilitySlotById(slotId);
        return ResponseEntity.ok(AvailabilitySlotMapper.toResponse(slot));
    }

    @PutMapping("/{slotId}")
    public ResponseEntity<AvailabilitySlotResponse> update(
            @PathVariable UUID restaurantId,
            @PathVariable UUID slotId,
            @Valid @RequestBody AvailabilitySlotRequest request
    ) {
        AvailabilitySlot updated = availabilitySlotService.updateAvailabilitySlot(slotId, request);
        return ResponseEntity.ok(AvailabilitySlotMapper.toResponse(updated));
    }

    @DeleteMapping("/{slotId}")
    public ResponseEntity<Void> delete(
            @PathVariable UUID restaurantId,
            @PathVariable UUID slotId
    ) {
        availabilitySlotService.deleteAvailabilitySlot(slotId);
        return ResponseEntity.noContent().build();
    }
}
