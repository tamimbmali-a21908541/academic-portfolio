package pt.ulusofona.cd.restaurant.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import pt.ulusofona.cd.restaurant.model.AvailabilitySlot;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface AvailabilitySlotRepository extends JpaRepository<AvailabilitySlot, UUID> {
    List<AvailabilitySlot> findByRestaurantId(UUID restaurantId);

    List<AvailabilitySlot> findByRestaurantIdAndDate(UUID restaurantId, LocalDate date);

    @Query("SELECT a FROM AvailabilitySlot a WHERE a.restaurantId = :restaurantId " +
           "AND a.date = :date AND a.seatsAvailable >= :partySize")
    List<AvailabilitySlot> findAvailableSlots(
            @Param("restaurantId") UUID restaurantId,
            @Param("date") LocalDate date,
            @Param("partySize") int partySize);

    @Query("SELECT a FROM AvailabilitySlot a WHERE a.restaurantId = :restaurantId " +
           "AND a.date = :date " +
           "AND ((a.startTime < :endTime AND a.endTime > :startTime))")
    List<AvailabilitySlot> findOverlappingSlots(
            @Param("restaurantId") UUID restaurantId,
            @Param("date") LocalDate date,
            @Param("startTime") LocalTime startTime,
            @Param("endTime") LocalTime endTime);
}
