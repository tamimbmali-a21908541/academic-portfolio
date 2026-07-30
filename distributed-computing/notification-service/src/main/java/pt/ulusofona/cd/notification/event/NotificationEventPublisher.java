package pt.ulusofona.cd.notification.event;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import pt.ulusofona.cd.notification.dto.MessageEnvelope;
import pt.ulusofona.cd.notification.dto.NotifiedPayload;
import pt.ulusofona.cd.notification.model.Notification;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Component
public class NotificationEventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final String notifiedTopic;

    public NotificationEventPublisher(
            KafkaTemplate<String, Object> kafkaTemplate,
            @Value("${notification.topics.restaurant-notified:restaurant.notified}") String notifiedTopic
    ) {
        this.kafkaTemplate = kafkaTemplate;
        this.notifiedTopic = notifiedTopic;
    }

    public void publishRestaurantNotified(Notification notification) {
        NotifiedPayload payload = new NotifiedPayload(
                notification.getId(),
                notification.getReservationId(),
                notification.getEventType(),
                notification.getRecipient()
        );

        MessageEnvelope<NotifiedPayload> envelope = new MessageEnvelope<>(
                "restaurant.notified",
                notification.getStatus().name(),
                Instant.now(),
                UUID.randomUUID().toString(),
                payload
        );

        kafkaTemplate.send(notifiedTopic, notification.getReservationId().toString(), envelope)
                .whenComplete((result, ex) -> {
                    if (ex == null) {
                        log.info("Published restaurant.notified event for notification: {}", notification.getId());
                    } else {
                        log.error("Failed to publish restaurant.notified event: {}", ex.getMessage());
                    }
                });
    }
}
