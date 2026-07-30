package pt.ulusofona.cd.reservation.event;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import pt.ulusofona.cd.reservation.dto.MessageEnvelope;
import pt.ulusofona.cd.reservation.model.Reservation;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Component
public class ReservationEventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final String createdTopic;
    private final String confirmedTopic;
    private final String cancelledTopic;

    public ReservationEventPublisher(
            KafkaTemplate<String, Object> kafkaTemplate,
            @Value("${reservation.topics.created:reservation.created}") String createdTopic,
            @Value("${reservation.topics.confirmed:reservation.confirmed}") String confirmedTopic,
            @Value("${reservation.topics.cancelled:reservation.cancelled}") String cancelledTopic
    ) {
        this.kafkaTemplate = kafkaTemplate;
        this.createdTopic = createdTopic;
        this.confirmedTopic = confirmedTopic;
        this.cancelledTopic = cancelledTopic;
    }

    public void publishCreated(Reservation reservation) {
        ReservationPayload payload = new ReservationPayload(
                reservation.getId(),
                reservation.getRestaurantId(),
                reservation.getCustomerName(),
                reservation.getCustomerEmail(),
                reservation.getPartySize(),
                reservation.getScheduledAt()
        );

        MessageEnvelope<ReservationPayload> envelope = new MessageEnvelope<>(
                "reservation.created",
                reservation.getStatus().name(),
                Instant.now(),
                UUID.randomUUID().toString(),
                payload
        );

        kafkaTemplate.send(createdTopic, reservation.getId().toString(), envelope)
                .whenComplete((result, ex) -> {
                    if (ex == null) {
                        log.info("Published reservation.created event for reservation: {}", reservation.getId());
                    } else {
                        log.error("Failed to publish reservation.created event: {}", ex.getMessage());
                    }
                });
    }

    public void publishConfirmed(Reservation reservation) {
        ReservationPayload payload = new ReservationPayload(
                reservation.getId(),
                reservation.getRestaurantId(),
                reservation.getCustomerName(),
                reservation.getCustomerEmail(),
                reservation.getPartySize(),
                reservation.getScheduledAt()
        );

        MessageEnvelope<ReservationPayload> envelope = new MessageEnvelope<>(
                "reservation.confirmed",
                reservation.getStatus().name(),
                Instant.now(),
                UUID.randomUUID().toString(),
                payload
        );

        kafkaTemplate.send(confirmedTopic, reservation.getId().toString(), envelope)
                .whenComplete((result, ex) -> {
                    if (ex == null) {
                        log.info("Published reservation.confirmed event for reservation: {}", reservation.getId());
                    } else {
                        log.error("Failed to publish reservation.confirmed event: {}", ex.getMessage());
                    }
                });
    }

    public void publishCancelled(Reservation reservation) {
        ReservationPayload payload = new ReservationPayload(
                reservation.getId(),
                reservation.getRestaurantId(),
                reservation.getCustomerName(),
                reservation.getCustomerEmail(),
                reservation.getPartySize(),
                reservation.getScheduledAt()
        );

        MessageEnvelope<ReservationPayload> envelope = new MessageEnvelope<>(
                "reservation.cancelled",
                reservation.getStatus().name(),
                Instant.now(),
                UUID.randomUUID().toString(),
                payload
        );

        kafkaTemplate.send(cancelledTopic, reservation.getId().toString(), envelope)
                .whenComplete((result, ex) -> {
                    if (ex == null) {
                        log.info("Published reservation.cancelled event for reservation: {}", reservation.getId());
                    } else {
                        log.error("Failed to publish reservation.cancelled event: {}", ex.getMessage());
                    }
                });
    }
}
