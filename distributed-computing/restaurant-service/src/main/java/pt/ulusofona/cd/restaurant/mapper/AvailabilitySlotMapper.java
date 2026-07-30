package pt.ulusofona.cd.restaurant.mapper;

import pt.ulusofona.cd.restaurant.model.AvailabilitySlot;
import pt.ulusofona.cd.restaurant.dto.AvailabilitySlotRequest;
import pt.ulusofona.cd.restaurant.dto.AvailabilitySlotResponse;
import java.util.UUID;

public class AvailabilitySlotMapper {

    public static AvailabilitySlot toEntity(AvailabilitySlotRequest dto, UUID restaurantId) {
        AvailabilitySlot slot = new AvailabilitySlot();
        slot.setRestaurantId(restaurantId);
        slot.setDate(dto.getDate());
        slot.setStartTime(dto.getStartTime());
        slot.setEndTime(dto.getEndTime());
        slot.setCapacity(dto.getCapacity());
        slot.setSeatsAvailable(dto.getCapacity());
        return slot;
    }

    public static AvailabilitySlotResponse toResponse(AvailabilitySlot entity) {
        AvailabilitySlotResponse response = new AvailabilitySlotResponse();
        response.setId(entity.getId());
        response.setRestaurantId(entity.getRestaurantId());
        response.setDate(entity.getDate());
        response.setStartTime(entity.getStartTime());
        response.setEndTime(entity.getEndTime());
        response.setCapacity(entity.getCapacity());
        response.setSeatsAvailable(entity.getSeatsAvailable());
        return response;
    }
}
