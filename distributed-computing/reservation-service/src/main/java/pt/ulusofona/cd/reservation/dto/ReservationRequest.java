package pt.ulusofona.cd.reservation.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;
import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class ReservationRequest {
    @NotNull(message = "Restaurant ID is required")
    private UUID restaurantId;

    @NotBlank(message = "Customer name is required")
    @Size(max = 255, message = "Customer name must be at most 255 characters")
    private String customerName;

    @NotBlank(message = "Customer email is required")
    @Email(message = "Customer email must be valid")
    @Size(max = 255, message = "Customer email must be at most 255 characters")
    private String customerEmail;

    @Min(value = 1, message = "Party size must be at least 1")
    private int partySize;

    @NotNull(message = "Scheduled at is required")
    @Future(message = "Scheduled at must be in the future")
    private Instant scheduledAt;
}
