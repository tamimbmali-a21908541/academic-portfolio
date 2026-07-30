CREATE TABLE IF NOT EXISTS processed_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_event UNIQUE (event_id, event_type)
);

CREATE INDEX IF NOT EXISTS idx_processed_events_event_id ON processed_events(event_id);
