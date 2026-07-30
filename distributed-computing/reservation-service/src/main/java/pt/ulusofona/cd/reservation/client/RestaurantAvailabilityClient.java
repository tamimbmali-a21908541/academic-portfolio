package pt.ulusofona.cd.reservation.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import pt.ulusofona.cd.reservation.dto.AvailabilitySlotDto;

import java.util.List;

@FeignClient(
        name = "restaurant-availability",
        url = "${restaurant.service.url}",
        fallback = RestaurantAvailabilityClientFallback.class
)
public interface RestaurantAvailabilityClient {

    @GetMapping("/api/restaurants/{id}/availability")
    List<AvailabilitySlotDto> getAvailability(
            @PathVariable("id") String id,
            @RequestParam("date") String date,
            @RequestParam("partySize") int partySize);
}
