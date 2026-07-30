package pt.ulusofona.cd.payment.messaging;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.annotation.RetryableTopic;
import org.springframework.retry.annotation.Backoff;
import org.springframework.stereotype.Component;
import pt.ulusofona.cd.payment.dto.MessageEnvelope;
import pt.ulusofona.cd.payment.dto.ReservationPayload;
import pt.ulusofona.cd.payment.event.PaymentEventPublisher;
import pt.ulusofona.cd.payment.model.Payment;
import pt.ulusofona.cd.payment.model.PaymentStatus;
import pt.ulusofona.cd.payment.service.PaymentService;

@Slf4j
@Component
@RequiredArgsConstructor
public class ReservationEventConsumer {

    private final PaymentService paymentService;
    private final PaymentEventPublisher eventPublisher;
    private final ObjectMapper objectMapper;

    @RetryableTopic(
            attempts = "3",
            backoff = @Backoff(delay = 3000, multiplier = 2.0),
            dltTopicSuffix = ".DLT"
    )
    @KafkaListener(
            topics = "${payment.topics.reservation-confirmed:reservation.confirmed}",
            groupId = "${spring.kafka.consumer.group-id}"
    )
    public void onReservationConfirmed(String rawMessage) {
        try {
            log.info("Received reservation.confirmed event: {}", rawMessage);

            MessageEnvelope<ReservationPayload> envelope = objectMapper.readValue(
                    rawMessage,
                    new TypeReference<MessageEnvelope<ReservationPayload>>() {}
            );

            ReservationPayload payload = envelope.getPayload();
            String traceId = envelope.getTraceId();

            log.info("Processing payment for confirmed reservation: {}, traceId: {}",
                    payload.getReservationId(), traceId);

            Payment payment = paymentService.processReservationConfirmed(payload);

            if (payment != null && payment.getStatus() == PaymentStatus.AUTHORIZED) {
                eventPublisher.publishPaymentAuthorized(payment);
            }

        } catch (Exception e) {
            log.error("Error processing reservation.confirmed event: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to process event: " + e.getMessage(), e);
        }
    }
}
