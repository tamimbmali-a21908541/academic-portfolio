package pt.ulusofona.cd.notification.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import pt.ulusofona.cd.notification.dto.ReservationPayload;
import pt.ulusofona.cd.notification.model.Notification;
import pt.ulusofona.cd.notification.model.NotificationStatus;
import pt.ulusofona.cd.notification.model.ProcessedEvent;
import pt.ulusofona.cd.notification.repository.NotificationRepository;
import pt.ulusofona.cd.notification.repository.ProcessedEventRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final ProcessedEventRepository processedEventRepository;

    public boolean isEventProcessed(String eventId, String eventType) {
        return processedEventRepository.existsByEventIdAndEventType(eventId, eventType);
    }

    @Transactional
    public Notification processReservationEvent(ReservationPayload payload, String eventType, String traceId) {
        String eventId = payload.getReservationId().toString() + "-" + eventType;

        if (isEventProcessed(eventId, eventType)) {
            log.info("Event already processed, skipping: {} - {}", eventId, eventType);
            return null;
        }

        Notification notification = new Notification();
        notification.setReservationId(payload.getReservationId());
        notification.setEventType(eventType);
        notification.setRecipient(payload.getCustomerEmail());
        notification.setStatus(NotificationStatus.PENDING);

        try {
            sendNotification(notification, payload, eventType);
            notification.setStatus(NotificationStatus.SENT);
            notification.setSentAt(Instant.now());
            log.info("Notification sent successfully for reservation: {}", payload.getReservationId());
        } catch (Exception e) {
            notification.setStatus(NotificationStatus.FAILED);
            notification.setErrorMessage(e.getMessage());
            log.error("Failed to send notification: {}", e.getMessage());
        }

        Notification saved = notificationRepository.save(notification);

        ProcessedEvent processedEvent = new ProcessedEvent();
        processedEvent.setEventId(eventId);
        processedEvent.setEventType(eventType);
        processedEventRepository.save(processedEvent);

        return saved;
    }

    private void sendNotification(Notification notification, ReservationPayload payload, String eventType) {
        String message = switch (eventType) {
            case "reservation.created" -> String.format(
                    "Dear %s, your reservation at restaurant %s for %d people on %s has been created and is pending confirmation.",
                    payload.getCustomerName(),
                    payload.getRestaurantId(),
                    payload.getPartySize(),
                    payload.getScheduledAt()
            );
            case "reservation.confirmed" -> String.format(
                    "Dear %s, your reservation at restaurant %s for %d people on %s has been CONFIRMED!",
                    payload.getCustomerName(),
                    payload.getRestaurantId(),
                    payload.getPartySize(),
                    payload.getScheduledAt()
            );
            case "reservation.cancelled" -> String.format(
                    "Dear %s, your reservation at restaurant %s for %d people on %s has been CANCELLED.",
                    payload.getCustomerName(),
                    payload.getRestaurantId(),
                    payload.getPartySize(),
                    payload.getScheduledAt()
            );
            default -> "Reservation notification";
        };

        log.info("=== SENDING NOTIFICATION ===");
        log.info("To: {}", notification.getRecipient());
        log.info("Type: {}", eventType);
        log.info("Message: {}", message);
        log.info("============================");
    }

    public List<Notification> getNotificationsByReservation(UUID reservationId) {
        return notificationRepository.findByReservationId(reservationId);
    }

    public List<Notification> getAllNotifications() {
        return notificationRepository.findAll();
    }

    public Notification getNotificationById(UUID id) {
        return notificationRepository.findById(id).orElse(null);
    }
}
