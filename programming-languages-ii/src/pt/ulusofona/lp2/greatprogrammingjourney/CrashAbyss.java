package pt.ulusofona.lp2.greatprogrammingjourney;

public class CrashAbyss extends Abyss {

    public CrashAbyss() {
        super(4, "Crash");
    }

    @Override
    public String getImageName() {
        return "crash.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 5;
    }

    @Override
    public String applyEffect(Player player) {
        player.setPositionFromEffect(1);
        return player.getName() + " voltou para a posição inicial devido a " + getName();
    }
}
