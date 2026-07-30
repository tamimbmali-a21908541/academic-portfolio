package pt.ulusofona.cd.reservation.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import pt.ulusofona.cd.reservation.dto.AvailabilitySlotDto;
import pt.ulusofona.cd.reservation.exception.NoAvailabilityException;

import java.util.List;

@Component
public class RestaurantAvailabilityClientFallback implements RestaurantAvailabilityClient {

    private static final Logger log = LoggerFactory.getLogger(RestaurantAvailabilityClientFallback.class);

    @Override
    public List<AvailabilitySlotDto> getAvailability(String id, String date, int partySize) {
        log.error("Fallback triggered: Restaurant Service is unavailable. restaurantId={}, date={}, partySize={}",
                id, date, partySize);
        throw new NoAvailabilityException("Restaurant Service is currently unavailable. Please try again later.");
    }
}
