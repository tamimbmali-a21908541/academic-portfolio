package pt.ulusofona.lp2.greatprogrammingjourney;

public class ExceptionAbyss extends Abyss {

    public ExceptionAbyss() {
        super(2, "Exception");
    }

    @Override
    public String getImageName() {
        return "exception.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 3;
    }

    @Override
    public String applyEffect(Player player) {
        int newPosition = player.getCurrentPosition() - 2;
        if (newPosition < 1) {
            newPosition = 1;
        }
        player.setPositionFromEffect(newPosition);
        return player.getName() + " voltou para a posição " + newPosition + " devido a " + getName();
    }
}
