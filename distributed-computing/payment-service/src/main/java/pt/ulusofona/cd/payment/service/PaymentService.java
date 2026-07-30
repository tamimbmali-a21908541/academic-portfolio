package pt.ulusofona.cd.payment.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pt.ulusofona.cd.payment.dto.PaymentRequest;
import pt.ulusofona.cd.payment.dto.ReservationPayload;
import pt.ulusofona.cd.payment.exception.PaymentAlreadyExistsException;
import pt.ulusofona.cd.payment.exception.PaymentNotFoundException;
import pt.ulusofona.cd.payment.mapper.PaymentMapper;
import pt.ulusofona.cd.payment.model.Payment;
import pt.ulusofona.cd.payment.model.PaymentStatus;
import pt.ulusofona.cd.payment.repository.PaymentRepository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;

    @Value("${payment.default-deposit-amount:20.00}")
    private BigDecimal defaultDepositAmount;

    @Value("${payment.default-currency:EUR}")
    private String defaultCurrency;

    @Transactional
    public Payment createPayment(PaymentRequest request) {
        if (paymentRepository.existsByReservationId(request.getReservationId())) {
            throw new PaymentAlreadyExistsException(
                    "Payment already exists for reservation: " + request.getReservationId());
        }

        Payment payment = PaymentMapper.toEntity(request);
        return paymentRepository.save(payment);
    }

    @Transactional
    public Payment processReservationConfirmed(ReservationPayload payload) {
        if (paymentRepository.existsByReservationId(payload.getReservationId())) {
            log.info("Payment already exists for reservation: {}", payload.getReservationId());
            return paymentRepository.findByReservationId(payload.getReservationId()).orElse(null);
        }

        Payment payment = new Payment();
        payment.setReservationId(payload.getReservationId());
        payment.setAmount(defaultDepositAmount);
        payment.setCurrency(defaultCurrency);
        payment.setStatus(PaymentStatus.PENDING);

        Payment saved = paymentRepository.save(payment);

        try {
            authorizePayment(saved);
            saved.setStatus(PaymentStatus.AUTHORIZED);
            saved.setTransactionId("TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            log.info("Payment authorized for reservation: {}", payload.getReservationId());
        } catch (Exception e) {
            saved.setStatus(PaymentStatus.FAILED);
            saved.setErrorMessage(e.getMessage());
            log.error("Payment failed for reservation: {}", payload.getReservationId(), e);
        }

        return paymentRepository.save(saved);
    }

    private void authorizePayment(Payment payment) {
        log.info("=== AUTHORIZING PAYMENT ===");
        log.info("Reservation: {}", payment.getReservationId());
        log.info("Amount: {} {}", payment.getAmount(), payment.getCurrency());
        log.info("===========================");
    }

    public Payment getPaymentById(UUID id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new PaymentNotFoundException("Payment not found with id: " + id));
    }

    public Payment getPaymentByReservationId(UUID reservationId) {
        return paymentRepository.findByReservationId(reservationId)
                .orElseThrow(() -> new PaymentNotFoundException(
                        "Payment not found for reservation: " + reservationId));
    }

    public List<Payment> getAllPayments() {
        return paymentRepository.findAll();
    }

    public List<Payment> getPaymentsByStatus(PaymentStatus status) {
        return paymentRepository.findByStatus(status);
    }
}
