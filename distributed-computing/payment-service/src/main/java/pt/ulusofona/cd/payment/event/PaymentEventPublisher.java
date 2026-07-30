package pt.ulusofona.cd.payment.event;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import pt.ulusofona.cd.payment.dto.MessageEnvelope;
import pt.ulusofona.cd.payment.dto.PaymentAuthorizedPayload;
import pt.ulusofona.cd.payment.model.Payment;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Component
public class PaymentEventPublisher {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final String authorizedTopic;

    public PaymentEventPublisher(
            KafkaTemplate<String, Object> kafkaTemplate,
            @Value("${payment.topics.payment-authorized:payment.authorized}") String authorizedTopic
    ) {
        this.kafkaTemplate = kafkaTemplate;
        this.authorizedTopic = authorizedTopic;
    }

    public void publishPaymentAuthorized(Payment payment) {
        PaymentAuthorizedPayload payload = new PaymentAuthorizedPayload(
                payment.getId(),
                payment.getReservationId(),
                payment.getAmount(),
                payment.getCurrency(),
                payment.getTransactionId()
        );

        MessageEnvelope<PaymentAuthorizedPayload> envelope = new MessageEnvelope<>(
                "payment.authorized",
                payment.getStatus().name(),
                Instant.now(),
                UUID.randomUUID().toString(),
                payload
        );

        kafkaTemplate.send(authorizedTopic, payment.getReservationId().toString(), envelope)
                .whenComplete((result, ex) -> {
                    if (ex == null) {
                        log.info("Published payment.authorized event for payment: {}", payment.getId());
                    } else {
                        log.error("Failed to publish payment.authorized event: {}", ex.getMessage());
                    }
                });
    }
}
