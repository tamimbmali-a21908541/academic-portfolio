package pt.ulusofona.cd.notification.dto;

import lombok.Getter;
import lombok.Setter;
import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class NotificationResponse {
    private UUID id;
    private UUID reservationId;
    private String eventType;
    private String recipient;
    private String status;
    private String errorMessage;
    private Instant sentAt;
    private Instant createdAt;
}
