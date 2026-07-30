package pt.ulusofona.cd.notification.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import pt.ulusofona.cd.notification.model.Notification;
import pt.ulusofona.cd.notification.model.NotificationStatus;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByReservationId(UUID reservationId);
    List<Notification> findByStatus(NotificationStatus status);
    List<Notification> findByEventType(String eventType);
}
