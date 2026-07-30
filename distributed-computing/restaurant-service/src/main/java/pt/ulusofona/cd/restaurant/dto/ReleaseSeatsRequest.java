package pt.ulusofona.cd.restaurant.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;
import java.time.Instant;

@Getter
@Setter
public class ReleaseSeatsRequest {
    @NotNull(message = "Scheduled at is required")
    private Instant scheduledAt;

    @Min(value = 1, message = "Party size must be at least 1")
    private int partySize;
}
