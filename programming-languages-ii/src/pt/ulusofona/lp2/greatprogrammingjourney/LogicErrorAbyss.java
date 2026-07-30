package pt.ulusofona.lp2.greatprogrammingjourney;

public class LogicErrorAbyss extends Abyss {

    public LogicErrorAbyss() {
        super(1, "Erro de Lógica");
    }

    @Override
    public String getImageName() {
        return "logic.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 2;
    }

    @Override
    public String applyEffect(Player player) {
        int diceValue = player.getLastDiceRoll();
        int stepsBack = diceValue / 2;  
        int newPosition = player.getCurrentPosition() - stepsBack;
        if (newPosition < 1) {
            newPosition = 1;
        }
        player.setPositionFromEffect(newPosition);
        return player.getName() + " voltou para a posição " + newPosition + " devido a " + getName();
    }
}
