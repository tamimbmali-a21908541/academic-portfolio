package pt.ulusofona.cd.reservation.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import pt.ulusofona.cd.reservation.dto.ReleaseSeatsRequest;

@Component
public class RestaurantCapacityClientFallback implements RestaurantCapacityClient {

    private static final Logger log = LoggerFactory.getLogger(RestaurantCapacityClientFallback.class);

    @Override
    public void releaseSeats(String id, ReleaseSeatsRequest request) {
        log.error("Fallback triggered: Failed to release seats. Restaurant Service is unavailable. " +
                "restaurantId={}, date={}, partySize={}",
                id, request.getDate(), request.getPartySize());
        // Seat release is non-critical - log error but don't throw exception
        // The reservation will still be cancelled, seats can be released later
    }
}
