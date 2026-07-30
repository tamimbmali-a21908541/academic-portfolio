package pt.ulusofona.lp2.greatprogrammingjourney;

public class FunctionalProgrammingTool extends Tool {

    public FunctionalProgrammingTool() {
        super(1, "Programa\u00E7\u00E3o Funcional");
    }

    @Override
    public String getImageName() {
        return "functional.png";
    }

    @Override
    public boolean counters(Abyss abyss) {
        return abyss.getId() == 6 || abyss.getId() == 8; // Side Effects and Infinite Loop
    }
}
