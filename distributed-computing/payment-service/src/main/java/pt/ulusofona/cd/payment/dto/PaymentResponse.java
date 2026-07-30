package pt.ulusofona.cd.payment.dto;

import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class PaymentResponse {
    private UUID id;
    private UUID reservationId;
    private BigDecimal amount;
    private String currency;
    private String status;
    private String transactionId;
    private Instant createdAt;
}
