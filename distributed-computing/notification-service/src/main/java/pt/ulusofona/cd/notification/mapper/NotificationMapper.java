package pt.ulusofona.cd.notification.mapper;

import pt.ulusofona.cd.notification.model.Notification;
import pt.ulusofona.cd.notification.dto.NotificationResponse;

public class NotificationMapper {

    public static NotificationResponse toResponse(Notification entity) {
        NotificationResponse response = new NotificationResponse();
        response.setId(entity.getId());
        response.setReservationId(entity.getReservationId());
        response.setEventType(entity.getEventType());
        response.setRecipient(entity.getRecipient());
        response.setStatus(entity.getStatus().name());
        response.setErrorMessage(entity.getErrorMessage());
        response.setSentAt(entity.getSentAt());
        response.setCreatedAt(entity.getCreatedAt());
        return response;
    }
}
