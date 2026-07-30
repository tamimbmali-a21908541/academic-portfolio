package pt.ulusofona.lp2.greatprogrammingjourney;

public class SegFaultAbyss extends Abyss {

    public SegFaultAbyss() {
        super(9, "Segmentation Fault");
    }

    @Override
    public String getImageName() {
        return "core-dumped.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 5;
    }

    @Override
    public String applyEffect(Player player) {
        int newPosition = player.getCurrentPosition() - 3;
        if (newPosition < 1) {
            newPosition = 1;
        }
        player.setPositionFromEffect(newPosition);
        return player.getName() + " recuou para a posição " + newPosition + " devido a " + getName();
    }

    public boolean requiresMultiplePlayers() {
        return true;
    }
}
