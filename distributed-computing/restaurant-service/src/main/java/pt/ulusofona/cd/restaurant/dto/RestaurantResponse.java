package pt.ulusofona.cd.restaurant.dto;

import lombok.Getter;
import lombok.Setter;
import java.util.UUID;

@Getter
@Setter
public class RestaurantResponse {
    private UUID id;
    private String name;
    private String address;
    private String city;
    private String country;
    private String phone;
    private String email;
}
