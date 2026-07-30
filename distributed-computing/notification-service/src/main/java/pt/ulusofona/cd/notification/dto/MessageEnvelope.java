package pt.ulusofona.cd.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.Instant;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageEnvelope<T> {
    private String eventType;
    private String status;
    private Instant occurredAt;
    private String traceId;
    private T payload;
}
