package pt.ulusofona.cd.restaurant.dto;

import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
public class MenuItemResponse {
    private UUID id;
    private UUID restaurantId;
    private String name;
    private String description;
    private BigDecimal price;
    private String currency;
    private boolean active;
}
