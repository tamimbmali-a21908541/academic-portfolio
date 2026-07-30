package pt.ulusofona.cd.reservation.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import pt.ulusofona.cd.reservation.dto.ReleaseSeatsRequest;

@FeignClient(
        name = "restaurant-capacity",
        url = "${restaurant.service.url}",
        fallback = RestaurantCapacityClientFallback.class
)
public interface RestaurantCapacityClient {

    @PostMapping("/api/restaurants/{id}/availability/release")
    void releaseSeats(@PathVariable("id") String id, @RequestBody ReleaseSeatsRequest request);
}
