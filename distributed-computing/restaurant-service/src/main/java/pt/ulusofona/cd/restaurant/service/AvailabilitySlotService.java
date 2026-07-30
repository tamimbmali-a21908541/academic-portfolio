package pt.ulusofona.cd.restaurant.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pt.ulusofona.cd.restaurant.dto.AvailabilitySlotRequest;
import pt.ulusofona.cd.restaurant.dto.ReleaseSeatsRequest;
import pt.ulusofona.cd.restaurant.exception.AvailabilitySlotNotFoundException;
import pt.ulusofona.cd.restaurant.exception.SlotOverlapException;
import pt.ulusofona.cd.restaurant.mapper.AvailabilitySlotMapper;
import pt.ulusofona.cd.restaurant.model.AvailabilitySlot;
import pt.ulusofona.cd.restaurant.repository.AvailabilitySlotRepository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AvailabilitySlotService {

    private final AvailabilitySlotRepository availabilitySlotRepository;
    private final RestaurantService restaurantService;

    @Transactional
    public AvailabilitySlot createAvailabilitySlot(UUID restaurantId, AvailabilitySlotRequest request) {
        restaurantService.getRestaurantById(restaurantId);

        if (request.getCapacity() <= 0) {
            throw new IllegalArgumentException("Capacity must be positive");
        }

        if (!request.getEndTime().isAfter(request.getStartTime())) {
            throw new IllegalArgumentException("End time must be after start time");
        }

        List<AvailabilitySlot> overlapping = availabilitySlotRepository.findOverlappingSlots(
                restaurantId, request.getDate(), request.getStartTime(), request.getEndTime());

        if (!overlapping.isEmpty()) {
            throw new SlotOverlapException("Overlapping availability slot exists for this date and time");
        }

        AvailabilitySlot slot = AvailabilitySlotMapper.toEntity(request, restaurantId);
        return availabilitySlotRepository.save(slot);
    }

    public AvailabilitySlot getAvailabilitySlotById(UUID id) {
        return availabilitySlotRepository.findById(id)
                .orElseThrow(() -> new AvailabilitySlotNotFoundException("Availability slot not found with id: " + id));
    }

    public List<AvailabilitySlot> getAvailabilitySlotsByRestaurant(UUID restaurantId) {
        restaurantService.getRestaurantById(restaurantId);
        return availabilitySlotRepository.findByRestaurantId(restaurantId);
    }

    public List<AvailabilitySlot> getAvailableSlots(UUID restaurantId, LocalDate date, int partySize) {
        restaurantService.getRestaurantById(restaurantId);
        return availabilitySlotRepository.findAvailableSlots(restaurantId, date, partySize);
    }

    @Transactional
    public AvailabilitySlot reserveSeats(UUID slotId, int partySize) {
        AvailabilitySlot slot = getAvailabilitySlotById(slotId);

        if (slot.getSeatsAvailable() < partySize) {
            throw new IllegalArgumentException("Not enough seats available. Available: " +
                    slot.getSeatsAvailable() + ", Requested: " + partySize);
        }

        slot.setSeatsAvailable(slot.getSeatsAvailable() - partySize);
        return availabilitySlotRepository.save(slot);
    }

    @Transactional
    public void releaseSeats(UUID restaurantId, ReleaseSeatsRequest request) {
        restaurantService.getRestaurantById(restaurantId);

        LocalDate date = request.getScheduledAt().atZone(ZoneId.systemDefault()).toLocalDate();
        LocalTime time = request.getScheduledAt().atZone(ZoneId.systemDefault()).toLocalTime();

        List<AvailabilitySlot> slots = availabilitySlotRepository.findByRestaurantIdAndDate(restaurantId, date);

        for (AvailabilitySlot slot : slots) {
            if (!time.isBefore(slot.getStartTime()) && time.isBefore(slot.getEndTime())) {
                int newSeats = Math.min(slot.getSeatsAvailable() + request.getPartySize(), slot.getCapacity());
                slot.setSeatsAvailable(newSeats);
                availabilitySlotRepository.save(slot);
                return;
            }
        }

        throw new AvailabilitySlotNotFoundException("No availability slot found for the given time");
    }

    @Transactional
    public AvailabilitySlot updateAvailabilitySlot(UUID id, AvailabilitySlotRequest request) {
        AvailabilitySlot slot = getAvailabilitySlotById(id);

        if (request.getCapacity() <= 0) {
            throw new IllegalArgumentException("Capacity must be positive");
        }

        if (!request.getEndTime().isAfter(request.getStartTime())) {
            throw new IllegalArgumentException("End time must be after start time");
        }

        slot.setDate(request.getDate());
        slot.setStartTime(request.getStartTime());
        slot.setEndTime(request.getEndTime());
        slot.setCapacity(request.getCapacity());
        slot.setSeatsAvailable(Math.min(slot.getSeatsAvailable(), request.getCapacity()));
        return availabilitySlotRepository.save(slot);
    }

    @Transactional
    public void deleteAvailabilitySlot(UUID id) {
        AvailabilitySlot slot = getAvailabilitySlotById(id);
        availabilitySlotRepository.delete(slot);
    }
}
