package pt.ulusofona.cd.notification.controller;

import lombok.RequiredArgsConstructor;
import pt.ulusofona.cd.notification.dto.NotificationResponse;
import pt.ulusofona.cd.notification.model.Notification;
import pt.ulusofona.cd.notification.mapper.NotificationMapper;
import pt.ulusofona.cd.notification.service.NotificationService;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getAll(
            @RequestParam(required = false) UUID reservationId
    ) {
        List<Notification> notifications;
        if (reservationId != null) {
            notifications = notificationService.getNotificationsByReservation(reservationId);
        } else {
            notifications = notificationService.getAllNotifications();
        }

        List<NotificationResponse> responseList = notifications.stream()
                .map(NotificationMapper::toResponse)
                .toList();

        return ResponseEntity.ok(responseList);
    }

    @GetMapping("/{id}")
    public ResponseEntity<NotificationResponse> getById(@PathVariable UUID id) {
        Notification notification = notificationService.getNotificationById(id);
        if (notification == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(NotificationMapper.toResponse(notification));
    }
}
