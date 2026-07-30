package pt.ulusofona.lp2.greatprogrammingjourney;

public class FileNotFoundAbyss extends Abyss {

    public FileNotFoundAbyss() {
        super(3, "FileNotFoundException");
    }

    @Override
    public String getImageName() {
        return "file-not-found-exception.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 3;
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
}
