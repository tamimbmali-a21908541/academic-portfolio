package pt.ulusofona.cd.notification.messaging;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.annotation.RetryableTopic;
import org.springframework.retry.annotation.Backoff;
import org.springframework.stereotype.Component;
import pt.ulusofona.cd.notification.dto.MessageEnvelope;
import pt.ulusofona.cd.notification.dto.ReservationPayload;
import pt.ulusofona.cd.notification.event.NotificationEventPublisher;
import pt.ulusofona.cd.notification.model.Notification;
import pt.ulusofona.cd.notification.service.NotificationService;

@Slf4j
@Component
@RequiredArgsConstructor
public class ReservationEventConsumer {

    private final NotificationService notificationService;
    private final NotificationEventPublisher eventPublisher;
    private final ObjectMapper objectMapper;

    @RetryableTopic(
            attempts = "3",
            backoff = @Backoff(delay = 3000, multiplier = 2.0),
            dltTopicSuffix = ".DLT"
    )
    @KafkaListener(
            topics = "${notification.topics.reservation-created:reservation.created}",
            groupId = "${spring.kafka.consumer.group-id}"
    )
    public void onReservationCreated(String rawMessage) {
        processEvent(rawMessage, "reservation.created");
    }

    @RetryableTopic(
            attempts = "3",
            backoff = @Backoff(delay = 3000, multiplier = 2.0),
            dltTopicSuffix = ".DLT"
    )
    @KafkaListener(
            topics = "${notification.topics.reservation-confirmed:reservation.confirmed}",
            groupId = "${spring.kafka.consumer.group-id}"
    )
    public void onReservationConfirmed(String rawMessage) {
        processEvent(rawMessage, "reservation.confirmed");
    }

    @RetryableTopic(
            attempts = "3",
            backoff = @Backoff(delay = 3000, multiplier = 2.0),
            dltTopicSuffix = ".DLT"
    )
    @KafkaListener(
            topics = "${notification.topics.reservation-cancelled:reservation.cancelled}",
            groupId = "${spring.kafka.consumer.group-id}"
    )
    public void onReservationCancelled(String rawMessage) {
        processEvent(rawMessage, "reservation.cancelled");
    }

    private void processEvent(String rawMessage, String eventType) {
        try {
            log.info("Received {} event: {}", eventType, rawMessage);

            MessageEnvelope<ReservationPayload> envelope = objectMapper.readValue(
                    rawMessage,
                    new TypeReference<MessageEnvelope<ReservationPayload>>() {}
            );

            ReservationPayload payload = envelope.getPayload();
            String traceId = envelope.getTraceId();

            log.info("Processing {} for reservation: {}, traceId: {}",
                    eventType, payload.getReservationId(), traceId);

            Notification notification = notificationService.processReservationEvent(payload, eventType, traceId);

            if (notification != null) {
                eventPublisher.publishRestaurantNotified(notification);
            }

        } catch (Exception e) {
            log.error("Error processing {} event: {}", eventType, e.getMessage(), e);
            throw new RuntimeException("Failed to process event: " + e.getMessage(), e);
        }
    }
}
