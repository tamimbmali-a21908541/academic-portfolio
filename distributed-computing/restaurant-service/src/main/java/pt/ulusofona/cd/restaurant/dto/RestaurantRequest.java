package pt.ulusofona.cd.restaurant.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RestaurantRequest {
    @NotBlank(message = "Name is required")
    @Size(max = 255, message = "Name must be at most 255 characters")
    private String name;

    @Size(max = 500, message = "Address must be at most 500 characters")
    private String address;

    @NotBlank(message = "City is required")
    @Size(max = 100, message = "City must be at most 100 characters")
    private String city;

    @NotBlank(message = "Country is required")
    @Size(max = 100, message = "Country must be at most 100 characters")
    private String country;

    @Size(max = 50, message = "Phone must be at most 50 characters")
    private String phone;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 255, message = "Email must be at most 255 characters")
    private String email;
}
