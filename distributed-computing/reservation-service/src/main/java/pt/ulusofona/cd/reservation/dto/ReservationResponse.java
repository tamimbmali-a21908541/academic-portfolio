package pt.ulusofona.cd.reservation.dto;

import lombok.Getter;
import lombok.Setter;
import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class ReservationResponse {
    private UUID id;
    private UUID restaurantId;
    private String customerName;
    private String customerEmail;
    private int partySize;
    private String status;
    private Instant scheduledAt;
    private Instant createdAt;
}
