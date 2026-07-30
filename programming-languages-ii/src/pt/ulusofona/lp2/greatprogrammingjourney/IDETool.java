package pt.ulusofona.lp2.greatprogrammingjourney;

public class IDETool extends Tool {

    public IDETool() {
        super(4, "IDE");
    }

    @Override
    public String getImageName() {
        return "IDE.png";
    }

    @Override
    public boolean counters(Abyss abyss) {
        return abyss.getId() == 0 || abyss.getId() == 2; // Syntax Error and Exception
    }
}
