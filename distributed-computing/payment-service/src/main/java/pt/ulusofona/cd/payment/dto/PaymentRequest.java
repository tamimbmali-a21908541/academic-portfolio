package pt.ulusofona.cd.payment.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
public class PaymentRequest {
    @NotNull(message = "Reservation ID is required")
    private UUID reservationId;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than zero")
    private BigDecimal amount;

    @Size(max = 3, message = "Currency must be at most 3 characters")
    private String currency = "EUR";
}
