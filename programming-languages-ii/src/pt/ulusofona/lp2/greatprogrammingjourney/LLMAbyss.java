package pt.ulusofona.lp2.greatprogrammingjourney;

public class LLMAbyss extends Abyss {

    public LLMAbyss() {
        super(20, "LLM");
    }

    @Override
    public String getImageName() {
        return "llm.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 5;
    }

    @Override
    public String applyEffect(Player player) {
        return player.getName() + " caiu no abismo " + getName();
    }

    public String applyEffectWithTurn(Player player, int turnCounter) {
        int lastDiceRoll = player.getLastDiceRoll();

        if (turnCounter < 4) {
            int previousPosition = player.getPreviousPosition();
            if (previousPosition < 1) {
                previousPosition = 1;
            }
            player.setPositionFromEffect(previousPosition);
            return player.getName() + " voltou para a posição " + previousPosition;
        } else {
            int currentPosition = player.getCurrentPosition();
            int newPosition = currentPosition + lastDiceRoll;
            player.setPositionFromEffect(newPosition);
            return player.getName() + " com LLM já tem experiência";
        }
    }
}
