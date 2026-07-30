package pt.ulusofona.cd.reservation.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pt.ulusofona.cd.reservation.client.RestaurantAvailabilityClient;
import pt.ulusofona.cd.reservation.client.RestaurantCapacityClient;
import pt.ulusofona.cd.reservation.dto.AvailabilitySlotDto;
import pt.ulusofona.cd.reservation.dto.ReleaseSeatsRequest;
import pt.ulusofona.cd.reservation.dto.ReservationRequest;
import pt.ulusofona.cd.reservation.event.ReservationEventPublisher;
import pt.ulusofona.cd.reservation.exception.InvalidStatusTransitionException;
import pt.ulusofona.cd.reservation.exception.NoAvailabilityException;
import pt.ulusofona.cd.reservation.exception.ReservationNotFoundException;
import pt.ulusofona.cd.reservation.mapper.ReservationMapper;
import pt.ulusofona.cd.reservation.model.Reservation;
import pt.ulusofona.cd.reservation.model.ReservationStatus;
import pt.ulusofona.cd.reservation.repository.ReservationRepository;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final RestaurantAvailabilityClient availabilityClient;
    private final RestaurantCapacityClient capacityClient;
    private final ReservationEventPublisher eventPublisher;

    @Transactional
    public Reservation createReservation(ReservationRequest request) {
        if (request.getScheduledAt().isBefore(Instant.now())) {
            throw new IllegalArgumentException("Scheduled time must be in the future");
        }

        if (request.getPartySize() <= 0) {
            throw new IllegalArgumentException("Party size must be greater than zero");
        }

        LocalDate date = request.getScheduledAt().atZone(ZoneId.systemDefault()).toLocalDate();
        String dateStr = date.toString();

        try {
            List<AvailabilitySlotDto> slots = availabilityClient.getAvailability(
                    request.getRestaurantId().toString(),
                    dateStr,
                    request.getPartySize()
            );

            if (slots == null || slots.isEmpty()) {
                throw new NoAvailabilityException("No availability found for the requested date and party size");
            }
        } catch (NoAvailabilityException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error checking availability: {}", e.getMessage());
            throw new NoAvailabilityException("Unable to verify availability: " + e.getMessage());
        }

        Reservation reservation = ReservationMapper.toEntity(request);
        Reservation saved = reservationRepository.save(reservation);

        eventPublisher.publishCreated(saved);

        return saved;
    }

    public Reservation getReservationById(UUID id) {
        return reservationRepository.findById(id)
                .orElseThrow(() -> new ReservationNotFoundException("Reservation not found with id: " + id));
    }

    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    public List<Reservation> getReservationsByRestaurant(UUID restaurantId) {
        return reservationRepository.findByRestaurantId(restaurantId);
    }

    public List<Reservation> getReservationsByCustomerEmail(String email) {
        return reservationRepository.findByCustomerEmail(email);
    }

    @Transactional
    public Reservation confirmReservation(UUID id) {
        Reservation reservation = getReservationById(id);

        if (reservation.getStatus() != ReservationStatus.PENDING) {
            throw new InvalidStatusTransitionException(
                    "Cannot confirm reservation. Current status: " + reservation.getStatus() +
                    ". Only PENDING reservations can be confirmed."
            );
        }

        LocalDate date = reservation.getScheduledAt().atZone(ZoneId.systemDefault()).toLocalDate();
        String dateStr = date.toString();

        try {
            List<AvailabilitySlotDto> slots = availabilityClient.getAvailability(
                    reservation.getRestaurantId().toString(),
                    dateStr,
                    reservation.getPartySize()
            );

            if (slots == null || slots.isEmpty()) {
                throw new NoAvailabilityException("Slot is no longer available");
            }
        } catch (NoAvailabilityException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error checking availability during confirmation: {}", e.getMessage());
            throw new NoAvailabilityException("Unable to verify availability: " + e.getMessage());
        }

        reservation.setStatus(ReservationStatus.CONFIRMED);
        Reservation saved = reservationRepository.save(reservation);

        eventPublisher.publishConfirmed(saved);

        return saved;
    }

    @Transactional
    public Reservation cancelReservation(UUID id) {
        Reservation reservation = getReservationById(id);

        if (reservation.getStatus() == ReservationStatus.CANCELLED) {
            throw new InvalidStatusTransitionException("Reservation is already cancelled");
        }

        if (reservation.getStatus() == ReservationStatus.CONFIRMED) {
            try {
                ReleaseSeatsRequest releaseRequest = new ReleaseSeatsRequest(
                        reservation.getScheduledAt(),
                        reservation.getPartySize()
                );
                capacityClient.releaseSeats(reservation.getRestaurantId().toString(), releaseRequest);
                log.info("Released {} seats for restaurant {}", reservation.getPartySize(), reservation.getRestaurantId());
            } catch (Exception e) {
                log.error("Error releasing seats: {}", e.getMessage());
            }
        }

        reservation.setStatus(ReservationStatus.CANCELLED);
        Reservation saved = reservationRepository.save(reservation);

        eventPublisher.publishCancelled(saved);

        return saved;
    }
}
