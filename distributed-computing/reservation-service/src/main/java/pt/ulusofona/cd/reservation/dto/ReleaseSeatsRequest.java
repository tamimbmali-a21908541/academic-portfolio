package pt.ulusofona.cd.reservation.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReleaseSeatsRequest {
    private Instant scheduledAt;
    private int partySize;
}
