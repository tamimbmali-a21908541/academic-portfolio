package pt.ulusofona.lp2.greatprogrammingjourney;

public class InfiniteLoopAbyss extends Abyss {

    public InfiniteLoopAbyss() {
        super(8, "Ciclo Infinito");
    }

    @Override
    public String getImageName() {
        return "infinite-loop.png";
    }

    @Override
    public boolean isCounteredBy(Tool tool) {
        return tool.getId() == 4; // IDE
    }

    @Override
    public String applyEffect(Player player) {
        player.setStatus("Preso");
        return player.getName() + " ficou preso no " + getName();
    }
}
