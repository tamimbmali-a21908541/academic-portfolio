package pt.ulusofona.cd.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotifiedPayload {
    private UUID notificationId;
    private UUID reservationId;
    private String relatedEventType;
    private String recipient;
}
