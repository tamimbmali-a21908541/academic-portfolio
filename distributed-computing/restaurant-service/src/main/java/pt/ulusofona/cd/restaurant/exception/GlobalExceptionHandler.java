package pt.ulusofona.cd.restaurant.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RestaurantNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleRestaurantNotFoundException(RestaurantNotFoundException ex) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", "NOT_FOUND");
        error.put("message", ex.getMessage());
        error.put("timestamp", Instant.now());
        error.put("traceId", UUID.randomUUID().toString());

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MenuItemNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleMenuItemNotFoundException(MenuItemNotFoundException ex) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", "NOT_FOUND");
        error.put("message", ex.getMessage());
        error.put("timestamp", Instant.now());
        error.put("traceId", UUID.randomUUID().toString());

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(AvailabilitySlotNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleAvailabilitySlotNotFoundException(AvailabilitySlotNotFoundException ex) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", "NOT_FOUND");
        error.put("message", ex.getMessage());
        error.put("timestamp", Instant.now());
        error.put("traceId", UUID.randomUUID().toString());

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(SlotOverlapException.class)
    public ResponseEntity<Map<String, Object>> handleSlotOverlapException(SlotOverlapException ex) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", "CONFLICT");
        error.put("message", ex.getMessage());
        error.put("timestamp", Instant.now());
        error.put("traceId", UUID.randomUUID().toString());

        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgumentException(IllegalArgumentException ex) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", "VALIDATION_ERROR");
        error.put("message", ex.getMessage());
        error.put("timestamp", Instant.now());
        error.put("traceId", UUID.randomUUID().toString());

        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(error);
    }
}
