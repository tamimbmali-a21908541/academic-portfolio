package pt.ulusofona.lp2.greatprogrammingjourney;

public class BlueScreenAbyss extends Abyss {

    public BlueScreenAbyss() {
        super(7, "Blue Screen of Death");
    }

    @Override
    public String getImageName() {
        return "bsod.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 5;
    }

    @Override
    public String applyEffect(Player player) {
        player.setStatus("Derrotado");
        return player.getName() + " perdeu o jogo devido ao Blue Screen of Death";
    }
}
