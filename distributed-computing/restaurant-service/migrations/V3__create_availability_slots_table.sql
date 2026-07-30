CREATE TABLE IF NOT EXISTS availability_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    seats_available INT NOT NULL CHECK (seats_available >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT check_seats_available CHECK (seats_available <= capacity),
    CONSTRAINT check_end_after_start CHECK (end_time > start_time)
);

CREATE INDEX IF NOT EXISTS idx_availability_slots_restaurant_id ON availability_slots(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_availability_slots_date ON availability_slots(date);
CREATE INDEX IF NOT EXISTS idx_availability_slots_restaurant_date ON availability_slots(restaurant_id, date, start_time);
