package pt.ulusofona.lp2.greatprogrammingjourney;

public class DuplicateCodeAbyss extends Abyss {

    public DuplicateCodeAbyss() {
        super(5, "Codigo Duplicado");
    }

    @Override
    public String getImageName() {
        return "duplicated-code.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 0;
    }

    @Override
    public String applyEffect(Player player) {
        int prevPos = player.getPreviousPosition();
        player.setPositionFromEffect(prevPos);
        return player.getName() + " voltou para a posição " + prevPos + " devido a " + getName();
    }
}
