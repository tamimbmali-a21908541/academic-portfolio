package pt.ulusofona.cd.reservation.mapper;

import pt.ulusofona.cd.reservation.model.Reservation;
import pt.ulusofona.cd.reservation.model.ReservationStatus;
import pt.ulusofona.cd.reservation.dto.ReservationRequest;
import pt.ulusofona.cd.reservation.dto.ReservationResponse;

public class ReservationMapper {

    public static Reservation toEntity(ReservationRequest dto) {
        Reservation reservation = new Reservation();
        reservation.setRestaurantId(dto.getRestaurantId());
        reservation.setCustomerName(dto.getCustomerName().trim());
        reservation.setCustomerEmail(dto.getCustomerEmail().trim());
        reservation.setPartySize(dto.getPartySize());
        reservation.setScheduledAt(dto.getScheduledAt());
        reservation.setStatus(ReservationStatus.PENDING);
        return reservation;
    }

    public static ReservationResponse toResponse(Reservation entity) {
        ReservationResponse response = new ReservationResponse();
        response.setId(entity.getId());
        response.setRestaurantId(entity.getRestaurantId());
        response.setCustomerName(entity.getCustomerName());
        response.setCustomerEmail(entity.getCustomerEmail());
        response.setPartySize(entity.getPartySize());
        response.setStatus(entity.getStatus().name());
        response.setScheduledAt(entity.getScheduledAt());
        response.setCreatedAt(entity.getCreatedAt());
        return response;
    }
}
