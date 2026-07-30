package pt.ulusofona.cd.notification.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import pt.ulusofona.cd.notification.model.ProcessedEvent;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProcessedEventRepository extends JpaRepository<ProcessedEvent, UUID> {
    Optional<ProcessedEvent> findByEventIdAndEventType(String eventId, String eventType);
    boolean existsByEventIdAndEventType(String eventId, String eventType);
}
