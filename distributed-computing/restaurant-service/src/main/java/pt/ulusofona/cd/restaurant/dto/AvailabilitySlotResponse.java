package pt.ulusofona.cd.restaurant.dto;

import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Setter
public class AvailabilitySlotResponse {
    private UUID id;
    private UUID restaurantId;
    private LocalDate date;
    private LocalTime startTime;
    private LocalTime endTime;
    private int capacity;
    private int seatsAvailable;
}
