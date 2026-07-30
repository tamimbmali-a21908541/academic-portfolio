package pt.ulusofona.cd.restaurant.exception;

public class AvailabilitySlotNotFoundException extends RuntimeException {
    public AvailabilitySlotNotFoundException(String message) {
        super(message);
    }
}
