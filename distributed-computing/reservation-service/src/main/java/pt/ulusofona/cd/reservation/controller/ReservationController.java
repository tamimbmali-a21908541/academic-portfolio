package pt.ulusofona.cd.reservation.controller;

import lombok.RequiredArgsConstructor;
import pt.ulusofona.cd.reservation.dto.ReservationRequest;
import pt.ulusofona.cd.reservation.dto.ReservationResponse;
import pt.ulusofona.cd.reservation.model.Reservation;
import pt.ulusofona.cd.reservation.mapper.ReservationMapper;
import pt.ulusofona.cd.reservation.service.ReservationService;
import jakarta.validation.Valid;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;

    @PostMapping
    public ResponseEntity<ReservationResponse> create(
            @Valid @RequestBody ReservationRequest request
    ) {
        Reservation created = reservationService.createReservation(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ReservationMapper.toResponse(created));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReservationResponse> getById(@PathVariable UUID id) {
        Reservation reservation = reservationService.getReservationById(id);
        return ResponseEntity.ok(ReservationMapper.toResponse(reservation));
    }

    @GetMapping
    public ResponseEntity<List<ReservationResponse>> getAll(
            @RequestParam(required = false) UUID restaurantId,
            @RequestParam(required = false) String email
    ) {
        List<Reservation> reservations;
        if (restaurantId != null) {
            reservations = reservationService.getReservationsByRestaurant(restaurantId);
        } else if (email != null && !email.isBlank()) {
            reservations = reservationService.getReservationsByCustomerEmail(email);
        } else {
            reservations = reservationService.getAllReservations();
        }

        List<ReservationResponse> responseList = reservations.stream()
                .map(ReservationMapper::toResponse)
                .toList();

        return ResponseEntity.ok(responseList);
    }

    @PostMapping("/{id}/confirm")
    public ResponseEntity<ReservationResponse> confirm(@PathVariable UUID id) {
        Reservation confirmed = reservationService.confirmReservation(id);
        return ResponseEntity.ok(ReservationMapper.toResponse(confirmed));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<ReservationResponse> cancel(@PathVariable UUID id) {
        Reservation cancelled = reservationService.cancelReservation(id);
        return ResponseEntity.ok(ReservationMapper.toResponse(cancelled));
    }
}
