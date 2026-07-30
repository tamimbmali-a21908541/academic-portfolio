package pt.ulusofona.lp2.greatprogrammingjourney;

public class SyntaxErrorAbyss extends Abyss {

    public SyntaxErrorAbyss() {
        super(0, "Erro de sintaxe");
    }

    @Override
    public String getImageName() {
        return "syntax.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 4;
    }

    @Override
    public String applyEffect(Player player) {
        int newPosition = player.getCurrentPosition() - 1;
        if (newPosition < 1) {
            newPosition = 1;
        }
        player.setPositionFromEffect(newPosition);
        return player.getName() + " voltou para a posição " + newPosition + " devido a " + getName();
    }
}
