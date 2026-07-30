package pt.ulusofona.cd.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentAuthorizedPayload {
    private UUID paymentId;
    private UUID reservationId;
    private BigDecimal amount;
    private String currency;
    private String transactionId;
}
