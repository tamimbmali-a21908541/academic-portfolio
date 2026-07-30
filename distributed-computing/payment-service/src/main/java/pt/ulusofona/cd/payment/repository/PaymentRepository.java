package pt.ulusofona.cd.payment.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import pt.ulusofona.cd.payment.model.Payment;
import pt.ulusofona.cd.payment.model.PaymentStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByReservationId(UUID reservationId);
    List<Payment> findByStatus(PaymentStatus status);
    boolean existsByReservationId(UUID reservationId);
}
