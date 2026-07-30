package pt.ulusofona.cd.payment.mapper;

import pt.ulusofona.cd.payment.model.Payment;
import pt.ulusofona.cd.payment.model.PaymentStatus;
import pt.ulusofona.cd.payment.dto.PaymentRequest;
import pt.ulusofona.cd.payment.dto.PaymentResponse;

public class PaymentMapper {

    public static Payment toEntity(PaymentRequest dto) {
        Payment payment = new Payment();
        payment.setReservationId(dto.getReservationId());
        payment.setAmount(dto.getAmount());
        payment.setCurrency(dto.getCurrency() != null ? dto.getCurrency() : "EUR");
        payment.setStatus(PaymentStatus.PENDING);
        return payment;
    }

    public static PaymentResponse toResponse(Payment entity) {
        PaymentResponse response = new PaymentResponse();
        response.setId(entity.getId());
        response.setReservationId(entity.getReservationId());
        response.setAmount(entity.getAmount());
        response.setCurrency(entity.getCurrency());
        response.setStatus(entity.getStatus().name());
        response.setTransactionId(entity.getTransactionId());
        response.setCreatedAt(entity.getCreatedAt());
        return response;
    }
}
