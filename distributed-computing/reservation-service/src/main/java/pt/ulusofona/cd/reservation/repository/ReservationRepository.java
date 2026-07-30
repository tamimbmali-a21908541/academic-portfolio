package pt.ulusofona.cd.reservation.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import pt.ulusofona.cd.reservation.model.Reservation;
import pt.ulusofona.cd.reservation.model.ReservationStatus;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, UUID> {
    List<Reservation> findByRestaurantId(UUID restaurantId);
    List<Reservation> findByCustomerEmail(String customerEmail);
    List<Reservation> findByStatus(ReservationStatus status);
    List<Reservation> findByRestaurantIdAndStatus(UUID restaurantId, ReservationStatus status);
}
