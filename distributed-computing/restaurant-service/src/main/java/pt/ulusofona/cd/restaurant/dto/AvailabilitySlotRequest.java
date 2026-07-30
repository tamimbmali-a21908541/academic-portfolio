package pt.ulusofona.cd.restaurant.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
public class AvailabilitySlotRequest {
    @NotNull(message = "Date is required")
    @FutureOrPresent(message = "Date must be today or in the future")
    private LocalDate date;

    @NotNull(message = "Start time is required")
    private LocalTime startTime;

    @NotNull(message = "End time is required")
    private LocalTime endTime;

    @Min(value = 1, message = "Capacity must be at least 1")
    private int capacity;
}
