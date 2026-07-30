package pt.ulusofona.lp2.greatprogrammingjourney;

public class ExceptionHandlingTool extends Tool {

    public ExceptionHandlingTool() {
        super(3, "Tratamento de Excepções");
    }

    @Override
    public String getImageName() {
        return "catch.png";
    }

    @Override
    public boolean counters(Abyss abyss) {
        return abyss.getId() == 2 || abyss.getId() == 3;
    }
}
