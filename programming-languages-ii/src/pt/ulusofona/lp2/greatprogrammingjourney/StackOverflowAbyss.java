package pt.ulusofona.lp2.greatprogrammingjourney;

/**
 * Stack Overflow Abyss (ID 10) - Creativity Component
 *
 * Represents a stack overflow error caused by infinite recursion.
 * The player must "unwind the call stack" by going back through their position history.
 *
 * Unique behavior: Unlike other abysses that move the player to a fixed position,
 * this abyss calculates how far back to send the player based on their journey length,
 * simulating the unwinding of a recursive call stack.
 */
public class StackOverflowAbyss extends Abyss {

    public StackOverflowAbyss() {
        super(10, "Stack Overflow");
    }

    @Override
    public String getImageName() {
        return "stack_overflow.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        // Stack Overflow can be countered by debugging-related tools:
        // Tool 2 (Unit Tests), Tool 4 (IDE), Tool 5 (Professor Help)
        int toolId = tool.getId();
        return toolId == 2 || toolId == 4 || toolId == 5;
    }

    @Override
    public String applyEffect(Player player) {
        // Get player's position history
        int historySize = player.getPositionHistorySize();
        int currentPosition = player.getCurrentPosition();

        // Calculate how many positions to unwind (simulate unwinding the call stack)
        // Go back 30% of the journey, minimum 3 positions, maximum 10 positions
        int unwindAmount = Math.max(3, Math.min(10, historySize * 3 / 10));

        // Get the position from history to unwind to
        int targetPosition = currentPosition;
        if (historySize >= unwindAmount) {
            // Go back through history
            targetPosition = player.getPositionFromHistory(historySize - unwindAmount);
        } else {
            // If not enough history, go back to position 1 (start)
            targetPosition = 1;
        }

        // Apply the effect without updating position history (it's an abyss effect)
        player.setPositionFromEffect(targetPosition);

        return player.getName() + " caiu em " + getName() +
               " e teve que desfazer " + unwindAmount +
               " chamadas recursivas, voltando para a posição " + targetPosition;
    }
}
