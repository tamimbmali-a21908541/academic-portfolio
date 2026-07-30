package pt.ulusofona.lp2.greatprogrammingjourney;

public class SideEffectsAbyss extends Abyss {

    public SideEffectsAbyss() {
        super(6, "Efeitos Secundarios");
    }

    @Override
    public String getImageName() {
        return "secondary-effects.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 1;
    }

    @Override
    public String applyEffect(Player player) {
        int positionFrom2MovesAgo = player.getPositionFromNMovesAgo(2);
        player.setPositionFromEffect(positionFrom2MovesAgo);
        return player.getName() + " voltou para a posição " + positionFrom2MovesAgo + " devido a " + getName();
    }
}
