package pt.ulusofona.cd.payment.controller;

import lombok.RequiredArgsConstructor;
import pt.ulusofona.cd.payment.dto.PaymentRequest;
import pt.ulusofona.cd.payment.dto.PaymentResponse;
import pt.ulusofona.cd.payment.model.Payment;
import pt.ulusofona.cd.payment.mapper.PaymentMapper;
import pt.ulusofona.cd.payment.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping
    public ResponseEntity<PaymentResponse> create(
            @Valid @RequestBody PaymentRequest request
    ) {
        Payment created = paymentService.createPayment(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(PaymentMapper.toResponse(created));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentResponse> getById(@PathVariable UUID id) {
        Payment payment = paymentService.getPaymentById(id);
        return ResponseEntity.ok(PaymentMapper.toResponse(payment));
    }

    @GetMapping("/reservation/{reservationId}")
    public ResponseEntity<PaymentResponse> getByReservationId(@PathVariable UUID reservationId) {
        Payment payment = paymentService.getPaymentByReservationId(reservationId);
        return ResponseEntity.ok(PaymentMapper.toResponse(payment));
    }

    @GetMapping
    public ResponseEntity<List<PaymentResponse>> getAll() {
        List<Payment> payments = paymentService.getAllPayments();
        List<PaymentResponse> responseList = payments.stream()
                .map(PaymentMapper::toResponse)
                .toList();

        return ResponseEntity.ok(responseList);
    }
}
